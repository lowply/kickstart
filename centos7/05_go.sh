#!/bin/bash

. ./lib

VERSION="1.9"

echo "Install Go"
cd /usr/local/src/
curl -OL https://storage.googleapis.com/golang/go${VERSION}.linux-amd64.tar.gz
tar vxzf go${VERSION}.linux-amd64.tar.gz
mv go /usr/local/
cd /usr/local/bin/
ln -s /usr/local/go/bin/* .
su ${USERNAME} -c "mkdir ~/src ~/pkg ~/bin"

echo "Install peco"
cd /usr/local/src/
curl -OL https://github.com/peco/peco/releases/download/v0.5.1/peco_linux_amd64.tar.gz
tar vxzf peco_linux_amd64.tar.gz
cd peco_linux_amd64
cp -a peco /usr/local/bin/

# echo "Install ghq"
## This doesn't work
# su ${USERNAME} -c "export GOPATH=~; go get github.com/motemen/ghq"
