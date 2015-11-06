#!/bin/bash
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y python python-devel python-pip
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get install -y -qq python python-dev python-pip
fi

if [[ $BUILD_REGION =~ cn ]]; then
  mkdir -p /root/.pip
  cat > /root/.pip/pip.conf <<"EOF"
[global]
index-url = https://pypi.mirrors.ustc.edu.cn/simple
EOF

  if [[ $BUILD_FORMAT =~ vagrant ]]; then
    mkdir -p /home/vagrant/.pip
    cp /root/.pip/pip.conf /home/vagrant/.pip/pip.conf
    chown -R vagrant:vagrant /home/vagrant/.pip
  fi
fi
