#!/bin/sh
sed -i 's|enabled=1|enabled=0|g' /etc/yum/pluginconf.d/fastestmirror.conf
curl -sSL -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
yum install -y epel-release
sed -i 's|#baseurl=http://download.fedoraproject.org/pub|baseurl=http://mirrors.ustc.edu.cn|g' /etc/yum.repos.d/epel.repo
sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/epel.repo
sed -i 's|#baseurl=http://download.fedoraproject.org/pub|baseurl=http://mirrors.ustc.edu.cn|g' /etc/yum.repos.d/epel-testing.repo
sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/epel-testing.repo

yum install -y docker
sed -i 's|OPTIONS=|OPTIONS=--registry-mirror=https://docker.mirrors.ustc.edu.cn |g' /etc/sysconfig/docker
systemctl enable docker
systemctl start docker
curl -sSL -o /usr/bin/weave https://github.com/weaveworks/weave/releases/download/v0.11.0/weave
chmod a+x /usr/bin/weave
weave setup
