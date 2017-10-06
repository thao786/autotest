class ApiController < ActionController::Base
  def check
    if Test.find_by(session_id: params[:session_id])
      render json: true
    else
      render json: false
    end
  end

  # save this event to draft and update test's cache response
  def saveEvent
    if params[:action_type] == 'pageload' and params[:webpage] =~ %r|http(.*)google(.*)/_/chrome/newtab|
      render json: true
    else
      test = Test.find_by(session_id: params[:session_id])

      if test and test.session_expired_at > DateTime.now
        test.update(session_expired_at: (Time.now + 15*60))
        hash = params.to_unsafe_h
        params[:draft] = hash

        draft = Draft.create(params.require(:draft).permit(:webpage, :stamp, :apk, :activity, :action_type, :session_id, :typed, :screenwidth, :screenheight, :scrollTop, :scrollLeft, :x, :y, :tabId, :windowId))

        draft.update(selector: {selector: params[:selector], eq: params[:eq].to_i, selectorType: params[:selectorType], childrenCount: params[:childrenCount]})
        render json: true
      else
        render json: false
      end
    end
  end

  # request has to be encrypted with a private key (to make sure it comes from Beanstalk)
  # too much work to create security group for each Beanstalk instance
  # only make sense when decrypted with the public key
  # anybody can read, but its just test_id anyway
  def runTest
    begin
      secret_data = Base64::decode64(params[:data])
      decipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
      decipher.decrypt
      decipher.key = Digest::SHA256.digest ENV['RDS_PASSWORD']
      decipher.iv  = ENV['iv']
      decrypted_data = decipher.update(secret_data) + decipher.final

      data = JSON.parse decrypted_data
      test = Test.find data['test_id']
      headless = Headless.new(video: {:frame_rate => 12, provider: :ffmpeg})
      headless.start

      caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => {'binary' => '/usr/bin/chromium-browser'})

      first_step = Step.where(test: test).first
      run_id = test.id
      md5 = helpers.hash_video run_id
      video_path_on_disk = "#{ENV['HOME']}/#{ENV['mediaDir']}/#{md5}"

      driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
      driver.manage.window.resize_to(first_step.screenwidth, first_step.screenheight)

      headless.video.start_capture # start recording
      helpers.runSteps(driver, test, test.id)
      headless.video.stop_and_save("#{video_path_on_disk}.mov")
      driver.quit

      `ffmpeg -i #{video_path_on_disk}.mov -pix_fmt yuv420p #{video_path_on_disk}.mp4`
      client = Aws::S3::Client.new(region: 'us-east-1')
      resource = Aws::S3::Resource.new(client: client)
      bucket = resource.bucket('autotest-test')
      bucket.object("#{md5}.mp4").upload_file("#{video_path_on_disk}.mp4", acl:'public-read')

      File.delete "#{video_path_on_disk}.mov"
      File.delete "#{video_path_on_disk}.mp4"

      if data[:user] == 'thao786'
        render json: helpers.video_aws_path(run_id)
      else
        render json: true
      end
    rescue Exception => error
      p error.message
      # email Thao

      if data[:user] == 'thao786'
        render json: error.message, :status => 404
      else
        render json: false, :status => 404
      end
    end
  end

  def intro
    render template: 'layouts/intro'
  end
end
