#!/bin/bash
# repo is written in /etc/yum.repos.d/openEuler.repo

set -xe
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"

DEBUG=true

DISTRO=openEuler
# $1=RELEASE
if [ -z "$1" ]; then
        RELEASE=24.09
else
        RELEASE=$1
fi
CHROOT_BASE=/pxe/rootfs/openeuler/$RELEASE
TIMESTAMP=$(date +%Y%m%dT%H%M%S%Z)
CHROOT_TARGET=$CHROOT_BASE.$TIMESTAMP
INIT=$(ps --no-headers -o comm 1)

mkdir -p "$CHROOT_TARGET"
TMPFILE=/root/$TIMESTAMP.sh # /tmp is mount to tmpfs in systemd-nspawn
CTMPFILE=$CHROOT_TARGET/$TMPFILE
TMPLOG=/tmp/openeuler-$RELEASE-$TIMESTAMP.log

PREREQUISITES=(dnf rpm)
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

# openEuler's support for rpm sqlite db is not possible, so dnf can't be used
# see https://gitee.com/src-openeuler/rpm/issues/I5MAW5

# mount proc, sys before entering chroot
# https://discussion.fedoraproject.org/t/root-on-nfs-installing-system-using-dnf-installroot/132194

# for dir in proc sys; do
#         mkdir -p "$CHROOT_TARGET"/$dir
#         mount --bind /$dir "$CHROOT_TARGET"/$dir
# done
# 
# dnf --installroot="$CHROOT_TARGET" \
#     --repo=openEuler \
#     --releasever="$RELEASE" \
#     -y groupinstall core

######################
# bootstrap (unpack) #
######################

IMAGEURL="https://mirrors.zju.edu.cn/openeuler/openEuler-$RELEASE/OS/x86_64/images/install.img"

ROOTIMGPATH='LiveOS/rootfs.img'
TMPDIR=/tmp/openeuler-$TIMESTAMP
mkdir -p "$TMPDIR"
IMGFILE=$TMPDIR/install.img

# note: 7zip needs version 24.08 or later
# https://sourceforge.net/p/sevenzip/support-requests/435/
# version 22.01 in debian stable can't extract ext4 filesystem correctly
if ! command -v 7z &>/dev/null; then
	apt-get -qq update
	apt-get -qq install 7zip/stable-backports
fi
PREREQUISITES=(squashfs-tools wget)
for pkg in "${PREREQUISITES[@]}"; do
	if ! dpkg -l "$pkg" &>/dev/null; then
		apt-get -qq update
		apt-get -qq install "${PREREQUISITES[@]}"
		break
	fi
done

wget -O "$IMGFILE" "$IMAGEURL"
# 7z can also extract squashfs filesystem, but it's very very slow now...
# 7z x "$IMGFILE" -o"$TMPDIR" $ROOTIMGPATH
unsquashfs -d "$TMPDIR" "$IMGFILE" $ROOTIMGPATH
7z x -snld "$TMPDIR/$ROOTIMGPATH" -o"$CHROOT_TARGET"
rm -rf "$TMPDIR"

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
		for mount in proc tmp sys; do
			if mountpoint -q "$CHROOT_TARGET/$mount"; then
				umount -l "$CHROOT_TARGET/$mount"
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
	set -o pipefail # see eg http://petereisentraut.blogspot.com/2010/11/pipefail.html
	case $INIT in
	systemd) # use this is you run on a physical machine with systemd
		(systemd-nspawn --resolv-conf=replace-stub --hostname="$DISTRO"-"$RELEASE" -D "$CHROOT_TARGET" "$TMPFILE" 2>&1 | tee "$TMPLOG") || true
		;;
	*) # but now we are running in a container, so systemd-nspawn can't be used
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
	# https://www.shellcheck.net/wiki/SC2129
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
