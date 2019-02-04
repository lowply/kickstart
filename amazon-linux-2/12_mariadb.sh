#!/bin/bash

. ./lib

echo "Install MariaDB"
yum -y install mariadb mariadb-server

systemctl start mariadb
systemctl enable mariadb
