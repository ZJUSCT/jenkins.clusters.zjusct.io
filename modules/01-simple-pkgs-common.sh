#!/bin/bash
# https://pkgs.io/

COMMON_PACKAGES=(
	aria2 attr autoconf automake bat bc bison bridge-utils btop cargo ccls chrony
	clang clang cmake cmake cpufetch curl curl doxygen dracut duf ethtool
	exfatprogs fish fish flex fq fzf gawk gdb gdb-multiarch gdu git git git-extras
	git-lfs gperf htop httpie hugo hwinfo hwloc hyperfine iperf3 ipmitool iptraf-ng
	jenkins-job-builder jq libtool lldb lldpd locate mc meson neofetch net-tools
	numactl nvtop patchutils pkg-config pkg-config ripgrep screenfetch
	squashfs-tools sshfs stress sudo tcpdump tcpdump texinfo tldr tmux traceroute
	tree unrar valgrind vim wget zip zoxide zsh
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
