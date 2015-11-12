#!/bin/bash
if [[ ! $BUILD_FORMAT =~ vagrant ]]; then
  echo "Build format is not vagrant format."
  exit 0
fi

date > /etc/vagrant_box_build_time

# Add vagrant user
/usr/sbin/groupadd vagrant
/usr/sbin/useradd -s /bin/bash -g vagrant vagrant
echo -e "vagrant\nvagrant" | passwd vagrant
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# Installing vagrant keys
mkdir -pm 700 /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Customize the message of the day
echo 'Welcome to your Vagrant-built virtual machine.' > /etc/motd
