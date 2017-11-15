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

        when 'hit_enter' # merge all typed into 1 string
          step.update(action_type: 'hit_enter')
        when 'hit_tab' # merge all typed into 1 string
          step.update(action_type: 'hit_tab')
        when 'hit_caps' # merge all typed into 1 string
          step.update(action_type: 'hit_caps')
        when 'hit_backspace' # merge all typed into 1 string
          step.update(action_type: 'hit_backspace')

        when 'alert'
          step.update(action_type: 'alert')
        when 'click'
          # this can be a double click, need to check for time interval
          chunk = Draft.where("id < ?", next_id)
                        .where(session_id: session_id, action_type: 'click', x: first_event.x, y: first_event.y)

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

      # some actions dont come in chunks: hit enter, alert
      # instead, only 1 draft event present
      if chunk.present?
        chunk.destroy_all
      else
        first_event.destroy
      end
    end

    Draft.where(session_id: session_id).destroy_all
  end

  def get_comment(step)
    action = Step.web_step_types[step.action_type]

    case step.action_type
        when 'pageload'
          "#{action} #{step.webpage}, screen size = #{step.screenwidth} x #{step.screenheight}"
        when 'scroll'
          "#{action} to #{step.scrollLeft}px #{step.scrollTop}px"
        when 'click'
          "#{action} on #{translateClickSelector step.selector}"
        when 'keypress'
          "#{action} #{step.typed}"
        when 'hit_enter'
          'hit Enter'
        when 'hit_tab'
          'hit Tab'
        when 'hit_backspace'
          'hit BackSpace'
        when 'hit_caps'
          'hit Caps Lock'
        when 'resize'
          "#{action} to #{step.screenwidth} x #{step.screenheight}"
    end
  end

  def generate_assertion(file, assertion)
    condition = assertion.condition
    case current_user.language
      when 'ruby'
        file.puts "# #{Assertion.assertion_types[assertion.assertion_type]}: #{condition}"
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
