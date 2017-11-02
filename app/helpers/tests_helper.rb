module TestsHelper
  def showUrl (test)
    "/test/#{test.name}/#{test.id}"
  end

  def testCount
    Test.where(suite: current_user.suites).count
  end

  def JQfyClasses(class_group) # turn "class1 class2" into ".class1.class2"
    array = class_group.split.map { |single_class| ".#{single_class}" }
    array.join
  end

  def score(selector) # the higher the score, the higher its priority
    # select based on children count. the fewer children the higher score
    case selector[:selectorType]
      when 'href'
        100000
      when 'button'
        90001
      when 'id' # maybe only prioritize elements with less than 3 children
        80000 + (10000 - selector[:childrenCount] * 3000)
      when 'class'
        65000 + (10000 - selector[:childrenCount])
      when 'css'
        60000 + (10000 - selector[:childrenCount])
      when 'tag' # prioritize inline elements like img,span, h1
        500
      else
        0
    end
  end

  def parseDraft(session_id)
    test = Test.where(session_id: session_id).first
    order = Step.where(test: test).maximum(:order)
    order ||= 0

    while Draft.where(session_id: session_id).count > 0
      first_event = Draft.where(session_id: session_id).order(:stamp).first

      next_event = if first_event.action_type == 'click'
                      # use x,y coordination to find same clicks
                      Draft.where.not(x: first_event.x, y: first_event.y)
                           .where(session_id: session_id).order(:stamp).first
                  else
                      Draft.where.not(action_type: first_event.action_type)
                           .where(session_id: session_id).order(:stamp).first
                  end
      next_id = next_event.nil? ? 9999999 : next_event.id
      next_stamp = next_event.nil? ? DateTime.now.strftime('%Q').to_i : next_event.stamp
      order = order + 1
      step = Step.create(wait: next_stamp - first_event.stamp,
           order: order, test: test, device_type: 'browser',
           tabId: first_event.tabId, windowId: first_event.windowId,
           action_type: first_event.action_type, webpage: first_event.webpage,
           screenwidth: first_event.screenwidth, screenheight: first_event.screenheight)
      chunk = nil

      case first_event.action_type
        when 'pageload' # not sure what to do
          first_event.destroy!
        when 'resize'
          chunk = Draft.where("id < ?", next_id)
                      .where(session_id: session_id, action_type: 'resize')
          last_resize = chunk.last
          step.update(screenwidth: last_resize.screenwidth, screenheight: last_resize.screenheight)
          first_event.destroy!
        when 'scroll' # merge homogeneously increasing scrollTop or scrollLeft into 1 step
          # for now, just pick the last position
          # find the chunk of scroll events
          # the last scroll event should be follow by a different action_type
          chunk = Draft.where("id < ?", next_id)
                             .where(session_id: session_id, action_type: 'scroll')
          last_scroll = chunk.last
          step.update(scrollTop: last_scroll.scrollTop.to_s, scrollLeft: last_scroll.scrollLeft.to_s)
        when 'keypress' # merge all typed into 1 string
          chunk = Draft.where("id < ?", next_id)
                      .where(session_id: session_id, action_type: 'keypress')

          # compress into 1 string
          typed = chunk.inject('') { |str, draft|
            "#{str}#{draft.typed}"
          }
          step.update(typed: typed)
        when 'click'
          # this can be a double click, need to check for time interval
          chunk = Draft.where("id < ?", next_id)
                        .where(session_id: session_id, action_type: 'click')

          # sort selectors in order: href, button, id, class, tag
          selectors = chunk.collect { |click| click.selector }.uniq.compact
               .reject { |c| c.empty? }
               .sort! { |x,y| score(x) <=> score(y)}
               .reverse
          # if click on href, set eq=0
          step.update(config: {selectors: selectors, x: first_event.x, y: first_event.y},
                  selector: selectors.first)
        else
            order = order - 1
      end

      if chunk.present?
        chunk.destroy_all
      end
    end

    Draft.where(session_id: session_id).destroy_all
  end

  def generate_step(file, step)
    return unless step.complete?

    case current_user.language
      when 'ruby'
          # write comments
          file.puts "\n# Step #{step.order}: #{Step.web_step_types[step.action_type]}, #{step.webpage}"

          case step.action_type
            when 'pageload'
              file.puts "driver.get '#{escape_javascript step.webpage}'"
            when 'scroll'
              file.puts "driver.execute_script 'scroll(#{step.scrollLeft}, #{step.scrollTop})'"
            when 'keypress'
              file.puts "driver.action.send_keys('#{escape_javascript step.typed}').perform"
            when 'resize'
              file.puts "driver.manage.window.resize_to(#{step.screenwidth}, #{step.screenheight})"
            when 'click'
              type = step.selector[:selectorType]
              selector = escape_javascript step.selector[:selector].strip
              eq = step.selector[:eq].to_i
              case type # first, find DOM with WebDriver
                  when 'id'
                    file.puts "driver.find_element(:id, '#{selector}')"
                  when 'class'
                    if selector.include? ' '
                      selector = ".#{selector.split.join('.')}"
                      file.puts "driver.find_elements(:css => '#{selector}')[#{eq}]"
                    else # 1 single class
                      file.puts "driver.find_elements(:class => '#{selector}')[#{eq}]"
                    end
                  when 'tag'
                    file.puts "driver.find_elements(:tag_name => '#{selector}')[#{eq}]"
                  when 'name'
                    file.puts "driver.find_elements(:name => '#{selector}')[#{eq}]"
                  when 'partialLink' # link text
                    file.puts "driver.find_elements(:partial_link_text => '#{selector}')[#{eq}]"
                  when 'href'
                    file.puts "driver.find_elements(:css => \"a[href='#{selector}']\")[#{eq}]"
                  when 'partialHref'
                    file.puts "driver.find_elements(:css => \"a[href*='#{selector}']\")[#{eq}]"
                  when 'button' # use XPath
                    file.puts "driver.find_elements(:xpath, \"//button[text()[contains(.,'#{selector}')]]\")[#{eq}]"
                  when 'css'
                    if eq > 0
                      file.puts "driver.find_elements(:css => '#{selector}')[#{eq}]"
                    else
                      file.puts "driver.find_element(:css, '#{selector}')"
                    end
                  when 'coordination'
                    file.puts "elem = driver.find_elements(:tag_name => 'body').first"
                    file.puts "driver.action.move_to(elem, #{step.selector[:x]}, #{step.selector[:y]}).click.perform"
                  else
                    nil
              end
            else
              true
          end
      when 'java'
      when 'python'
      when 'javascript'
      else
        true
    end
  end

  def generate_assertion(file, assertion)
    condition = assertion.condition
    case current_user.language
      when 'ruby'
        file.puts "\n# #{Assertion.assertion_types[assertion.assertion_type]}: #{condition}"
        file.puts "condition = '#{escape_javascript condition}'"

        case assertion.assertion_type
           when 'text-in-page'
             file.puts "text = driver.execute_script 'return document.body.textContent'"
             file.puts 'puts "#{text.include? condition}"'
           when 'html-in-page'
             file.puts "source = driver.execute_script 'return document.documentElement.outerHTML'"
             file.puts 'puts "#{source.include? condition}"'
           when 'page-title'
             file.puts "passed = driver.execute_script('return document.title').include? condition"
             file.puts 'puts "assertion: #{passed}"'
          else # self-enter JS command
            file.puts "driver.execute_script \"return \#{condition}\""
        end
      when 'java'
      when 'python'
      when 'javascript'
      else
        true
    end
  end
end
