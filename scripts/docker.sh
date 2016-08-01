#!/bin/bash
# Install docker
DOCKER_VERSION=1.12.0

if [[ $BUILD_GUEST_OS =~ centos ]]; then
  cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
  yum install -y docker-engine-${DOCKER_VERSION}
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
  apt-get install -y apt-transport-https
  sleep 3; apt-get update -qq
  apt-get install -y -qq --force-yes docker-engine=${DOCKER_VERSION}\*
fi


# Add vagrant user to docker group
if [[ $BUILD_RUNTIME =~ vagrant ]]; then
  usermod -a -G docker vagrant
fi


# Enable docker
systemctl enable docker
systemctl start docker
