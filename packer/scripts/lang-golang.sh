#!/bin/sh
yum install -y golang git subversion mercurial bzr
cat > /etc/profile.d/golang.sh <<EOF
export GOPATH=/vagrant/.go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH
EOF
