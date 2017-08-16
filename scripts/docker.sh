#!/bin/bash
# Install docker
DOCKER_VERSION=17.06
DOCKER_COMPOSE_VERSION=1.14.0

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
  apt-get install -y apt-transport-https software-properties-common gnupg2
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"
  sleep 1; apt-get update -qq
  apt-get install -y -qq --force-yes docker-ce=${DOCKER_VERSION}\*
fi

# docker-compose
curl -sSL https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


# Add vagrant user to docker group
if [[ $BUILD_RUNTIME =~ vagrant ]]; then
  usermod -a -G docker vagrant
fi


# Enable docker
systemctl enable docker
systemctl start docker
