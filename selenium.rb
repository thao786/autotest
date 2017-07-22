require 'selenium-webdriver'

headless = Headless.new
headless.start
driver = Selenium::WebDriver.for :chrome
driver.get "http://rumie.org"

logs = driver.manage.logs.get('browser')
logs.each { |x| p x }