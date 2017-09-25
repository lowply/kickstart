#!/bin/bash

. ./lib

VERSION="2.14.1"

echo "Install git from source"
cd /usr/local/src
curl -OL https://www.kernel.org/pub/software/scm/git/git-${VERSION}.tar.gz
tar vxzf git-${VERSION}.tar.gz
cd git-${VERSION}
./configure --prefix=/usr/local/git && make && make install
cd /usr/local/bin
ln -s /usr/local/git/bin/* .

echo "Install diff-highlight"
cp -a /usr/local/src/git-${VERSION}/contrib /usr/local/git/
cd /usr/local/git/contrib/diff-highlight
make
ln -s /usr/local/git/contrib/diff-highlight/diff-highlight /usr/local/bin/diff-highlight
