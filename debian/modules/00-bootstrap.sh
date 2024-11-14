#!/bin/bash

# Copyright 2012-2024 Holger Levsen <holger@layer-acht.org>
#           2018-2023 Mattia Rizzolo <mattia@debian.org>
#           2024-2025 Baolin Zhu <zhubaolin228@gmail.com> and ZJUSCT
# 
# The following code is a derivative work of the code from the jenkins.debian.net, 
# which is licensed GPLv2. This code therefore is also licensed under the terms 
# of the GNU Public License, verison 2.

set -x
mount /proc -t proc /proc
# default console password, will be superseeded when SSSD is setup
echo "root:root" | chpasswd
echo -e '#!/bin/sh\nexit 101' >/usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
# configure dpkg to use unsafe io for faster installs
mkdir -p /etc/dpkg/dpkg.cfg.d
echo force-unsafe-io >/etc/dpkg/dpkg.cfg.d/02dpkg-unsafe-io
set +x
