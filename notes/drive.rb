require "selenium-webdriver"

Selenium::WebDriver::Chrome.driver_path = '/home/thao/Documents/chromedriver'
driver = Selenium::WebDriver.for :chrome
driver.get 'http://dev.rumie.org/app_dev.php/search'


driver.title
