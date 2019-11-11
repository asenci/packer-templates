#!/bin/bash
chmod 0440 /etc/sudoers.d/vagrant

useradd --create-home --user-group vagrant
install -o vagrant -g vagrant -m 0700 -d /home/vagrant/.ssh
install -o vagrant -g vagrant -m 0600 /dev/null /home/vagrant/.ssh/authorized_keys
curl -s -o /home/vagrant/.ssh/authorized_keys 'https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub'

chpasswd << EOF
root:vagrant
vagrant:vagrant
EOF

sed -i -e '/^\s*PasswordAuthentication/d' /etc/ssh/sshd_config
sed -i -e '/^\s*PermitRootLogin/d' /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config << EOF

PasswordAuthentication no
PermitRootLogin no
EOF
