#!/bin/bash
BASE_VERSION=4.x

if [[ $BUILD_GUEST_OS =~ centos ]]; then
  curl -sL https://rpm.nodesource.com/setup_$BASE_VERSION | bash -
  yum install -y nodejs
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  curl -sL https://deb.nodesource.com/setup_$BASE_VERSION | bash -
  apt-get install -y -qq nodejs
fi
