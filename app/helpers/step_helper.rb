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

  def generate_step(file, step)
    return unless step.complete?

    comment = "Step #{step.order}: #{escape_javascript get_comment(step)}"
    case current_user.language
      when 'ruby'
        file.puts "\n# #{comment}"

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
        file.puts "\n/* #{comment} */"

        case step.action_type
          when 'pageload'
            file.puts "driver.get('#{escape_javascript step.webpage}');"
          when 'scroll'
            file.puts "driver.executeScript('scroll(#{step.scrollLeft}, #{step.scrollTop})');"
          when 'keypress'
            file.puts "driver.action().sendKeys('#{escape_javascript step.typed}').perform();"
          when 'resize'
            file.puts "driver.manage().window.setSize(new Dimension(#{step.screenwidth}, #{step.screenheight}));"
          when 'click'
            type = step.selector[:selectorType]
            selector = escape_javascript step.selector[:selector].strip
            eq = step.selector[:eq].to_i
            case type # first, find DOM with WebDriver
              when 'id'
                file.puts "driver.findElement(By.id('#{selector}'));"
              when 'class'
                if selector.include? ' '
                  selector = ".#{selector.split.join('.')}"
                  file.puts "driver.findElements(By.cssSelector('#{selector}'))[#{eq}];"
                else # 1 single class
                  file.puts "driver.findElements(By.className('#{selector}'))[#{eq}];"
                end
              when 'tag'
                file.puts "driver.findElements(By.tagName('#{selector}'))[#{eq}];"
              when 'name'
                file.puts "driver.findElements(By.name => '#{selector}')[#{eq}];"
              when 'partialLink' # link text
                file.puts "driver.findElements(By.partialLinkText('#{selector}'))[#{eq}];"
              when 'href'
                file.puts "driver.findElements(By.cssSelector(\"a[href='#{selector}']\"))[#{eq}];"
              when 'partialHref'
                file.puts "driver.findElements(By.cssSelector(\"a[href*='#{selector}']\"))[#{eq}];"
              when 'button' # use XPath
                file.puts "driver.findElements(By.:xpath, \"//button[text()[contains(.,'#{selector}')]]\")[#{eq}]"
              when 'css'
                if eq > 0
                  file.puts "driver.findElements(By.cssSelector('#{selector}'))[#{eq}];"
                else
                  file.puts "driver.findElement(By.cssSelector('#{selector}'));"
                end
              when 'coordination'
                file.puts "elem = driver.find_elements(By.tagName('body'))[0];"
                file.puts "driver.action().moveToElement(elem, #{step.selector[:x]}, #{step.selector[:y]}).click().perform();"
              else
                nil
            end
          else
            true
        end
      when 'python'
      when 'javascript'
        file.puts "\n// #{comment}"

        case step.action_type
          when 'pageload'
            file.puts "driver.get ('#{escape_javascript step.webpage}');"
          when 'scroll'
            file.puts "driver.executeScript('scroll(#{step.scrollLeft}, #{step.scrollTop})');"
          when 'keypress'
            file.puts "driver.action().sendKeys('#{escape_javascript step.typed}').perform();"
          when 'resize'
            file.puts "driver.manage().window().setSize(new Dimension(#{step.screenwidth}, #{step.screenheight});"
          when 'click'
            type = step.selector[:selectorType]
            selector = escape_javascript step.selector[:selector].strip
            eq = step.selector[:eq].to_i
            case type # first, find DOM with WebDriver
              when 'id'
                file.puts "driver.findElement(By.id('#{selector}'));"
              when 'class'
                if selector.include? ' '
                  selector = ".#{selector.split.join('.')}"
                  file.puts "driver.findElements(By.css('#{selector}'))[#{eq}];"
                else # 1 single class
                  file.puts "driver.findElements(By.className('#{selector}'))[#{eq}];"
                end
              when 'tag'
                file.puts "driver.findElements(By.tagName('#{selector}'))[#{eq}];"
              when 'name'
                file.puts "driver.findElements(By.name('#{selector}'))[#{eq}];"
              when 'partialLink' # link text
                file.puts "driver.findElements(By.partialLinkText('#{selector}'))[#{eq}];"
              when 'href'
                file.puts "driver.findElements(By.css(\"a[href='#{selector}']\"))[#{eq}];"
              when 'partialHref'
                file.puts "driver.findElements((By.css(\"a[href*='#{selector}']\"))[#{eq}];"
              when 'button' # use XPath
                file.puts "driver.findElements((By.xpath('\"//button[text()[contains(.,'#{selector}')]]\"))[#{eq}];"
              when 'css'
                if eq > 0
                  file.puts "driver.findElements(By.css('#{selector}'))[#{eq}];"
                else
                  file.puts "driver.findElement(By.css('#{selector}'));"
                end
              when 'coordination'
                file.puts "elem = driver.find_elements(By.tagName('body'))[0];"
                file.puts "driver.action().moveToElement(elem, #{step.selector[:x]}, #{step.selector[:y]}).click().perform();"
              else
                nil
            end
          else
            true
        end
      else
        true
    end
  end

  def generate_boilerplate(test, file, language = current_user.language)
    title = "Generated by UIChecks.com
Test title: #{test.title}
Language: #{language.capitalize}"

    case language
      when 'ruby'
        file.puts "=begin
#{title}\n=end\n"
        file.puts "require 'selenium-webdriver'
driver = Selenium::WebDriver.for :chrome\n\n"
      when 'java'
        file.puts "/*
#{title}
*/\n"
        file.puts "import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.WebDriverWait;

public class AutoTesting {
  public static void main(String[] args) {
    System.setProperty(\"webdriver.chrome.driver\", \"/Path/chromedriver\");
    WebDriver driver = new ChromeDriver();\n\n"
      when 'javascript'
      else
        true
    end
  end

  def generate_ending_boilerplate(test, file, language = current_user.language)
    case language
      when 'java'
        file.puts ' }
}'
      when 'c#'
      else
        true
    end
  end
end
