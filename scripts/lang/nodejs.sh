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

export NVM_NODEJS_ORG_MIRROR=https://nodejs.org/dist
export npm_config_registry=http://registry.npmjs.org
if [[ $BUILD_REGION =~ cn ]] || [[ $BUILD_REGION =~ cn ]]; then
  export NVM_NODEJS_ORG_MIRROR=https://mirrors.ustc.edu.cn/node
  export npm_config_registry=https://registry.npm.taobao.org
fi
nvm install "v$NODE_VERSION.*"
npm install -g npm
