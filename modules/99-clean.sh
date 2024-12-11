#!/bin/bash
all() {
	echo "" >/etc/hostname
}

debian() {
	apt-get autopurge
	apt-get clean
	rm -f /etc/apt/apt.conf.d/80proxy
	rm -f /etc/apt/apt.conf.d/80debug
	echo "" >/usr/sbin/policy-rc.d
	rm -f /etc/dpkg/dpkg.cfg.d/02dpkg-unsafe-io
}

ubuntu() {
	debian
}

arch()
{
	pacman --noconfirm -Scc
	sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf
	rm -rf /dev/fd
}

openEuler()
{
	dnf clean all
}

all
check_and_exec "$DISTRO"
