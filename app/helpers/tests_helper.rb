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
        80000 + (10000 - selector[:childrenCount].to_i * 3000)
      when 'css'
        60000 + (10000 - selector[:childrenCount].to_i)
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

    Draft.destroy_all(session_id: session_id)
  end
end
