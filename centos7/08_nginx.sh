#!/bin/bash

. ./lib

echo "Install nginx"
cat <<- EOF > /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF
yum install -y nginx
systemctl start nginx
