#!/bin/bash

. ./lib

echo "Install Nagios"
yum install -y nagios nagios-plugins-all nrpe --enablerepo=epel
systemctl start nrpe
systemctl enable nrpe
