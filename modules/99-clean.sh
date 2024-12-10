#!/bin/bash
clean_all() {
	echo "" >/etc/hostname
}

clean_debian() {
	apt-get autopurge
	apt-get clean
	rm -f /etc/apt/apt.conf.d/80proxy
	rm -f /etc/apt/apt.conf.d/80debug
	echo "" >/usr/sbin/policy-rc.d
	rm -f /etc/dpkg/dpkg.cfg.d/02dpkg-unsafe-io
}

clean_ubuntu() {
	clean_debian
}

clean_arch()
{
	pacman --noconfirm -Scc
	sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf
	rm -rf /dev/fd
}

clean_openEuler()
{
	dnf clean all
}

clean_all
check_and_exec clean_"$DISTRO"
