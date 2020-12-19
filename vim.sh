#!/bin/bash

VERSION="8.2.1288"

yum -y remove vim-common vim-enhanced
yum -y install python3 python3-devel lua lua-devel
yum -y install autoconf gcc xmlto asciidoc docbook2X curl curl-devel perl perl-devel expat expat-devel gettext openssl openssl-devel ncurses-devel

cd /usr/local/src/
curl -OL https://github.com/vim/vim/archive/v${VERSION}.tar.gz
tar vxzf v${VERSION}.tar.gz
cd vim-${VERSION}

./configure \
--prefix=/usr/local/vim \
--with-features=huge \
--enable-multibyte \
--enable-luainterp \
--enable-fail-if-missing \
--enable-python3interp \
--with-python3-config-dir=/usr/lib64/python3.7/config-3.7m-x86_64-linux-gnu

## Use correct dir, for example on CentOS 8 this should be:
## --with-python3-config-dir=/usr/lib64/python3.6/config-3.6m-x86_64-linux-gnu

make && rm -rf /usr/local/vim && make install

ln -s /usr/local/vim/bin/* /usr/local/bin/
