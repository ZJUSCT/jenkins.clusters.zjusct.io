#!/bin/bash

debian=(
	7zip
	aptitude
	autotools-dev
	binutils-dev
	build-essential
	clangd
	clang-format
	clang-format
	clang-tidy
	clang-tidy
	cpu-checker
	devscripts
	fd-find
	fonts-firacode
	gcc-aarch64-linux-gnu
	gcc-doc
	gcc-doc
	gcc-riscv64-linux-gnu
	gfortran
	glibc-doc
	glibc-doc
	golang
	libdrm-dev
	libexpat-dev
	libgmp-dev
	libgmp-dev
	libgtk-3-dev
	libmpc-dev
	libmpfr-dev
	libomp-dev
	libpcap-dev
	libpcap-dev
	libssl-dev
	libvirt-clients
	libvirt-daemon-system
	linux-source
	mmdebstrap
	network-manager
	ninja-build
	opensbi
	pipx
	proxychains4
	python-is-python3
	qemu-kvm
	qemu-system-misc
	rename
	rpm2cpio
	rustc
	snmp
	systemd-container
	tshark
	tshark
	u-boot-qemu
	wireshark
	zlib1g-dev
	# with arch
	aria2
	bat
	btop
	ccls
	cpufetch
	duf
	exfatprogs
	fq
	fzf
	gdb-multiarch
	gdu
	git-extras
	git-lfs
	httpie
	hugo
	hyperfine
	lldpd
	locate
	neofetch
	nvtop
	ripgrep
	screenfetch
	stress
	unrar
	zoxide
)

ubuntu=("${debian[@]}")

case $ID in
debian)
	debian+=(linux-perf linux-cpupower)
	case $RELEASE in
	stable)
		debian+=(exa jenkins-job-builder opensm)
		;;
	testing)
		debian+=(eza gping)
		;;
	esac
	;;
ubuntu)
	ubuntu+=(linux-tools-common eza gping opensm)
	case $RELEASE in
	oracular)
		ubuntu+=(linux-cpupower)
		;;
	esac
	;;
esac

arch=(
	binutils
	linux
	linux-headers
	nfs-utils
	# with debian
	aria2
	bat
	btop
	ccls
	cpufetch
	duf
	exfatprogs
	fq
	fzf
	gdu
	git-extras
	git-lfs
	httpie
	hugo
	hyperfine
	lldpd
	locate
	neofetch
	nvtop
	ripgrep
	screenfetch
	stress
	unrar
	zoxide
)

openEuler=(
	binutils-devel
)

# check if ${ID} is defined
if [ -n "${!ID}" ]; then
	eval "install_pkg \"\${${ID}[@]}\""
fi

# # bat
# if [ ! -e /usr/bin/bat ]; then
# 	ln -s /usr/bin/batcat /usr/bin/bat
# fi
# # fd-find
# if [ ! -e /usr/bin/fd ]; then
# 	ln -s /usr/bin/fdfind /usr/bin/fd
# fi
