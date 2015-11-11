#!/bin/bash
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y python python-devel python-pip
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get install -y -qq python python-dev python-pip
fi
