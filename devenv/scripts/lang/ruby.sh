#!/bin/sh
gem sources --remove https://rubygems.org/
gem sources -a https://ruby.taobao.org/
yum install -y ruby ruby-devel
gem install rake bundler
