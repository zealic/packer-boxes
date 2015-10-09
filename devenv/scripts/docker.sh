#!/bin/sh
# Install docker
DOCKER_VERSION=1.8.2
curl -o /tmp/docker.rpm -sSL http://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-$DOCKER_VERSION-1.el7.centos.x86_64.rpm
yum localinstall -y --nogpgcheck /tmp/docker.rpm

# Add vagrant user to docker group
getent passwd vagrant >/dev/null 2>&1 && ret=true
if $ret; then
  usermod vagrant -a -G docker vagrant
fi

# Enable docker
systemctl enable docker
systemctl start docker
