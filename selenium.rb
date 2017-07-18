require 'rubygems'
require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome
driver.get "http://rumie.org"

logs = driver.manage.logs.get('browser')
logs.each { |x| p x }