#!/bin/bash

# workaround for bootstrapping, there is no https support
mkdir -p /etc/yum.repos.d
cat > /etc/yum.repos.d/openeuler.repo <<'EOF'
[openEuler]
name=openEuler-$releasever-OS
baseurl=http://mirrors.zju.edu.cn/openeuler/openEuler-$releasever/OS/$basearch/
enabled=1
gpgcheck=0
EOF

# system-release will introduce repo and keys
dnf --releasever="$VERSION_ID" \
    --setopt=install_weak_deps=False \
    install ca-certificates rpm openEuler-release
rm -f /etc/yum.repos.d/openeuler.repo
sed -i 's/repo.openeuler.org/mirrors.zju.edu.cn\/openeuler/g' /etc/yum.repos.d/openEuler.repo

# now we have the everything repo
dnf --releasever="$VERSION_ID" \
    groupinstall core
