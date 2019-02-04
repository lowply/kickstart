#!/bin/bash

. ./lib

echo "Install Docker"
amazon-linux-extras install docker
systemctl start docker
systemctl enable docker

VERSION="1.23.2"

echo "Install Docker Compose"
curl -L "https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose
