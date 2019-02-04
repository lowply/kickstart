#!/bin/bash

. ./lib

echo "Install Go"
sudo amazon-linux-extras install golang1.11
su -l -c "mkdir ~/go" ${USERNAME}

echo "Install ghq"
su -l -c "go get github.com/motemen/ghq" ${USERNAME}
