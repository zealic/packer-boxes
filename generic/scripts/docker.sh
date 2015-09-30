#!/bin/sh
# Install docker
DOCKER_VERSION=1.8.2
curl -o /tmp/docker.rpm -sSL http://yum.dockerproject.org/repo/main/centos/7/Packages/docker-engine-$DOCKER_VERSION-1.el7.centos.x86_64.rpm
yum localinstall -y --nogpgcheck /tmp/docker.rpm

# Enable docker
systemctl enable docker
systemctl start docker
