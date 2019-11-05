#!/bin/bash

dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
chmod 600 /swapfile
mkswap /swapfile >/dev/null
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
