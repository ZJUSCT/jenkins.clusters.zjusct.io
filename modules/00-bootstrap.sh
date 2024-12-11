#!/bin/bash

bootstrap_all() {
	# default console password, will be superseeded when SSSD is setup
	echo "root:root" | chpasswd

	# fix dns problem for specific distros
	if [ "$INIT" != "systemd" ]; then
		# https://askubuntu.com/questions/469209/how-to-resolve-hostnames-in-chroot
		case $ID in
		ubuntu | arch)
			rm -f /etc/resolv.conf
			cat >/etc/resolv.conf <<EOF
nameserver 127.0.0.1
nameserver 172.25.2.253
nameserver 10.10.0.21
EOF
			;;
		esac
	fi
}

bootstrap_debian() {
	echo -e '#!/bin/sh\nexit 101' >/usr/sbin/policy-rc.d
	chmod +x /usr/sbin/policy-rc.d
	# configure dpkg to use unsafe io for faster installs
	mkdir -p /etc/dpkg/dpkg.cfg.d
	echo force-unsafe-io >/etc/dpkg/dpkg.cfg.d/02dpkg-unsafe-io

	# apt debug
	if $DEBUG; then
		cat >/etc/apt/apt.conf.d/80debug <<EOF
# solution calculation
Debug::pkgDepCache::Marker "true";
Debug::pkgDepCache::AutoInstall "true";
Debug::pkgProblemResolver "true";
# installation order
Debug::pkgPackageManager "true";
EOF
	fi

	# apt proxy
	if [ -n "$PROXY" ]; then
		cat >/etc/apt/apt.conf.d/80proxy <<EOF
Acquire::http::Proxy "$PROXY";
Acquire::https::Proxy "$PROXY";
EOF
	fi

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

bootstrap_ubuntu() {
	bootstrap_debian
}

bootstrap_openEuler() {
	# workaround for bootstrapping, there is no https support
	mkdir -p /etc/yum.repos.d
	cat >/etc/yum.repos.d/openeuler.repo <<'EOF'
[openEuler]
name=openEuler-$releasever-OS
baseurl=http://mirrors.zju.edu.cn/openeuler/openEuler-$releasever/OS/$basearch/
enabled=1
gpgcheck=0
EOF

	# system-release will introduce repo and keys
	dnf --releasever="$VERSION_ID" \
		--setopt=install_weak_deps=False \
		install ca-certificates rpm openEuler-release
	rm -f /etc/yum.repos.d/openeuler.repo
	sed -i 's/repo.openeuler.org/mirrors.zju.edu.cn\/openeuler/g' /etc/yum.repos.d/openEuler.repo

	# now we have the everything repo
	dnf --releasever="$VERSION_ID" \
		groupinstall core
}

bootstrap_arch() {
	cat >/etc/pacman.d/mirrorlist <<'EOF'
Server = https://mirrors.zju.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
EOF

	cat >/etc/pacman.conf <<'EOF'
[options]
HoldPkg     = pacman glibc
Architecture = auto
Color
CheckSpace
DownloadUser = alpm
DisableSandbox
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist

[archlinuxcn]
Server = https://mirrors.zju.edu.cn/archlinuxcn/$arch
EOF
	# fix for /dev/fd, https://bbs.archlinux.org/viewtopic.php?id=287248
	[ ! -h /dev/fd ] && ln -s /proc/self/fd /dev/fd

	# Workaround to fix "error: could not determine cachedir mount point"
	# Need to be re-enabled at clean
	sed -i 's/^CheckSpace/#CheckSpace/' /etc/pacman.conf

	# Init public keyring
	# gpg: Warning: using insecure memory! is ok to ignore
	# it relates to the security risks of caching of gpg keys on disk
	# https://bbs.archlinux.org/viewtopic.php?id=278170
	# https://bbs.archlinux32.org/viewtopic.php?id=3022
	pacman-key --init &>/dev/null
	pacman-key --populate archlinux &>/dev/null

	# Force update metadata and upgrade packages
	pacman -Syyu &>/dev/null
	pacman -S archlinuxcn-keyring &>/dev/null

	# Visit: https://wiki.archlinux.org/title/Kernel to choose a flavor

	pacman -S --needed git base-devel

	# https://github.com/Jguer/yay
	# from archlinuxcn
	pacman -S yay

	# https://github.com/Morganamilo/paru
	# from archlinuxcn
	pacman -S paru

	# https://github.com/actionless/pikaur
	# from archlinuxcn
	pacman -S pikaur
}

bootstrap_all
check_and_exec bootstrap_"$DISTRO"
