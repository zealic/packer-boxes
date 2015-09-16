if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
  mount -o loop /home/vagrant/VBoxGuestAdditions.iso /mnt
  /mnt/VBoxLinuxAdditions.run
  umount /mnt
  rm -rf VBoxGuestAdditions.iso
fi

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
  yum install -y fuse-libs open-vm-tools
fi
