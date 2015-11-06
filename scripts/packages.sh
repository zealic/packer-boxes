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
  ###########################################################
  # Setup yum
  if [[ $BUILD_REGION =~ cn ]]; then
    # Setup mirror on china
    sed -i 's|enabled=1|enabled=0|g' /etc/yum/pluginconf.d/fastestmirror.conf
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=https://mirrors.ustc.edu.cn|g' /etc/yum.repos.d/CentOS-Base.repo
    sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-Base.repo
  fi

  # Setup EPEL
  yum install -y epel-release
  if [[ $BUILD_REGION =~ cn ]]; then
    sed -i 's|#baseurl=http://download.fedoraproject.org/pub|baseurl=https://mirrors.ustc.edu.cn|g' /etc/yum.repos.d/epel.repo
    sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/epel.repo
    sed -i 's|#baseurl=http://download.fedoraproject.org/pub|baseurl=https://mirrors.ustc.edu.cn|g' /etc/yum.repos.d/epel-testing.repo
    sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/epel-testing.repo
  fi

  yum update -y
  yum install -y ${PACKAGES[@]}
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  if [[ $BUILD_REGION =~ cn ]]; then
    cat > /etc/apt/source.list <<"EOF"
deb http://mirrors.ustc.edu.cn/debian jessie main
deb-src http://mirrors.ustc.edu.cn/debian jessie main
deb http://mirrors.ustc.edu.cn/debian-security jessie/updates main
deb-src http://mirrors.ustc.edu.cn/debian-security jessie/updates main
deb http://mirrors.ustc.edu.cn/debian jessie-updates main
deb-src http://mirrors.ustc.edu.cn/debian jessie-updates main
EOF
  else
    cat > /etc/apt/source.list <<"EOF"
deb http://mirrors.kernel.org/debian jessie main
deb-src http://mirrors.kernel.org/debian jessie main
deb http://mirrors.kernel.org/debian jessie-updates main
deb-src http://mirrors.kernel.org/debian jessie-updates main
deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main
EOF
  fi

  apt-get update -qq
  apt-get install -y -qq ${PACKAGES[@]}
fi
