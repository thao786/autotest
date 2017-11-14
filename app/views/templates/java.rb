def generate_step(step)
  return unless step.complete?

  comment = "\n/* Step #{step.order}: #{helpers.escape_javascript helpers.get_comment(step)} */"

  command = case step.action_type
    when 'pageload'
      "driver.get('#{helpers.escape_javascript step.webpage}');"
    when 'scroll'
      "driver.executeScript('scroll(#{step.scrollLeft}, #{step.scrollTop})');"
    when 'keypress'
      "driver.action().sendKeys('#{helpers.escape_javascript step.typed}').perform();"
    when 'resize'
      "driver.manage().window.setSize(new Dimension(#{step.screenwidth}, #{step.screenheight}));"
    when 'click'
      type = step.selector[:selectorType]
      selector = helpers.escape_javascript step.selector[:selector].strip
      eq = step.selector[:eq].to_i
      case type # first, find DOM with WebDriver
        when 'id'
          "driver.findElement(By.id('#{selector}'));"
        when 'class'
          if selector.include? ' '
            selector = ".#{selector.split.join('.')}"
            "driver.findElements(By.cssSelector('#{selector}'))[#{eq}];"
          else # 1 single class
            "driver.findElements(By.className('#{selector}'))[#{eq}];"
          end
        when 'tag'
          "driver.findElements(By.tagName('#{selector}'))[#{eq}];"
        when 'name'
          "driver.findElements(By.name => '#{selector}')[#{eq}];"
        when 'partialLink' # link text
          "driver.findElements(By.partialLinkText('#{selector}'))[#{eq}];"
        when 'href'
          "driver.findElements(By.cssSelector(\"a[href='#{selector}']\"))[#{eq}];"
        when 'partialHref'
          "driver.findElements(By.cssSelector(\"a[href*='#{selector}']\"))[#{eq}];"
        when 'button' # use XPath
          "driver.findElements(By.:xpath, \"//button[contains(.,'#{selector}')]\")[#{eq}]"
        when 'css'
          if eq > 0
            "driver.findElements(By.cssSelector('#{selector}'))[#{eq}];"
          else
            "driver.findElement(By.cssSelector('#{selector}'));"
          end
        when 'coordination'
          "elem = driver.find_elements(By.tagName('body'))[0];"
          "driver.action().moveToElement(elem, #{step.selector[:x]}, #{step.selector[:y]}).click().perform();"
        else
          nil
      end
    else
      true
    end

  "#{comment}\n   #{command}"
end

def get_test_code(test)
  test.steps.inject('') { |code_so_far, step|
    cmd = generate_step(step)
    "#{code_so_far}\n
    #{cmd}"
  }
end

first_step = Step.where(test: test).first
resize_cmd = "driver.manage.window.resize_to(#{first_step.screenwidth}, #{first_step.screenheight})" if first_step.screenwidth

pre_tests_code = if @test.suite.prep_tests.count > 0
                   code = @test.suite.prep_tests.inject('') { |code_so_far, sub_test|
                     test_code = get_test_code(sub_test)
                     "#{code_so_far}\n\n#{test_code}"
                   }
                   "/* suite's pre-tests\n\n#{code} */"
                 end

code = get_test_code(test)

"/*
  Generated by UIChecks.com
  Test title: #{test.title}
  Language: #{lang.capitalize}
*/

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.WebDriverWait;

public class AutoTesting {
  public static void main(String[] args) {
    System.setProperty(\"webdriver.chrome.driver\", \"/Path/chromedriver\");
    WebDriver driver = new ChromeDriver();

    #{resize_cmd}
    #{pre_tests_code}
    #{code}

    driver.quit();
  }
}"