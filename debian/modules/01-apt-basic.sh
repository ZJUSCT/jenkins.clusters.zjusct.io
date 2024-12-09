#!/bin/bash
# https://pkgs.io/
# https://tracker.debian.org/
# https://packages.ubuntu.com/
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

	# bat
	if [ ! -e /usr/bin/bat ]; then
		ln -s /usr/bin/batcat /usr/bin/bat
	fi
	# fd-find
	if [ ! -e /usr/bin/fd ]; then
		ln -s /usr/bin/fdfind /usr/bin/fd
	fi
}

PACKAGES_COMMON=(
	aptitude build-essential clang clang-format clang-tidy cmake clangd ccls ethtool chrony
	cpu-checker htop iperf3 net-tools rename attr
	cpufetch curl devscripts doxygen exfatprogs fish fonts-firacode gcc-doc
	gfortran git-extras git-lfs glibc-doc hwinfo hwloc ipmitool iptraf-ng jq
	libgmp-dev libgtk-3-dev libpcap-dev linux-source lldb lldpd locate mc meson
	mmdebstrap neofetch network-manager ninja-build numactl nvtop pkg-config
	proxychains4 rpm2cpio screenfetch snmp sudo systemd-container tcpdump tldr
	traceroute tree tshark unrar valgrind vim wget wireshark zip
	squashfs-tools 7zip hugo
	# language and package manager
	golang rustc cargo pipx
	# kvm # https://developer.android.com/studio/run/emulator-acceleration?utm_source=android-studio&hl=zh-cn#vm-linux
	qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
	# zfs # https://wiki.debian.org/ZFS
	zfsutils-linux
	# 现代 cli 工具 https://zjusct.pages.zjusct.io/opendocs/operation/system/service/modern_cli/
	aria2 bat btop duf fd-find fq fzf fish gdu httpie hyperfine ripgrep
	tmux zoxide zsh
	# 课程：操作系统 https://zju-sec.github.io/os24fall-stu/lab0
	gcc-aarch64-linux-gnu gcc-riscv64-linux-gnu
	autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev
	gawk bison flex texinfo gperf libtool patchutils bc
	zlib1g-dev libexpat-dev git
	qemu-system-misc gdb-multiarch opensbi u-boot-qemu
	# 课程：计算机网络
	git cmake gdb build-essential clang clang-tidy clang-format gcc-doc
	pkg-config glibc-doc tcpdump tshark libpcap-dev
)

PACKAGES_PURGE=(
	# deprecated packages
	# net-tools # use iproute2 instead # but jenkins and lots of old tools depend on this...
	"libreoffice*"
	# nvidia-installer-cleanup
)

set_sources_list() {
	rm -f /etc/apt/sources.list
	cat >/etc/apt/sources.list.d/"$ID".sources <<EOF
Types: deb deb-src
URIs: https://mirrors.zju.edu.cn/$ID/
EOF
	case $ID in
	debian)
		if [ "$VERSION_CODENAME" != "sid" ]; then
			cat >>/etc/apt/sources.list.d/"$ID".sources <<EOF
Suites: ${VERSION_CODENAME} ${VERSION_CODENAME}-updates ${VERSION_CODENAME}-backports
EOF
		else # sid
			cat >>/etc/apt/sources.list.d/"$ID".sources <<EOF
Suites: ${VERSION_CODENAME}
EOF
		fi
		cat >>/etc/apt/sources.list.d/"$ID".sources <<EOF
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
		;;
	ubuntu)
		cat >>/etc/apt/sources.list.d/"$ID".sources <<EOF
Suites: ${VERSION_CODENAME} ${VERSION_CODENAME}-updates ${VERSION_CODENAME}-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
		;;
	esac
	apt-get update
}

set_sources_list
apt-get install "${PACKAGES_COMMON[@]}"
install_special_pkgs
apt-get purge "${PACKAGES_PURGE[@]}" >/dev/null 2>&1
apt-get upgrade
