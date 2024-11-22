#!/bin/bash
set -x
case $INIT in
systemd) # systemd-nspawn handles mounts
	;;
*) # if in chroot, you need to mount /proc first, so INIT is empty in bootstrap
	mount -t proc /proc /proc
	mount -t tmpfs tmpfs /tmp
	cat >/etc/resolv.conf <<EOF
nameserver 127.0.0.1
nameserver 172.25.2.253
nameserver 10.10.0.21
EOF
	;;
esac
# default console password, will be superseeded when SSSD is setup
echo "root:root" | chpasswd
set +x
