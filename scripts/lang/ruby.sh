#!/bin/sh
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y ruby ruby-devel
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get install -y ruby ruby-dev
fi
gem sources --remove https://rubygems.org/
gem sources -a https://ruby.taobao.org/
gem install rake bundler
