#!/bin/bash

# Remove unused packages
rpm -q linux-firmware >/dev/null && yum -q -y autoremove linux-firmware

# Remove old kernel versions
rpm -qa kernel | head -n -1 | xargs yum -q -y autoremove

# Clean-up yum
yum -q -y autoremove
yum -q -y clean all
rm -f /var/log/yum.log

# Rebuild initramfs
find /boot -name 'initramfs-*.img' | xargs dracut -f


# Remove unused network configurations
find /etc/sysconfig/network-scripts -name 'ifcfg-*' -not -name 'ifcfg-lo' -not -name 'ifcfg-eth0' -delete


# Remove anaconda artifacts
rm -f /etc/sysconfig/anaconda
rm -f /root/anaconda-ks.cfg
rm -f /root/original-ks.cfg
rm -rf /var/log/anaconda


# Clean-up log files
systemctl stop rsyslog.service syslog.socket
rm -f /var/lib/rsyslog/imjournal.state

/usr/sbin/logrotate -f /etc/logrotate.conf
rm -f /var/log/*-???????? /var/log/*.gz
rm -f /var/log/dmesg.old
:>/var/log/lastlog
:>/var/log/tallylog
:>/var/log/wtmp

# Reset SSH host keys
systemctl stop sshd
rm -f /etc/ssh/ssh_host_*


# Clean-up misc
rm -rf /etc/udev/rules.d/70-*
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


# Clean-up DHCP leases
pkill dhclient
rm -f /var/lib/dhclient/dhclient-*.lease


# Remove swapfile if created
if [ -f /swapfile ]; then
	export SWAPSIZE=`stat --printf="%s" /swapfile`
	swapoff /swapfile 2>/dev/null || true
	rm -f /swapfile
fi

# Defrag disk
dd if=/dev/zero of=/zero.img bs=1M oflag=direct status=none 2>/dev/null || true
rm -f /zero.img

# Re-create swapfile
if [ -n "$SWAPSIZE" ]; then
	dd if=/dev/zero of=/swapfile bs=1M oflag=direct status=none count="$SWAPSIZE" iflag=count_bytes
	mkswap /swapfile >/dev/null
fi

# Make sure all disk IO has finished
sync
