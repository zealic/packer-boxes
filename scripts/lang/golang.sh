#!/bin/bash
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y git subversion
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get install -y -qq git subversion bison
fi

GO_VERSION=1.6
curl -sSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | \
  bash /dev/stdin master /usr/local
cat > /etc/profile.d/gvm.sh <<EOF
source /usr/local/gvm/scripts/gvm
gvm use go$GO_VERSION
EOF
chmod +x /etc/profile.d/gvm.sh
source /usr/local/gvm/scripts/gvm

gvm install go$GO_VERSION -B
gvm use go$GO_VERSION
