module StepHelper
  def translateClickSelector (selector)
    begin
    eq = selector[:eq].to_i ||= 1

      case selector[:selectorType]
        when 'href'
          "#{eq.ordinalize} <a href=#{selector[:selector]}>"
        when 'partialHref'
          "#{eq.ordinalize} <a> in which href containing #{selector[:selector]}"
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
    rescue
      'Undefined Selector'
    end
  end
end
