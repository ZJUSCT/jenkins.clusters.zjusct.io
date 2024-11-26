#!/usr/bin/env bash

# Workaround to fix "error: could not determine cachedir mount point"
# Need to be re-enabled at clean
sed -i 's/^CheckSpace/#CheckSpace/' /etc/pacman.conf

# Init public keyring
pacman-key --init
pacman-key --populate archlinux

# Force update metadata and upgrade packages
pacman --noconfirm -Syyu

PACKAGES_COMMON=(
	# build-essential
	archlinuxcn-keyring
	vim nano git gdb gcc clang cmake
	htop iperf3 net-tools cpufetch doxygen exfatprogs fish # fonts-firacode
	git-extras git-lfs hwinfo hwloc ipmitool iptraf-ng jq
	lldb lldpd mc meson pipewire-jack
	fastfetch networkmanager ninja numactl nvtop
	proxychains-ng screenfetch sudo tcpdump tldr
	traceroute tree termshark unrar valgrind vim wget wireshark-cli zip
	squashfs-tools p7zip hugo
	# language and package manager
	go rust python-pipx
	# kvm # https://developer.android.com/studio/run/emulator-acceleration?utm_source=android-studio&hl=zh-cn#vm-linux
	qemu-full bridge-utils
	# zfs # https://wiki.debian.org/ZFS
	zfs-utils
	# 现代 cli 工具 https://zjusct.pages.zjusct.io/opendocs/operation/system/service/modern_cli/
	aria2 bat btop duf fq fzf fish gdu httpie hyperfine ripgrep
	tmux zoxide zsh
	starship
	# 课程：操作系统 https://zju-sec.github.io/os24fall-stu/lab0
	aarch64-linux-gnu-gcc riscv64-linux-gnu-gcc
	autoconf automake curl bison flex texinfo gperf libtool patchutils bc
	gdb-multiarch
	# 课程：计算机网络
	tcpdump
)

pacman --noconfirm -S "${PACKAGES_COMMON[@]}"
