module StepHelper
  def translateClickSelector (selector)
    selector[:selectorType] ||= selector['selectorType']

    case selector[:selectorType]
      when 'href'
        "#{(selector[:eq] ||= 1).ordinalize} <a href=#{selector[:selector]}>"
      when 'button'
        "#{(selector[:eq] ||= 1).ordinalize} button with text containing #{selector[:selector]}"
      when 'id'
        "##{selector[:selector]}"
      when 'css'
        "#{(selector[:eq] ||= 1).ordinalize} element with CSS Selector #{selector[:selector]}"
      when 'tag'
        "#{(selector[:eq] ||= 1).ordinalize} <#{selector[:selector].upcase}>"
      else
        0
    end
  end
end
