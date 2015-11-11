#!/bin/bash
cat > /etc/environment <<"EOF"
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF


# Packages
PACKAGES=(
  ca-certificates
  build-essential
  axel
  curl
  mtr
  nmap
  telnet
  tmux
  vim
  wget
)

if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y epel-release
  yum update -y
  yum install -y ${PACKAGES[@]}
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get update -qq
  apt-get install -y -qq ${PACKAGES[@]}
fi
