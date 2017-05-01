module StepHelper
  def translateClickSelector (selector)
    selector[:selectorType] ||= selector['selectorType']

    case selector[:selectorType]
      when 'href'
        "#{(selector[:eq] ||= 1).ordinalize} link tag <a> with url #{selector[:selector]}"
      when 'button'
        "#{(selector[:eq] ||= 1).ordinalize} button with text containing #{selector[:selector]}"
      when 'id'
        "element with ID #{selector[:selector]}"
      when 'css'
        "#{(selector[:eq] ||= 1).ordinalize} element with CSS Selector #{selector[:selector]}"
      when 'tag'
        "#{(selector[:eq] ||= 1).ordinalize} element with tag <#{selector[:selector].upcase}>"
      else
        0
    end
  end
end
