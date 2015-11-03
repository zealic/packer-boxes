#!/bin/bash
##########################################################
# General
##########################################################
# Clear root password
passwd -d root

# Cleanup package manager
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum -y clean all
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get -y clean
fi


# Cleanup log files
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# remove under tmp directory
rm -rf /tmp/*

# Clean network
rm -f /etc/udev/rules.d/70-persistent-net.rules


##########################################################
# Other
##########################################################
# Remove root permit permission on ssh
sed -i -r 's/^#?(PermitRootLogin|PasswordAuthentication) yes/\1 no/' /etc/ssh/sshd_config

# Remove Virtualbox specific files
rm -rf /usr/src/vboxguest* /usr/src/virtualbox-ose-guest*
rm -rf *.iso *.iso.? /tmp/vbox /{root,vagrant}/.vbox_version

# Cleanup disk
dd if=/dev/zero of=/EMPTY bs=1M
rm -rf /EMPTY
