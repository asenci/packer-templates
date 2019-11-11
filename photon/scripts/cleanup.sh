#!/bin/bash

# Clean-up tdnf
tdnf -q -y clean all >/dev/null

# Clean-up log files
rm -f /var/log/vmware-*.log
rm -f /var/log/vmware-*.log.0
rm -f /var/log/cloud-init.log
rm -f /var/log/cloud-init-output.log
:>/var/log/lastlog
:>/var/log/wtmp

# Reset SSH host keys
systemctl stop sshd
rm -f /etc/ssh/ssh_host_*


# Clean-up misc
rm -f /etc/udev/hwdb.bin
rm -rf /tmp/*
rm -f /var/lib/systemd/random-seed
rm -rf /var/lib/cloud
rm -rf /var/cache/*
rm -rf /var/tmp/*


# systemd should generate a new machine id during the first boot, to
# avoid having multiple Vagrant instances with the same id in the local
# network. /etc/machine-id should be empty, but it must exist to prevent
# boot errors (e.g.  systemd-journald failing to start).
:>/etc/machine-id


# Remove swapfile if created
if [ -f /swapfile ]; then
	export SWAPSIZE=`stat --printf="%s" /swapfile`
	swapoff /swapfile 2>/dev/null || true
	rm -f /swapfile
fi

# Defrag disk
dd if=/dev/zero of=/boot/zero.img bs=1M oflag=direct status=none 2>/dev/null || true
rm -f /boot/zero.img
dd if=/dev/zero of=/zero.img bs=1M oflag=direct status=none 2>/dev/null || true
rm -f /zero.img

# Re-create swapfile
if [ -n "$SWAPSIZE" ]; then
	dd if=/dev/zero of=/swapfile bs=1M oflag=direct status=none count="$SWAPSIZE" iflag=count_bytes
	chmod 600 /swapfile
	mkswap /swapfile >/dev/null
fi

# Make sure all disk IO has finished
sync
