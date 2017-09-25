#!/bin/bash

. ./lib

VERSION="0.2.0"

echo "Install neovim"
cd /usr/local/src/
curl -OL https://github.com/neovim/neovim/archive/v${VERSION}.tar.gz
tar vxzf v${VERSION}.tar.gz
cd neovim-${VERSION}/
make && make install
/usr/local/bin/pip3 install neovim

echo "Install dein"
su ${USERNAME} -c "curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > ~/installer.sh"
su ${USERNAME} -c "sh ~/installer.sh ~/.cache/dein"
