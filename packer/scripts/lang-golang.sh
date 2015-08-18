#!/bin/sh
yum install -y golang git subversion mercurial bzr
mkdir /go
chown 777 /go
cat > /etc/profile.d/golang.sh <<'EOF'
export GOPATH=/go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH
EOF
