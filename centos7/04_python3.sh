#!/bin/bash

. ./lib

VERSION="3.6.2"

echo "Install Python"
cd /usr/local/src/
curl -OL https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz
tar vxzf Python-${VERSION}.tgz
cd Python-${VERSION}
./configure --prefix=/usr/local/python && make && make install
cd /usr/local/bin/
ln -s /usr/local/python/bin/python3 .
ln -s /usr/local/python/bin/pip3 .
