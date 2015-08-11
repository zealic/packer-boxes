#!/bin/sh
DOCKER_VERSION=1.7.1
curl -o /tmp/docker.rpm -sSL https://get.docker.com/rpm/$DOCKER_VERSION/centos-7/RPMS/x86_64/docker-engine-$DOCKER_VERSION-1.el7.centos.x86_64.rpm
yum localinstall -y --nogpgcheck /tmp/docker.rpm

# Docker configuration
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/docker.conf <<'EOF'
[Service]
EnvironmentFile=-/etc/default/docker
ExecStart=
ExecStart=/usr/bin/docker -d -H fd:// $DOCKER_OPTS
EOF
cat > /etc/default/docker <<'EOF'
DOCKER_OPTS="--registry-mirror=https://docker.mirrors.ustc.edu.cn"
EOF

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
