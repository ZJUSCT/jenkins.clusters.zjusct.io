#!/usr/bin/env bash
# Running Arch Linux on HPC Cluster?
# Why not! :evil:
# Latest kernel, More packages, Arch is all you need!

set -xe
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"

DEBUG=true

DISTRO=archlinux
# Since Arch Linux is a rolling update distro
# It's not a good idea to stick to some specific 'version'
if [ -z "$1" ]; then
	RELEASE=arch
else
	RELEASE=$1
fi
CHROOT_BASE=/pxe/rootfs/archlinux/$RELEASE
TIMESTAMP=$(date +%Y%m%dT%H%M%S%Z)
CHROOT_TARGET=$CHROOT_BASE.$TIMESTAMP
INIT=$(ps --no-headers -o comm 1)

mkdir -p "$CHROOT_TARGET"
TMPFILE=/root/$TIMESTAMP.sh
CTMPFILE=$CHROOT_TARGET/$TMPFILE
TMPLOG=/tmp/archlinux-$RELEASE-$TIMESTAMP.log

# https://wiki.archlinux.org/title/Pacstrap
PREREQUISITES=(arch-install-scripts wget zstd)
for pkg in "${PREREQUISITES[@]}"; do
	if ! dpkg -l "$pkg" &>/dev/null; then
		apt-get -qq update
		apt-get -qq install "${PREREQUISITES[@]}"
		break
	fi
done

#############
# bootstrap #
#############

# Arch Linux requires the bootstrap tarball method for creating a rootfs
# https://wiki.archlinux.org/title/Install_Arch_Linux_from_existing_Linux#Method_A:_Using_the_bootstrap_tarball_(recommended)
IMAGEURL="https://mirrors.zju.edu.cn/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.zst"

ROOTIMGPATH='root.x86_64/'
TMPDIR=/tmp/archlinux-$TIMESTAMP
mkdir -p "$TMPDIR"
IMGFILE=$TMPDIR/archlinux-bootstrap-x86_64.tar.zst

wget --tries=5 --quiet -O "$IMGFILE" "$IMAGEURL"

# Extract the Arch Linux bootstrap tarball
tar xf "$IMGFILE" -C "$CHROOT_TARGET" --numeric-owner

# Copy from $CHROOT_TARGET/$ROOTIMGPATH to $CHROOT_TARGET
mv "$CHROOT_TARGET/$ROOTIMGPATH"/* "$CHROOT_TARGET/"
rmdir "$CHROOT_TARGET/$ROOTIMGPATH"

# Patch configurations
cp -rf ./etc/* "$CHROOT_TARGET"/etc

echo "rootfs is extracted to $CHROOT_TARGET."

##########
# chroot #
##########

cleanup_all() {
	echo "Doing cleanup now."
	echo "Debug: Removing trap."
	trap - INT TERM EXIT
	set -x
	case $INIT in
	systemd) # systemd-nspawn handles all mounts
		;;
	*)
		for mount in proc tmp sys dev; do
			if mountpoint -q "$CHROOT_TARGET/$mount"; then
				umount -lR "$CHROOT_TARGET/$mount"
			fi
		done
		;;
	esac
	echo "\$1 = $1"
	rm -f "$TMPLOG"
	if [ "$1" != "fine" ]; then
		set -o pipefail
		# rename to .error
		rm -rf --one-file-system "$CHROOT_BASE".error ||
			fuser -mv "$CHROOT_BASE".error
		mv "$CHROOT_TARGET" "$CHROOT_BASE".error ||
			fuser -mv "$CHROOT_TARGET" "$CHROOT_BASE".error
		set +o pipefail
		echo "Something went wrong, $CHROOT_TARGET is moved to $CHROOT_BASE.error for further inspection."
		exit 1
	else
		set -o pipefail
		# remove .error
		rm -rf --one-file-system "$CHROOT_BASE".error ||
			fuser -mv "$CHROOT_BASE".error
		# rename to .latest
		rm -rf --one-file-system "$CHROOT_BASE".latest ||
			fuser -mv "$CHROOT_BASE".latest
		echo "$CHROOT_TARGET succeeded."
		mv "$CHROOT_TARGET" "$CHROOT_BASE".latest ||
			fuser -mv "$CHROOT_TARGET" "$CHROOT_BASE".latest
		set +o pipefail
		echo "$CHROOT_BASE.latest can now be released."
	fi
}

execute_ctmpfile() {
	echo "echo xxxxxSUCCESSxxxxx" >>"$CTMPFILE"
	set -x
	chmod +x "$CTMPFILE"
	set -o pipefail
	case $INIT in
	systemd) # use this if you run on a physical machine with systemd
		# Land lock is enabled for pacman
		(systemd-nspawn --resolv-conf=replace-stub --hostname="$DISTRO"-"$RELEASE" -D "$CHROOT_TARGET" "$TMPFILE" 2>&1 | tee "$TMPLOG") || true
		;;
	*) # running in a container, so systemd-nspawn can't be used
		(chroot "$CHROOT_TARGET" "$TMPFILE" 2>&1 | tee "$TMPLOG") || true
		;;
	esac
	RESULT=$(grep "xxxxxSUCCESSxxxxx" "$TMPLOG" || true)
	if [ -z "$RESULT" ]; then
		echo "Failed to run $TMPFILE in $CHROOT_TARGET."
		exit 1
	fi
	rm "$CTMPFILE"
	set +o pipefail
	set +x
}

if [ -z "$LC_ALL" ]; then
	export LC_ALL=C.UTF-8
fi

export SCRIPT_HEADER="#!/bin/bash
if $DEBUG ; then
	set -x
fi
set -e
export LC_ALL=$LC_ALL
. /etc/os-release"

trap cleanup_all INT TERM EXIT

prepare_module() {
	{
		echo "$SCRIPT_HEADER"
		cat modules-header.sh
		cat "$1"
	} >>"$CTMPFILE"
}

for script in modules/*; do
	echo "Debug: Running $script."
	prepare_module "$script"
	execute_ctmpfile
done

echo "Debug: Cleanup fine"
cleanup_all fine
