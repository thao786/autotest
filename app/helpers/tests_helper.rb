module TestsHelper
  MAX_ID = 9999999

  def showUrl (test)
    "/test/#{test.name}/#{test.id}"
  end

  def JQfyClasses(class_group) # turn "class1 class2" into ".class1.class2"
    array = class_group.split.map { |single_class| ".#{single_class}" }
    array.join
  end

  def score(selector)
    if selector.index('a[href=') and selector.index('a[href=') == 0
      -1000
    elsif selector.index('button:contains(') and selector.index('button:contains(') == 0
      -500
    elsif selector.index('#') and selector.index('#') == 0
      -300
    elsif selector.index('.') and selector.index('.') == 0
      -200
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
      chrome_tab = first_event.chrome_tab
      step = Step.create(wait: first_event.stamp - start_time, webpage: first_event.webpage,
                         order: order, test: test, device_type: 'browser', active: true,
                         chrome_tab: chrome_tab, action_type: first_event.action_type)
      chunk = nil
      case first_event.action_type
        when 'pageload'
          # is this a link click or user load page in browser (this chrome-tab has existed before in this session)
          if Step.where(chrome_tab: chrome_tab).count > 1
            step.destroy
          else
            step.update(webpage: first_event.webpage)
          end
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
          step.update(scrollTop: last_scroll.scrollTop,
                      scrollLeft: last_scroll.scrollLeft)
        when 'keypress' # merge all typed into 1 string
          # similar to scroll
          next_event = Draft.where.not(action_type: 'keypress')
                              .where(session_id: session_id).first
          next_id = next_event.nil? ? MAX_ID : next_event.id
          chunk = Draft.where("id < ?", next_id).where(session_id: session_id, action_type: 'keypress')

          # compress into 1 string
          str = chunk.inject { |str, draft|
            str + draft.typed
          }
          step.update(typed: str)
        when 'click' # use x,y coordination to find same clicks
          next_event = Draft.where.not(x: first_event.x, y: first_event.y)
                           .where(session_id: session_id).first
          # this can be a double click, need to check for time interval
          next_id = next_event.nil? ? MAX_ID : next_event.id
          chunk = Draft.where("id < ?", next_id)
                        .where(session_id: session_id, action_type: 'click')

          # sort selectors in order: href, button, id, class, tag
          selectors = chunk.collect {|click| click.selector }.uniq.compact.reject { |c| c.empty? }
               .sort! { |x,y| score(x) <=> score(y)}
          step.update(config: {selectors: selectors, x: first_event.x, y: first_event.y},
                  selector: selectors.first)
        else
            order = order - 1
      end

      if chunk.present?
        chunk.destroy_all
      end
    end
  end
end
