#!/bin/bash
if [[ ! $BUILD_FORMAT =~ vagrant ]]; then
  echo "Build format is not vagrant format."
  exit 0
fi

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
  if [[ $BUILD_FORMAT =~ vagrant ]]; then
    mount -o loop /home/vagrant/VBoxGuestAdditions.iso /mnt
    /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm -rf VBoxGuestAdditions.iso
  fi
fi

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
  if [[ $BUILD_GUEST_OS =~ centos ]]; then
    yum install -y fuse-libs open-vm-tools
  elif [[ $BUILD_GUEST_OS =~ debian ]]; then
    apt-get install -y -qq open-vm-tools
  fi
fi
