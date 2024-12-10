#!/bin/bash
# https://pkgs.io/

COMMON_PACKAGES=(
	7zip aptitude aria2 attr autoconf automake autotools-dev bat bc bison
	bridge-utils btop build-essential build-essential cargo ccls chrony clang clang
	clangd clang-format clang-format clang-tidy clang-tidy cmake cmake cpu-checker
	cpufetch curl curl devscripts doxygen dracut duf ethtool exfatprogs fd-find
	fish fish flex fonts-firacode fq fzf gawk gcc-aarch64-linux-gnu gcc-doc gcc-doc
	gcc-riscv64-linux-gnu gdb gdb-multiarch gdu gfortran git git git-extras git-lfs
	glibc-doc glibc-doc golang gperf htop httpie hugo hwinfo hwloc hyperfine iperf3
	ipmitool iptraf-ng jq libdrm-dev libexpat-dev libgmp-dev libgmp-dev
	libgtk-3-dev libmpc-dev libmpfr-dev libomp-dev libpcap-dev libpcap-dev libtool
	libvirt-clients libvirt-daemon-system linux linux-headers linux-source lldb
	lldpd locate mc meson mmdebstrap neofetch net-tools network-manager nfs-utils
	ninja-build numactl nvtop opensbi patchutils pipx pkg-config pkg-config
	proxychains4 qemu-kvm qemu-system-misc rename ripgrep rpm2cpio rustc
	screenfetch snmp squashfs-tools sshfs stress sudo systemd-container tcpdump
	tcpdump texinfo tldr tmux traceroute tree tshark tshark u-boot-qemu unrar
	valgrind vim wget wireshark zfsutils-linux zip zlib1g-dev zoxide zsh
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
