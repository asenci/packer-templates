#!/bin/bash

# Boot options
sed -i 's/^set timeout=5$/set timeout=1/g' /boot/grub2/grub.cfg


# Packages
tdnf -q -y update
tdnf -q -y install rng-tools


# VMWare
cat > /etc/sysctl.d/10-vm_swappiness.conf << EOF
vm.swappiness = 1
EOF


# Locale
cat > /etc/locale.conf << EOF
LANG='en_US.UTF-8'
LC_COLLATE='C'
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


# Reboot before cleanup
/sbin/reboot
