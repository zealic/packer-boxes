#!/bin/sh
setup-keymap us us
setup-interfaces -i <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    hostname vagrant
EOF
setup-dns -d local 8.8.8.8
setup-timezone -z UTC
setup-apkrepos http://%{mirror_host}/alpine/v3.3/main
setup-ntp -c chrony
apk add e2fsprogs syslinux mkinitfs
mkfs.ext4 /dev/sda
mount -t ext4 /dev/sda /mnt
setup-disk /mnt
#setup-alpine -f ks.cfg <<EOF
#%{ssh_password}
#%{ssh_password}
#y
#EOF
chroot /mnt /bin/ash -c "apk add openssh && rc-update add sshd default"
umount /mnt
