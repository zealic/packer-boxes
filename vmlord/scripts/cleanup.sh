#!/bin/sh
##########################################################
# General
##########################################################
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
sed -i -E '/^Permit.+/d' /etc/ssh/sshd_config