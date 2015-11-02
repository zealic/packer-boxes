#!/bin/sh
##########################################################
# General
##########################################################
# Clear root password
passwd -d root

# Remove Linux headers
yum -y clean all

# Cleanup log files
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# remove under tmp directory
rm -rf /tmp/*

# Remove kickstart configuration
rm /root/anaconda-ks.cfg

# Clean network
rm -f /etc/udev/rules.d/70-persistent-net.rules
sed -i '/^UUID/d'   /etc/sysconfig/network-scripts/ifcfg-enp0s3
sed -i '/^HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-enp0s3


##########################################################
# Other
##########################################################
# Remove root permit permission on ssh
sed -i -r 's/^#?(PermitRootLogin|PasswordAuthentication) yes/\1 no/' /etc/ssh/sshd_config

# Remove Virtualbox specific files
rm -rf /usr/src/vboxguest* /usr/src/virtualbox-ose-guest*
rm -rf *.iso *.iso.? /tmp/vbox /home/vagrant/.vbox_version

# Cleanup disk
dd if=/dev/zero of=/EMPTY bs=1M
rm -rf /EMPTY
