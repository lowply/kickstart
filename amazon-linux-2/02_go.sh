#!/bin/bash

. ./lib

VERSION="1.11.5"

echo "Install Go"
cd /usr/local/src/
curl -OL https://dl.google.com/go/go${VERSION}.linux-amd64.tar.gz
tar vxzf go${VERSION}.linux-amd64.tar.gz
mv go /usr/local/
cd /usr/local/bin/
ln -s /usr/local/go/bin/* .
su -l -c "mkdir ~/go" ${USERNAME}

echo "Install ghq"
su -l -c "go get github.com/motemen/ghq" ${USERNAME}
