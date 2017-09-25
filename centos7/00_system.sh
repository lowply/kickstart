#!/bin/bash

. ./lib

echo "Change SSH port"
sed -i 's/#Port 22/Port 1417/' /etc/ssh/sshd_config
systemctl restart sshd

echo "Disable SELinux"
setenforce 0

echo "Configure date"
timedatectl set-timezone Asia/Tokyo
