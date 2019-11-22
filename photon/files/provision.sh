#!/bin/bash

# Boot options
sed -i 's/^set timeout=5$/set timeout=1/g' /boot/grub2/grub.cfg


# Packages
tdnf -q -y update
tdnf -q -y install rng-tools


# Vagrant
useradd --create-home --user-group vagrant
install -o vagrant -g vagrant -m 0700 -d /home/vagrant/.ssh
install -o vagrant -g vagrant -m 0600 /dev/null /home/vagrant/.ssh/authorized_keys
curl -s -o /home/vagrant/.ssh/authorized_keys 'https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub'

chpasswd 2>/dev/null << EOF
vagrant:vagrant
EOF

tdnf -q -y install sudo
cat > /etc/sudoers.d/vagrant << EOF
Defaults:vagrant env_keep += \"SSH_AUTH_SOCK\"
Defaults:vagrant !requiretty
vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/vagrant

install -d -m 0755 /etc/systemd/logind.conf.d
cat > /etc/systemd/logind.conf.d/vagrant.conf << EOF
# Do not kill user processes after logging out.
# Otherwise vmhgfs-fuse will be killed and Vagrant
# synced dirs won't be accessible
[Login]
KillUserProcesses=no
EOF
chmod 0644 /etc/systemd/logind.conf.d/vagrant.conf


# Locale
cat > /etc/locale.conf << EOF
LANG='en_US.UTF-8'
LC_COLLATE='C'
EOF


# Openssh
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


# Sysctl
cat > /etc/sysctl.d/10-vm_swappiness.conf << EOF
vm.swappiness = 1
EOF
