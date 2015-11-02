#!/bin/sh
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y nodejs npm
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get install -y nodejs npm
fi
npm install -g bower grunt gulp mocha
