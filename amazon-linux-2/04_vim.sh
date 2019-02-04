#!/bin/bash

. ./lib

VERSION="8.1.0873"

echo "Install vim"
yum -y remove vim-common vim-enhanced
yum -y install python3 python3-devel lua lua-devel autoconf gcc xmlto asciidoc docbook2X curl curl-devel perl perl-devel expat expat-devel gettext openssl openssl-devel ncurses-devel

cd /usr/local/src/
curl -OL https://github.com/vim/vim/archive/v8.1.0873.tar.gz

tar vxzf v${VERSION}.tar.gz
cd vim-${VERSION}

./configure \
    --prefix=/usr/local/vim \
    --with-features=huge \
    --enable-multibyte \
    --enable-luainterp \
    --enable-fail-if-missing \
    --enable-python3interp

make && make install

cd /usr/local/bin
ln -s /usr/local/vim/bin/* .
