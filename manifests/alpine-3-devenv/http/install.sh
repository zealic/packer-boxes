#!/bin/sh
setup-keymap us us
setup-interfaces -i <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    hostname vagrant
EOF
setup-timezone -z UTC
setup-apkrepos http://%{mirror_host}/alpine/v3.3/main
setup-ntp -c chrony
apk add --update
apk add e2fsprogs syslinux mkinitfs
echo "n
p
1


a
1
w
" | fdisk /dev/sda
mkfs.ext4 /dev/sda1
mount -t ext4 /dev/sda1 /mnt
setup-disk /mnt
chroot /mnt /bin/ash -c "echo -e '%{ssh_password}\n%{ssh_password}' | passwd"
chroot /mnt /bin/ash -c "apk add openssh && rc-update add sshd default"
chroot /mnt /bin/ash -c "apk add sudo bash"
sed -i -r 's/^#?(PermitRootLogin|PasswordAuthentication) .+/\1 yes/' /mnt/etc/ssh/sshd_config
dd if=/usr/share/syslinux/mbr.bin of=/dev/sda
extlinux --install /mnt/boot
umount /mnt
