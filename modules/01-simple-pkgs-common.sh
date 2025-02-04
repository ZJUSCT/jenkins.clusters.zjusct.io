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
	ffmpeg skopeo umoci debootstrap hyperfine iotop
)

install_pkg "${COMMON_PACKAGES[@]}"
