#!/bin/bash
NODE_VERSION=4

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | \
  NVM_DIR=/usr/local/nvm bash

cat > /etc/profile.d/nvm.sh <<"EOF"
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
EOF
chmod +x /etc/profile.d/nvm.sh
source /etc/profile.d/nvm.sh

nvm install "v$NODE_VERSION.*"
npm install -g npm
