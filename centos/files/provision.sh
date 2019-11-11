#!/bin/bash

# Yum
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

sed -i -e '/^\[main\]/a deltarpm=0' /etc/yum.conf

yum -q -y update

yum -q -y install open-vm-tools rng-tools


# Vagrant
cat > /etc/sudoers.d/vagrant << EOF
Defaults:vagrant env_keep += "SSH_AUTH_SOCK"
Defaults:vagrant !requiretty
vagrant ALL=(ALL) NOPASSWD: ALL
EOF

chmod 0440 /etc/sudoers.d/vagrant

cat > /etc/yum/vars/infra << EOF
vag
EOF


# VMWare
cat > /etc/dracut.conf.d/vmware.conf << EOF
add_drivers+=" vmw_pvscsi "
omit_drivers+=" floppy "
EOF

cat > /etc/modprobe.d/vmware.conf << EOF
blacklist floppy
EOF

cat > /etc/sysctl.d/10-vm_swappiness.conf << EOF
vm.swappiness = 1
EOF


# Locale
cat > /etc/environment << EOF
LANG='en_US.UTF-8'
LC_COLLATE='C'
EOF


# Networking
cat > /etc/sysconfig/network << EOF
NOZEROCONF=yes
EOF

find /etc/sysconfig/network-scripts -name 'ifcfg-*' -not -name 'ifcfg-lo' -delete

cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
ONBOOT=yes

# IPv4
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
PERSISTENT_DHCLIENT=yes

# IPv6
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
EOF


# OpenSSH
sed -i -e '/^\s*GSSAPIAuthentication/d' /etc/ssh/sshd_config
sed -i -e '/^\s*PasswordAuthentication/d' /etc/ssh/sshd_config
sed -i -e '/^\s*PermitRootLogin/d' /etc/ssh/sshd_config
sed -i -e '/^\s*UseDNS/d' /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config << EOF

GSSAPIAuthentication no
PasswordAuthentication no
PermitRootLogin no
UseDNS no
EOF

cat >>/etc/sysconfig/sshd <<EOF

# Decrease connection time by preventing reverse DNS lookups
# (see https://lists.centos.org/pipermail/centos-devel/2016-July/014981.html
#  and man sshd for more information)
OPTIONS="-u0"
EOF


# Reboot before cleanup
/sbin/reboot
