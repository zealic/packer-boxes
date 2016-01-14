#!/bin/bash
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y git subversion
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get install -y -qq git subversion
fi

GO_VERSION=1.5.3
curl -SL -o /tmp/golang.tar.gz https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/golang.tar.gz

ln -sf /usr/local/go/bin/go /usr/local/bin/go
ln -sf /usr/local/go/bin/godoc /usr/local/bin/godoc
ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
