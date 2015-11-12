#!/bin/bash
CMD=/usr/bin/fuck_gfw
echo '#!/bin/bash' > $CMD
chmod +x $CMD

# Package manager
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  cat >> $CMD <<"EOF"
# yum conf
cat > /etc/yum.repos.d/CentOS-Base.repo <<"CONF"
[base]
name=CentOS-$releasever - Base
baseurl=https://%{mirror_host}/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever - Updates
baseurl=https://%{mirror_host}/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras
baseurl=https://%{mirror_host}/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[centosplus]
name=CentOS-$releasever - Plus
baseurl=https://%{mirror_host}/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
CONF

# epel conf
cat > /etc/yum.repos.d/epel.repo <<"CONF"
[epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
baseurl=https://%{mirror_host}/epel/7/$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - $basearch - Debug
baseurl=https://%{mirror_host}/epel/7/$basearch/debug
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 7 - $basearch - Source
baseurl=https://%{mirror_host}/epel/7/SRPMS
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
gpgcheck=1
CONF
EOF

elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  cat >> $CMD <<"EOF"
# yum conf
cat > /etc/apt/source.list <<"CONF"
deb https://%{mirror_host}/debian jessie main
deb-src https://%{mirror_host}/debian jessie main
deb https://%{mirror_host}/debian-security jessie/updates main
deb-src https://%{mirror_host}/debian-security jessie/updates main
deb https://%{mirror_host}/debian jessie-updates main
deb-src https://%{mirror_host}/debian jessie-updates main
CONF
EOF
fi

# Ruby
cat >> $CMD <<"EOF"
# Ruby
gem sources --remove https://rubygems.org/
gem sources -a https://ruby.taobao.org/
EOF

# Python
cat >> $CMD <<"EOF"
# Python
cat > /etc/profile.d/100_pip-mirror.sh <<"CONF"
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<"CONF"
[global]
index-url = https://pypi.mirrors.ustc.edu.cn/simple
CONF
EOF

# END
cat >> $CMD <<"EOF"
# END
echo 'Just had fucked GFW!'
EOF

if [[ $BUILD_REGION =~ cn ]]; then
  /usr/bin/fuck_gfw
fi
