require 'selenium-webdriver'
require 'chromedriver-helper'
require 'headless'

headless = Headless.new
headless.start

caps = Selenium::WebDriver::Remote::Capabilities.chrome('desiredCapabilities' => {'takesScreenshot' => true}, 'chromeOptions' => {'binary' => '/chromium-browser'})

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-gpu')
options.add_argument('--remote-debugin-port=9222')
options.add_argument('--screen-size=1200x800')

driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps, options: options


driver = Selenium::WebDriver.for :chrome

driver.get "http://google.org"

driver.save_screenshot '/home/ubuntu/sc.png'

logs = driver.manage.logs.get('browser')
logs.each { |x| p x }