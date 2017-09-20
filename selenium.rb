#!/usr/bin/ruby

require 'selenium-webdriver'
require 'headless'

headless = Headless.new(video: { provider: :ffmpeg })
headless.start

caps = Selenium::WebDriver::Remote::Capabilities.chrome('desiredCapabilities' => {'takesScreenshot' => true}, 'chromeOptions' => {'binary' => '/usr/bin/chromium-browser'})

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--screen-size=1200x800')

driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps, options: options
headless.video.start_capture
driver.get "https://www.youtube.com/watch?v=TytGOeiW0aE"


driver.quit
headless.video.stop_and_save("/home/ubuntu/vid.mov")


client = Aws::S3::Client.new(region: 'us-east-1')
resource = Aws::S3::Resource.new(client: client)
bucket = resource.bucket('autotest-test')
bucket.object("vid.mov").upload_file('/home/ubuntu/vid.mov', acl:'public-read')



# logs = driver.manage.logs.get('browser')
# logs.each { |x| p x }