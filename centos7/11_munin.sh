#!/bin/bash

. ./lib

echo "Install Munin"
yum -y install munin --enablerepo=epel

systemctl start munin-node
systemctl enable munin-node
