#!/bin/sh
yum install -y docker
systemctl enable docker
systemctl start docker
curl -sSL -o /usr/bin/weave https://github.com/weaveworks/weave/releases/download/v0.11.1/weave
chmod a+x /usr/bin/weave
weave setup

PACKAGES=(
  busybox
  haproxy
  mongo
  nginx
  postgres
  redis
  microbox/etcd
)

for pkg in ${PACKAGES[@]}
do
  docker pull $pkg
done


# Set mirror
sed -i 's|OPTIONS=|OPTIONS=--registry-mirror=https://docker.mirrors.ustc.edu.cn |g' /etc/sysconfig/docker

