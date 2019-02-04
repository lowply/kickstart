#!/bin/bash

. ./lib

echo "Install nginx"
amazon-linux-extras install nginx
systemctl start nginx
systemctl enable nginx
