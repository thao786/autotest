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
    test = Test.find_by(session_id: params[:session_id])

    if test and test.session_expired_at > DateTime.now
      test.session_expired_at=Time.now + 15*60
      test.save

      hash = params.to_unsafe_h
      params[:draft] = hash

      draft = Draft.create(params.require(:draft).permit(:webpage, :stamp, :apk, :activity,
                 :action_type, :session_id, :typed, :screenwidth, :screenheight,
                 :scrollTop, :scrollLeft, :x, :y, :tabId, :windowId))
      draft.update(selector: {selector: params[:selector], eq: params[:eq].to_i,
                   selectorType: params[:selectorType], childrenCount: params[:childrenCount]})
      render json: true
    else
      render json: false
    end
  end

  def runTest
    unless params[:password] == ENV['beanstalk_password']
      render json: false
    end

    test = Test.find(params[:test_id])
    begin
      headless = Headless.new
      headless.start

      caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => {'binary' => '/usr/bin/chromium-browser'})

      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--screen-size=1200x800')

      md5 = Digest::MD5.hexdigest "videoCapture-#{runId}"
      videoPath = "#{ENV['HOME']}/#{ENV['mediaDir']}/#{runId}/#{md5}"

      driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps, options: options

      headless.video.start_capture
      runSteps(driver, test, test.id)
      headless.video.stop_and_save("#{videoPath}.mov")
      driver.quit

      `ffmpeg -i #{videoPath}.mov -pix_fmt yuv420p #{videoPath}.mp4`
      client = Aws::S3::Client.new(region: 'us-east-1')
      resource = Aws::S3::Resource.new(client: client)
      bucket = resource.bucket('autotest-test')
      bucket.object("#{videoPath}.mp4").upload_file("#{md5}.mp4", acl:'public-read')
      render json: true
    rescue
      render json: false, :status => 404
    end
  end

  def intro
    render template: 'layouts/intro'
  end

  def fonts
    send_file "#{ENV['HOME']}/autotest/vendor/assets/fonts/#{params[:font]}.#{params[:format]}"
  end
end
