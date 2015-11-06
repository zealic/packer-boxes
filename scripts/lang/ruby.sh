#!/bin/bash
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y ruby ruby-devel
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get install -y -qq ruby ruby-dev
fi

if [[ $BUILD_REGION =~ cn ]]; then
  gem sources --remove https://rubygems.org/
  gem sources -a https://ruby.taobao.org/
fi
gem install rake bundler
