#!/bin/sh
yum install -y ruby
gem install rake bundler
gem sources --remove https://rubygems.org/
gem sources -a https://ruby.taobao.org/
