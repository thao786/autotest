module ResultsHelper
  def extractParams(paramStr, param)
    if param.class == String && /#\{.+\}/ =~ param
      eval "#{paramStr}
#{param}"
    else
      param
    end
  end

  def runSteps(driver, test, run_id, checkAssertions = true)
    Result.create(test: test, assertion: Assertion.where(assertion_type: "report").first, runId: run_id) if checkAssertions # only check main test's assertions

    tabs = [] # the first tab is always blank for easier management
    param_str = ''
    test.test_params.each { |param|
      param_str = "#{param_str}
#{param.label} = \"#{param.val}\""
    }

    steps = Step.where(test: test, active: true)
    steps.each { |step|
      if checkAssertions # ran pre-tests (only available to main test)
        step.pre_tests.each { |pre_test|
          runSteps(driver, pre_test, run_id, false)
        }
      end

      # check if we need to switch tab
      current_tab_id = driver.execute_script "return window.name"
      tab_id = "#{step.windowId}-#{step.tabId}"
      if step.tabId.present? && current_tab_id != tab_id
        if tabs.exclude? tab_id
          driver.execute_script "window.open('', '#{tab_id}')"
          tabs << tab_id
        end
        driver.switch_to.window tab_id
      end

      begin
        Timeout::timeout(step.wait/1000) { # wait
          case step.action_type
            when 'pageload'
              driver.get extractParams(param_str,step.webpage)
            when 'pageloadCurl'
              # load headers and params
              Thread.new {
                driver.get extractParams(param_str,step.webpage)
              }
            when 'scroll'
              driver.execute_script "scroll(#{extractParams(param_str,step.scrollLeft)}, #{extractParams(param_str,step.scrollTop)})"
            when 'keypress'
              driver.action.send_keys(extractParams(param_str,step.typed)).perform
            when 'resize'
              driver.manage.window.resize_to(step.screenwidth, step.screenheight)
            when 'click'
              type = extractParams(param_str,step.selector[:selectorType])
              selector = extractParams(param_str,step.selector[:selector])
              eq = extractParams(param_str,step.selector[:eq]).to_i
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
                begin
                  element.click
                rescue Exception => error
                  click_with_js(driver, type, selector, eq)
                end
              else # when WebDriver's find_elements fails, find with JS
                click_with_js(driver, type, selector, eq)
              end
            else
              true
          end
        }
      rescue Timeout::Error
        # carry on
      rescue Exception => error
        Result.create(test: test, step: step, webpage: driver.current_url,
                      assertion: Assertion.where(assertion_type: "step-succeed").first,
                      runId: run_id, error: error[0..100])
      end

      body_text = driver.execute_script 'return document.body.textContent'
      # check if body_text has even numbers of ( and )

      # add extractions to params
      step.extracts.each { |extract|
        extract_value = driver.execute_script extract.command
        param_str = "#{param_str}
body_text#{step.id} = %(#{body_text})
#{extract.title} = \"#{extract_value}\""
      }
    }

    if checkAssertions # check assertions
      tabs.each { |tab_id|
        driver.switch_to.window tab_id

        # check 404 and 500 errors for ALL tabs
        logs = driver.manage.logs.get('browser')
        logs.each { |log|
          if log.message.include? 'Failed to load resource: the server responded with a status'
            Result.create(test: test, webpage: driver.current_url,
                          assertion: Assertion.where(assertion_type: "http-200").first,
                          runId: run_id, error: log)
          end
        }

        assertions = Assertion.where(test: test, active: true)
        assertions.each { |assertion|
          if assertion.webpage.blank? || assertion.webpage == driver.current_url
            condition = extractParams(param_str, assertion.condition)
            passed = case assertion.assertion_type
                       when 'text-in-page'
                         text = driver.execute_script 'return document.body.textContent'
                         text.include? condition
                       when 'text-not-in-page'
                         text = driver.execute_script 'return document.body.textContent'
                         text.exclude? condition
                       when 'html-in-page'
                         source = driver.execute_script 'return document.documentElement.outerHTML'
                         source.include? condition
                       when 'html-not-in-page'
                         source = driver.execute_script 'return document.documentElement.outerHTML'
                         source.exclude? condition
                       when 'page-title'
                         driver.execute_script('return document.title').include? condition
                       else # self-enter JS command
                         driver.execute_script(assertion.condition) == 'true'
                     end
            unless passed
              Result.create(test: test, webpage: driver.current_url,
                            assertion: assertion, runId: run_id)
            end
          end
        }
      }
    end
  end

  def click_with_js(driver, type, selector, eq)
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

  def getVideoPath(run_id)
    md5 = Digest::MD5.hexdigest "videoCapture-#{run_id}"
    # "#{ENV['HOME']}/#{ENV['mediaDir']}/#{md5}"
    "https://s3.amazonaws.com/#{ENV['bucket']}/#{md5}.mp4"
  end
end