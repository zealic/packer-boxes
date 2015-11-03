#!/bin/bash
# Install docker
DOCKER_VERSION=1.8.3

if [[ $BUILD_GUEST_OS =~ centos ]]; then
  curl -o /tmp/docker.rpm -sSL http://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-$DOCKER_VERSION-1.el7.centos.x86_64.rpm
  yum localinstall -y --nogpgcheck /tmp/docker.rpm
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
  apt-get install -y apt-transport-https
  sleep 3; apt-get update -qq
  apt-get install -y -qq docker-engine
fi


# Add vagrant user to docker group
if [[ $BUILD_FORMAT =~ vagrant ]]; then
  usermod -a -G docker vagrant
fi


# Enable docker
systemctl enable docker
systemctl start docker
