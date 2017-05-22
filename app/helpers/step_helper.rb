module StepHelper
  def translateClickSelector (selector)
    selector[:selectorType] ||= selector['selectorType']
    eq = selector[:eq] ||= 1
    eq = 1 if eq == 0

    case selector[:selectorType]
      when 'href'
        "#{eq.ordinalize} <a href=#{selector[:selector]}>"
      when 'button'
        "#{eq.ordinalize} button with text containing #{selector[:selector]}"
      when 'id'
        "##{selector[:selector]}"
      when 'css'
        "#{eq.ordinalize} element with CSS Selector #{selector[:selector]}"
      when 'tag'
        "#{eq.ordinalize} <#{selector[:selector].upcase}>"
      when 'coordination'
        "coordination [#{selector[:x]}, #{selector[:y]}]"
      else
        0
    end
  end
end
