#!/bin/bash

sed -i -e '/^\s*GSSAPIAuthentication/d' /etc/ssh/sshd_config
sed -i -e '/^\s*UseDNS/d' /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config << EOF

GSSAPIAuthentication no
UseDNS no
EOF
