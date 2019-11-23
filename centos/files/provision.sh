#!/bin/bash

# Yum
cat > /etc/yum/vars/infra << EOF
vag
EOF

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

sed -i -e '/^\[main\]/a deltarpm=0' /etc/yum.conf

yum -q -y update

yum -q -y install rng-tools


# Hypervisor
case "${PACKER_BUILDER_TYPE}" in
	parallels-iso)
		# Parallels Desktop
		yum -q -y install https://asenci.github.io/parallels-tools-rpm/centos/7/x86_64/Packages/parallels-tools-release-7-1.noarch.rpm
		yum -q -y install parallels-tools
		;;

	vmware-iso)
		# VMWare
		yum -q -y install open-vm-tools

		cat > /etc/dracut.conf.d/vmware.conf <<- EOF
		add_drivers+=" vmw_pvscsi "
		EOF
		;;

	*)
		echo "Builder \"${PACKER_BUILDER_TYPE}\" does not match any pre-defined builders" >&2
esac


# Disable floppy
cat > /etc/dracut.conf.d/nofloppy.conf << EOF
omit_drivers+=" floppy "
EOF

cat > /etc/modprobe.d/nofloppy.conf << EOF
blacklist floppy
EOF


# Vagrant
useradd --create-home --user-group vagrant
install -o vagrant -g vagrant -m 0700 -d /home/vagrant/.ssh
install -o vagrant -g vagrant -m 0600 /dev/null /home/vagrant/.ssh/authorized_keys
curl -s -o /home/vagrant/.ssh/authorized_keys 'https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub'

chpasswd 2>/dev/null << EOF
vagrant:vagrant
EOF

cat > /etc/sudoers.d/vagrant << EOF
Defaults:vagrant env_keep += \"SSH_AUTH_SOCK\"
Defaults:vagrant !requiretty
vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/vagrant


# Locale
cat > /etc/locale.conf << EOF
LANG='en_US.UTF-8'
LC_COLLATE='C'
EOF


# Sysctl
cat > /etc/sysctl.d/10-vm_swappiness.conf << EOF
vm.swappiness = 1
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
