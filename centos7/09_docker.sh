#!/bin/bash

. ./lib

# See https://docs.docker.com/engine/installation/linux/docker-ce/centos/
echo "Install Docker"
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl start docker
usermod -G docker ${USERNAME}

VERSION="1.16.1"

echo "Install Docker Compose"
curl -L -o /usr/local/bin/docker-compose \
	https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-Linux-x86_64
chmod 755 /usr/local/bin/docker-compose
