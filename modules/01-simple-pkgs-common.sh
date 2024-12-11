#!/bin/bash
# https://pkgs.io/

COMMON_PACKAGES=(
	attr autoconf automake bc bison bridge-utils cargo chrony
	clang clang cmake cmake curl curl doxygen dracut ethtool
	fish fish flex gawk gdb git git
	gperf htop hwinfo hwloc iperf3 ipmitool iptraf-ng
	jq libtool lldb mc meson net-tools
	numactl patchutils pkg-config pkg-config
	squashfs-tools sshfs sudo tcpdump tcpdump texinfo tldr tmux traceroute
	tree valgrind vim wget zip zsh openssl
)

case $ID in
debian | ubuntu)
	apt-get install "${COMMON_PACKAGES[@]}"
	;;
openEuler)
	dnf install "${COMMON_PACKAGES[@]}"
	;;
arch)
	pacman -S "${COMMON_PACKAGES[@]}"
	;;
esac
