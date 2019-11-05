#!/bin/bash

# Install system tuning daemon
yum -q -y install tuned
systemctl start tuned

# Configure virtual guest profile
tuned-adm profile virtual-guest

# Clean-up
systemctl stop tuned
rm -f /var/log/tuned/tuned.log
