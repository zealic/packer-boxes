#!/bin/bash
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y git subversion mercurial bzr
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get install -y -qq git subversion mercurial bzr
fi

GO_VERSION=1.5.1
curl -SL -o /tmp/golang.tar.gz https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz
tar -C /opt -xzf /tmp/golang.tar.gz

cat > /etc/profile.d/golang.sh <<'EOF'
export GOPATH=/opt/go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH
EOF
