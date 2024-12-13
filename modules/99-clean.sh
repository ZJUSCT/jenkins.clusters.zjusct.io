#!/bin/bash

echo "" >/etc/hostname
if [ -f /etc/resolv.conf.bak ]; then
	mv /etc/resolv.conf.bak /etc/resolv.conf
fi

case $ID in
debian | ubuntu)
	apt-get autopurge
	apt-get clean
	rm -f /etc/apt/apt.conf.d/80proxy
	rm -f /etc/apt/apt.conf.d/80debug
	echo "" >/usr/sbin/policy-rc.d
	rm -f /etc/dpkg/dpkg.cfg.d/02dpkg-unsafe-io
	;;
arch)
	pacman -Scc
	sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf
	rm -rf /dev/fd
	;;
openEuler)
	dnf clean all
	;;
esac
