module TestsHelper
  MAX_ID = 9999999

  def showUrl (test)
    "/test/#{test.name}/#{test.id}"
  end

  def testCount
    Test.where(suite: Suite.where(current_user.suites)).count
  end

  def JQfyClasses(class_group) # turn "class1 class2" into ".class1.class2"
    array = class_group.split.map { |single_class| ".#{single_class}" }
    array.join
  end

  def score (selector) # the higher the score, the higher its priority
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
    start_time = Draft.where(session_id: session_id).minimum(:stamp)
    test = Test.where(session_id: session_id).first
    order = Step.where(test: test).maximum(:order)
    order ||= 0

    while Draft.where(session_id: session_id).count > 0
      first_event = Draft.where(session_id: session_id).first
      order = order + 1
      step = Step.create(wait: first_event.stamp - start_time, webpage: first_event.webpage,
                         order: order, test: test, device_type: 'browser', active: true,
                         tabId: first_event.tabId, windowId: first_event.windowId,
                         action_type: first_event.action_type,
                         screenwidth: first_event.screenwidth, screenheight: first_event.screenheight)
      Extract.create(title: "body_text#{step.id}", step: step,
                     command: 'document.getElementsByTagName("body")[0].textContent')
      chunk = nil
      case first_event.action_type
        when 'pageload' # not sure what to do
          first_event.destroy!
        when 'resize'
          first_event.destroy!
        when 'scroll' # merge homogeneously increasing scrollTop or scrollLeft into 1 step
          # for now, just pick the last position
          # find the chunk of scroll events
          # the last scroll event should be follow by a different action_type
          next_event = Draft.where.not(action_type: 'scroll')
                           .where(session_id: session_id).first
          next_id = next_event.nil? ? MAX_ID : next_event.id
          chunk = Draft.where("id < ?", next_id)
                             .where(session_id: session_id, action_type: 'scroll')
          last_scroll = chunk.last
          step.update(scrollTop: last_scroll.scrollTop, scrollLeft: last_scroll.scrollLeft)
        when 'keypress' # merge all typed into 1 string
          # similar to scroll
          next_event = Draft.where.not(action_type: 'keypress')
                              .where(session_id: session_id).first
          next_id = next_event.nil? ? MAX_ID : next_event.id
          chunk = Draft.where("id < ?", next_id).where(session_id: session_id, action_type: 'keypress')

          # compress into 1 string
          typed = chunk.inject('') { |str, draft|
            "#{str}#{draft.typed}"
          }
          step.update(typed: typed)
        when 'click' # use x,y coordination to find same clicks
          next_event = Draft.where.not(x: first_event.x, y: first_event.y)
                           .where(session_id: session_id).first
          # this can be a double click, need to check for time interval
          next_id = next_event.nil? ? MAX_ID : next_event.id
          chunk = Draft.where("id < ?", next_id)
                        .where(session_id: session_id, action_type: 'click')

          # sort selectors in order: href, button, id, class, tag
          selectors = chunk.collect {|click| click.selector }.uniq.compact
               .reject { |c| c.empty? }.sort! { |x,y| score(x) <=> score(y)}
               .reverse
          step.update(config: {selectors: selectors, x: first_event.x, y: first_event.y},
                  selector: selectors.first.to_json)
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
