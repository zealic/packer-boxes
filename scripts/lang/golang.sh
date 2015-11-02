#!/bin/sh
if [[ $BUILD_GUEST_OS =~ centos ]]; then
  yum install -y golang git subversion mercurial bzr
elif [[ $BUILD_GUEST_OS =~ debian ]]; then
  apt-get install -y golang git subversion mercurial bzr
fi

mkdir /go
chown 777 /go
cat > /etc/profile.d/golang.sh <<'EOF'
export GOPATH=/go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH
EOF
