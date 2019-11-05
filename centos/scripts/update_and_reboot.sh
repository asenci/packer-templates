#!/bin/bash

# Import CentOS GPG key to avoid warnings
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

# Disable deltarpm support
sed -i -e '/^\[main\]/a deltarpm=0' /etc/yum.conf

yum -q -y update

reboot
