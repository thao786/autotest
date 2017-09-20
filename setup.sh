#!/bin/bash

# connect to instance:
ssh -i "ec2.pem" ubuntu@ec2-34-213-223-51.us-west-2.compute.amazonaws.com



gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --ruby
rvm default
\curl -sSL https://get.rvm.io | bash -s stable --rails




wget https://chromedriver.storage.googleapis.com/2.32/chromedriver_linux64.zip
sudo apt update
sudo apt install unzip
unzip chromedriver_linux64.zip
./chromedriver

sudo apt install chromium-browser
sudo apt-get install libgconf-2-4


sudo apt-get install nodejs
sudo apt-get install libmysqlclient-dev
sudo apt-get install xvfb
sudo apt-get install ffmpeg
sudo apt-get install imagemagick

git clone https://github.com/thao786/autotest.git
bundle install

cd /home/ubuntu/autotest
sudo apt install awscli
aws configure









scp -i ec2.pem ubuntu@ec2-54-201-188-160.us-west-2.compute.amazonaws.com:~/vid.mov ~/vid.mov