#!/bin/sh
yum install -y python python-devel python-pip
pip install distribute virtualenv nose 

mkdir -p /root/.pip
cat > /root/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.mirrors.ustc.edu.cn/simple
EOF

cp /home/vagrant/.pip/pip.conf /home/vagrant/.pip/pip.conf
chown vagrant:vagrant /home/vagrant/.pip/pip.conf
