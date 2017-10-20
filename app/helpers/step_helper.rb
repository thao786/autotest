module StepHelper
  def translateClickSelector (selector)
    begin
      eq = selector[:eq].to_i ||= 1

      case selector[:selectorType]
        when 'href'
          "<a href=#{selector[:selector]}>, index #{eq}"
        when 'partialHref'
          "<a> in which href containing #{selector[:selector]}, index #{eq}"
        when 'button'
          "BUTTON that says '#{selector[:selector]}', index #{eq}"
        when 'id'
          "##{selector[:selector]}"
        when 'css'
          "element with CSS Selector #{selector[:selector]}, index #{eq}"
        when 'tag'
          "<#{selector[:selector].upcase}>, index #{eq}"
        when 'name'
          "input with name=#{selector[:selector]}, index #{eq}"
        when 'class'
          "element with class=#{selector[:selector]}, index #{eq}"
        when 'tag'
          "<#{selector[:selector].upcase}>, index #{eq}"
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
