#!/bin/bash

# Clean-up tdnf
tdnf -q -y clean all >/dev/null


# Clean-up log files
rm -rf /var/log/journal/*
ln -s /var/opt/journal/log /var/log/journal/log
rm -f /var/log/vmware-*.log
rm -f /var/log/vmware-*.log.0
:>/var/log/lastlog
:>/var/log/wtmp


# Reset SSH host keys
systemctl stop sshd
rm -f /etc/ssh/ssh_host_*


# Clean-up misc
rm -f /etc/udev/hwdb.bin
rm -rf /tmp/*
rm -f /var/lib/systemd/random-seed
rm -rf /var/cache/*
rm -rf /var/tmp/*


# systemd should generate a new machine id during the first boot, to
# avoid having multiple Vagrant instances with the same id in the local
# network. /etc/machine-id should be empty, but it must exist to prevent
# boot errors (e.g.  systemd-journald failing to start).
:>/etc/machine-id


# Defrag disk
dd if=/dev/zero of=/boot/zero.img bs=1M oflag=direct status=none 2>/dev/null || true
rm -f /boot/zero.img
dd if=/dev/zero of=/zero.img bs=1M oflag=direct status=none 2>/dev/null || true
rm -f /zero.img


# Create swapfile
dd if=/dev/zero of=/swapfile bs=1M oflag=direct status=none count=2048
chmod 600 /swapfile
mkswap /swapfile >/dev/null
echo "/swapfile none swap defaults 0 0" >> /etc/fstab


# Make sure all disk IO has finished
sync
