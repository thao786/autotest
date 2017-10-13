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
        begin # if there's no such tab_id, stay in the current one
          driver.switch_to.window tab_id
        rescue # do nothing. carry on
        end
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
                  click_with_js(test, driver, type, selector, eq)
                end
              else # when WebDriver's find_elements fails, find with JS
                click_with_js(test, driver, type, selector, eq)
              end
            else
              true
          end
        }

        sleep step.wait/1000
      rescue Timeout::Error
        # carry on
      rescue Exception => error
        Result.create(test: test, step: step, webpage: driver.current_url,
                      assertion: Assertion.where(assertion_type: "step-succeed").first,
                      runId: run_id, error: error)
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
      console_log = ''
      tabs.each { |tab_id|
        driver.switch_to.window tab_id

        # check 404 and 500 errors for ALL tabs
        logs = driver.manage.logs.get('browser')
        logs.each { |log|
          console_log = "#{console_log}
#{log.message}"
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
                       when 'status-code'
                         if test.steps.count == 1 # condition is status code in this case
                           step = test.steps.first
                           begin
                             status = (open step.webpage).status.join
                           rescue Exception => error
                             status = error.message
                           end
                           status.include? condition
                         end
                       else # self-enter JS command
                         driver.execute_script "return #{condition}"
                     end
            unless passed
              Result.create(test: test, webpage: driver.current_url,
                            assertion: assertion, runId: run_id, error: console_log)
            end
          end
        }
      }

      Result.create(test: test, assertion: Assertion.where(assertion_type: "report").first, runId: run_id, error: console_log)
    end
  end

  def click_with_js(test, driver, type, selector, eq)
    js_selector = case type
                    when 'id'
                      "document.getElementById('#{selector}')"
                    when 'class'
                      "document.getElementsByClassName('#{selector}')"
                    when 'tag'
                      "document.getElementsByTagName('#{selector}')"
                    when 'name'
                      "document.getElementsByName('#{selector}')"
                    when 'partialLink' # use XPath, cant use eq
                      "document.evaluate(\"//a[text()[contains(.,\'#{selector}')]]\" ,document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue"
                    when 'href'
                      "document.querySelectorAll(\"a[href=\'#{selector}\']\")"
                    when 'partialHref'
                      "document.querySelectorAll(\"a[href*=\'#{selector}\']\")"
                    when 'button' # use XPath, cant use eq
                      "document.evaluate(\"//button[text()[contains(.,\'#{selector}')]]\" ,document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue"
                    else # 'css'
                      "document.querySelectorAll('#{selector}')"
                  end

    begin # check if getElements array returns nil
      count = driver.execute_script("return #{js_selector}.length")
      if eq + 1 > count
        Result.create(test: test, webpage: driver.current_url,
                      runId: test.id, error: "There are only #{count} elements with selector #{selector}. Either eq=#{eq} is too high, or selector is invalid.")
        return 1
      end
    rescue Exception => error
      Result.create(test: test, webpage: driver.current_url,
                    runId: test.id, error: "Invalid selector #{selector}: #{error.message}")
      return 1
    end

    js_eq_selector = case type
                       when 'id', 'button', 'partialLink' # use XPath, cant use eq
                         js_selector
                       when 'partialHref'
                         "document.querySelectorAll(\"a[href*=\'#{selector}\']\")[#{eq}]"
                       else # 'css' 'class' 'tag' 'name' 'href'
                         "#{js_selector}[#{eq}]"
                     end

    begin # check if getElements array returns nil
      driver.execute_script("#{js_eq_selector}.click()")
    rescue Exception => error
      Result.create(test: test, webpage: driver.current_url,
                    runId: test.id, error: "Unavailable or Invisible selector #{translateClickSelector selector}: #{error.message}")
      return 1
    end

    return 0
  end

  def hash_video(run_id)
    Digest::MD5.hexdigest "videoCapture-#{run_id}"
  end

  def hash_data_secure_SEL_server(data)
    Digest::MD5.hexdigest "#{ENV['RDS_HOSTNAME']}-#{data}"
  end

  def video_aws_path(run_id)
    md5 = hash_video(run_id)
    "https://s3.amazonaws.com/#{ENV['bucket']}/#{md5}"
  end
end