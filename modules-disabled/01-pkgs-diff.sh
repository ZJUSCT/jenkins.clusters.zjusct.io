#!/bin/bash

# special package information:
# - exa is replaced by eza, the former is available in Debian 12, the latter is available in Ubuntu 24
# - linux-tools is available on Ubuntu, but deprecated on Debian, split into tools like linux-perf
# - golang in stable is very old

install_special_pkgs() {
	case $ID in
	debian)
		apt-get install linux-cpupower linux-perf
		case $VERSION_CODENAME in
		bookworm) # stable
			apt-get install exa
			;;
		trixie | sid) # testing, unstable
			apt-get install eza gping
			;;
		esac
		;;
	ubuntu)
		apt-get install linux-tools-common
		apt-get install eza gping
		case $VERSION_CODENAME in
		noble) # 24.04 LTS
			;;
		oracular) # 24.10
			;;
		esac
		;;
	esac
}

install_special_pkgs
# bat
if [ ! -e /usr/bin/bat ]; then
	ln -s /usr/bin/batcat /usr/bin/bat
fi
# fd-find
if [ ! -e /usr/bin/fd ]; then
	ln -s /usr/bin/fdfind /usr/bin/fd
fi
