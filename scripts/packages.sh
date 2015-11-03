#!/bin/bash
cat > /etc/environment <<EOF
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
  ###########################################################
  # Setup mirror on chinese
  sed -i 's|enabled=1|enabled=0|g' /etc/yum/pluginconf.d/fastestmirror.conf

  # Setup yum
  sed -i 's|#baseurl=http://mirror.centos.org|baseurl=https://mirrors.ustc.edu.cn|g' /etc/yum.repos.d/CentOS-Base.repo
  sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-Base.repo

  # Setup EPEL
  yum install -y epel-release
  sed -i 's|#baseurl=http://download.fedoraproject.org/pub|baseurl=https://mirrors.ustc.edu.cn|g' /etc/yum.repos.d/epel.repo
  sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/epel.repo
  sed -i 's|#baseurl=http://download.fedoraproject.org/pub|baseurl=https://mirrors.ustc.edu.cn|g' /etc/yum.repos.d/epel-testing.repo
  sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/epel-testing.repo

  yum update -y
  yum install -y ${PACKAGES[@]}
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  cat > /etc/apt/source.list <<EOF
deb http://mirrors.ustc.edu.cn/debian jessie main
deb-src http://mirrors.ustc.edu.cn/debian jessie main
deb http://mirrors.ustc.edu.cn/debian-security jessie/updates main
deb-src http://mirrors.ustc.edu.cn/debian-security jessie/updates main
deb http://mirrors.ustc.edu.cn/debian jessie-updates main
deb-src http://mirrors.ustc.edu.cn/debian jessie-updates main
EOF

  apt-get update -qq
  apt-get install -y -qq ${PACKAGES[@]}
fi
