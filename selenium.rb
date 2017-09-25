#!/usr/bin/ruby

require 'selenium-webdriver'
require 'headless'

headless = Headless.new(video: {:frame_rate => 12, provider: :ffmpeg, :codec => 'h264'})
headless.start

caps = Selenium::WebDriver::Remote::Capabilities.chrome('chromeOptions' => {'binary' => '/usr/bin/chromium-browser'})

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--screen-size=1200x800')

driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps, options: options
driver.get "https://www.youtube.com/watch?v=TytGOeiW0aE"
headless.video.start_capture


headless.video.stop_and_save("/home/ubuntu/vid.mov")
driver.quit


client = Aws::S3::Client.new(region: 'us-east-1')
resource = Aws::S3::Resource.new(client: client)
bucket = resource.bucket('autotest-test')
bucket.object("vid.mov").upload_file('/home/ubuntu/vid.mov', acl:'public-read')



# logs = driver.manage.logs.get('browser')
# logs.each { |x| p x }

# export Elastic Beanstalk ENV to a file
file = "#{ENV['HOME']}/export.sh"
File.write(
    file,
    [
        "#!/bin/sh",
        "\n",
        "export bucket=#{ENV['bucket']}",
        "export GOOGLE_ID=#{ENV['GOOGLE_ID']}",
        "export RDS_HOSTNAME=#{ENV['RDS_HOSTNAME']}",
        "export RDS_DB_NAME=#{ENV['RDS_DB_NAME']}",
        "export RDS_PASSWORD=#{ENV['RDS_PASSWORD']}",
        "export RDS_USERNAME=#{ENV['RDS_USERNAME']}",
        "export GOOGLE_SECRET=#{ENV['GOOGLE_SECRET']}",
        "export RDS_PORT=#{ENV['RDS_PORT']}",
        "export mediaDir=media"
    ].join("\n")
)











