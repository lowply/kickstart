#!/bin/bash

. ./lib

echo "Change SSH port"
sed -i 's/#Port 22/Port 1417/' /etc/ssh/sshd_config
systemctl restart sshd
systemctl enable sshd

echo "Configure date"
timedatectl set-timezone Asia/Tokyo
