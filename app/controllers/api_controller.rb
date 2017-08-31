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

    @test = Test.find(params[:test_id])
    Result.where(test: @test).destroy_all # only 1 test can be ran at a time
    @test.update(running: true)

    begin
      Dir.mkdir "#{ENV['HOME']}/#{ENV['picDir']}/#{@test.id}"

      unless Rails.env.development?
        headless = Headless.new
        headless.start
      end

      driver = Selenium::WebDriver.for :firefox
      helpers.runSteps(driver, @test, @test.id)
      driver.quit
      FileUtils.remove_entry "#{ENV['HOME']}/#{ENV['picDir']}/#{@test.id}"
      @test.update(running: false)
      render json: @test.id
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
