#!/bin/sh
yum install -y python python-devel python-pip
pip install distribute virtualenv nose

mkdir -p /root/.pip
cat > /root/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.mirrors.ustc.edu.cn/simple
EOF

mkdir -p /home/vagrant/.pip
cp /root/.pip/pip.conf /home/vagrant/.pip/pip.conf
chown -R vagrant:vagrant /home/vagrant/.pip
