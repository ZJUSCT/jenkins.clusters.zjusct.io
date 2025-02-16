#!/bin/bash

debian=(
	7zip
	aptitude
	autotools-dev
	binutils-dev
	build-essential
	clangd
	clang-format
	clang-tidy
	cpu-checker
	devscripts
	fd-find
	fonts-firacode
	gcc-aarch64-linux-gnu
	gcc-doc
	gcc-riscv64-linux-gnu
	gfortran
	glibc-doc
	golang
	libboost-all-dev
	libbz2-dev
	#libcurl4-openssl-dev
	libdrm-dev
	libexpat-dev
	libgflags-dev
	libgoogle-glog-dev
	libgmp-dev
	libgmp-dev
	libgtk-3-dev
	libmpc-dev
	libmpfr-dev
	libmsgpack-cxx-dev
	libmsgpack-dev
	libmsgpackc2
	libomp-dev
	libpcap-dev
	libpcap-dev
	libssl-dev
	liburing-dev
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
	nvtop
	ripgrep
	screenfetch
	stress
	unrar
	zoxide
	attr autoconf automake bc bison bridge-utils cargo chrony
	clang clang cmake cmake curl curl doxygen dracut ethtool
	fish fish flex gawk gdb git git
	gperf htop hwinfo hwloc iperf3 ipmitool iptraf-ng
	jq libtool lldb mc meson net-tools
	numactl patchutils pkg-config pkg-config
	squashfs-tools sshfs sudo tcpdump tcpdump texinfo tldr tmux traceroute
	tree valgrind vim wget zip zsh openssl
	ffmpeg skopeo umoci debootstrap hyperfine iotop
	# Object Introspection https://objectintrospection.org/docs/getting-started
	bison autopoint build-essential cmake flex gawk libboost-all-dev libbz2-dev libcap2-bin libcurl4-gnutls-dev libdouble-conversion-dev libdw-dev libfmt-dev libgflags-dev libgmock-dev libgoogle-glog-dev libgtest-dev libjemalloc-dev libmsgpack-dev libzstd-dev ninja-build pkg-config python3-setuptools sudo xsltproc libboost-all-dev
	# 编译原理 https://github.com/ZJU-CP/tools/blob/main/Dockerfile
	build-essential git wget python3 python3-pip qemu-user flex bison openjdk-17-jdk python3-lark python3-venv python3-toml python3-rich
	# 计算机系统 III https://zju-sys.pages.zjusct.io/sys3/sys3-sp24/lab0
	gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu gcc-riscv64-unknown-elf
	git help2man perl python3 make autoconf g++ flex bison ccache
	libgoogle-perftools-dev numactl perl-doc
	libfl2
	libbz2-dev
	samtools
	libfl-dev
	zlib1g zlib1g-dev
	device-tree-compiler
	npm
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
	nvtop
	ripgrep
	screenfetch
	stress
	unrar
	zoxide
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

openEuler=(
	binutils-devel
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
