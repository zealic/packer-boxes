#!/bin/sh
DOCKER_VERSION=1.8.0
curl -o /tmp/docker.rpm -sSL http://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-$DOCKER_VERSION-1.el7.centos.x86_64.rpm
yum localinstall -y --nogpgcheck /tmp/docker.rpm

# Enable docker
systemctl enable docker
systemctl start docker

# Install docker
WEAVE_VERSION=1.0.1
curl -sSL -o /usr/bin/weave https://github.com/weaveworks/weave/releases/download/v$WEAVE_VERSION/weave
chmod a+x /usr/bin/weave
weave setup

# Install docker images
PACKAGES=(
  busybox
  haproxy
  mongo
  nginx
  postgres
  redis

  # Langugages
  node
  python:2.7
  python:latest
  ruby
)

for pkg in ${PACKAGES[@]}
do
  docker pull $pkg
done
