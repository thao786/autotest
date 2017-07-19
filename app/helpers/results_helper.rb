module ResultsHelper
  def runSteps(test, checkAssertions = true)
    runId = test.id
    driver = Selenium::WebDriver.for :chrome
    steps = Step.where(test: test)
    steps.each { |step|
      if checkAssertions # ran pre-tests (only available to main test)
      end

      begin
        case step.action_type
          when 'pageload'
            driver.get step.webpage
          when 'pageloadCurl'
            # load headers and params
            driver.get step.webpage
          when 'scroll'
            scrollLeft.present? and scrollTop.present?
          when 'keypress'
            driver.action.send_keys(step.typed).perform
          when 'click'
            selector.present?
          else
            true
        end
      rescue Exception => error
        Result.create(test: test, step: step, webpage: driver.current_url,
                      assertion: Assertion.where(assertion_type: "step-succeed").first,
                      runId: runId, error: error)
      end

      # save screenshot
      md5 = Digest::MD5.hexdigest "#{runId}-#{step.order}"
      screenshot = "#{ENV['picDir']}#{md5}.jpg"
      driver.save_screenshot screenshot

      # upload to AWS

      if checkAssertions # check assertions
      end
    }
  end
end
