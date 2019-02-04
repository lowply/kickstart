#!/bin/bash

. ./lib

echo "Install Nagios"
yum install -y nagios nagios-plugins-all nrpe
systemctl start nrpe
systemctl enable nrpe
