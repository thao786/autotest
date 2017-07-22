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
            driver.execute_script("scroll('#{step.scrollTop}, #{step.scrollTop}')")
          when 'keypress'
            driver.action.send_keys(step.typed).perform
          when 'click'
            type = step.selector.selectorType
            selector = step.selector.selector
            eq = step.selector.eq
            element = case type # first, find DOM with WebDriver
                        when 'id'
                          driver.find_elements(:id => selector).first
                        when 'class'
                          driver.find_elements(:class => selector)[eq]
                        when 'tag'
                          driver.find_elements(:tag_name => selector)[eq]
                        when 'name'
                          driver.find_elements(:name => selector)[eq]
                        when 'partialLink' # link text
                          driver.find_elements(:partial_link_text => selector)[eq]
                        when 'href'
                          driver.find_elements(:css => "a[href='#{selector}']")[eq]
                        when 'partialHref'
                          driver.find_elements(:css => "a[href*='#{selector}']")[eq]
                        when 'button' # use XPath
                          driver.find_elements(:xpath, "//button[text()[contains(.,'#{selector}')]]")[eq]
                        when 'css'
                          driver.find_elements(:css => selector)[eq]
                        when 'coordination'
                          elem = driver.find_elements(:tag_name => 'body').first
                          driver.action.move_to(elem, 50, 50).click.perform
                          elem
                        else
                          nil
                    end
            if element.present?
              element.click
            else # when WebDriver's find_elements fails, find with JS
              js_selector = case type
                              when 'id'
                                "document.getElementById('#{selector}')"
                              when 'class'
                                "document.getElementsByClassName('#{selector}')[#{eq}]"
                              when 'tag'
                                "document.getElementsByTagName('#{selector}')[#{eq}]"
                              when 'name'
                                "document.getElementsByName('#{selector}')[#{eq}]"
                              when 'partialLink' # use XPath, cant use eq
                                "document.evaluate('//a[text()[contains(.,\'#{selector}')]]\' ,document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue"
                              when 'href'
                                "document.querySelectorAll('a[href=\'#{selector}\']')[#{eq}]"
                              when 'partialHref'
                                "document.querySelectorAll('a[href*=\'#{selector}\']')[#{eq}]"
                              when 'button' # use XPath, cant use eq
                                "document.evaluate('//button[text()[contains(.,\'#{selector}')]]\' ,document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue"
                              when 'css'
                                "document.querySelectorAll('#{selector}')[#{eq}]"
                              else
                                nil
                            end
              driver.execute_script("#{js_selector}.click()")
            end
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
      s3 = Aws::S3::Client.new(region:'us-east-1')
      obj = s3.bucket(ENV['bucket']).object("#{md5}.jpg")
      obj.upload_file(screenshot)
       # delete local screenshot

      if checkAssertions # check assertions
      end
    }
  end
end