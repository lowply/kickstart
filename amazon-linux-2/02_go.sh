#!/bin/bash

. ./lib

echo "Install Go"
VERSION="1.14.1"
curl -OL https://dl.google.com/go/go${VERSION}.linux-amd64.tar.gz

# For A1 instances
# curl -OL https://dl.google.com/go/go${VERSION}.linux-arm64.tar.gz
tar vxzf go${VERSION}.linux-amd64.tar.gz
mv go /usr/local/go
ln -s /usr/local/go/bin/go* /usr/local/bin/
