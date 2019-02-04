#!/bin/bash

. ./lib

VERSION="2.8"

echo "Install tmux"
yum -y install libevent-devel ncurses-devel
cd /usr/local/src
curl -OL https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz
tar vxzf tmux-${VERSION}.tar.gz
cd tmux-${VERSION}
./configure --prefix=/usr/local/tmux
make && make install
ln -s /usr/local/tmux/bin/tmux /usr/local/bin/
