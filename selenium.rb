require 'selenium-webdriver'
require 'chromedriver-helper'
require 'headless'

headless = Headless.new
headless.start
driver = Selenium::WebDriver.for :firefox # :chrome

driver.get "http://rumie.org"

logs = driver.manage.logs.get('browser')
logs.each { |x| p x }