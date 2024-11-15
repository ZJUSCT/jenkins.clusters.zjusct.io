#!/bin/bash

# Copyright 2012-2024 Holger Levsen <holger@layer-acht.org>
#           2018-2023 Mattia Rizzolo <mattia@debian.org>
#           2024-2025 Baolin Zhu <zhubaolin228@gmail.com> and ZJUSCT
# 
# The following code is a derivative work of the code from the jenkins.debian.net, 
# which is licensed GPLv2. This code therefore is also licensed under the terms 
# of the GNU Public License, verison 2.

set -x
mount -t proc /proc /proc
mount -t tmpfs tmpfs /tmp
# fix dns problem for ubuntu
# https://askubuntu.com/questions/469209/how-to-resolve-hostnames-in-chroot
if [ "$ID" = "ubuntu" ]; then
	rm -f /etc/resolv.conf
	cat >/etc/resolv.conf <<EOF
nameserver 127.0.0.1
nameserver 172.25.2.253
nameserver 10.10.0.21
EOF
fi
# default console password, will be superseeded when SSSD is setup
echo "root:root" | chpasswd
echo -e '#!/bin/sh\nexit 101' >/usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
# configure dpkg to use unsafe io for faster installs
mkdir -p /etc/dpkg/dpkg.cfg.d
echo force-unsafe-io >/etc/dpkg/dpkg.cfg.d/02dpkg-unsafe-io
set +x
