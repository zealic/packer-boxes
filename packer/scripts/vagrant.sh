#!/usr/bin/env bash
# Installing vagrant keys
mkdir /home/vagrant/.ssh
wget --no-check-certificate -O authorized_keys 'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub'
mv authorized_keys /home/vagrant/.ssh
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# Deps
yum install -y net-tools bind-utils nfs-common portmap rpcbind libgssglue nfs-utils keyutils libevent nfs-utils-lib

# Customize the message of the day
echo 'Welcome to your Vagrant-built virtual machine.' > /etc/motd
