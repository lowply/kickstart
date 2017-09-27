#!/bin/bash

. ./lib

echo "Install Munin"
yum -y install mariadb mariadb-server

systemctl start mariadb
systemctl enable mariadb
