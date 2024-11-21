#!/bin/bash
set -xe
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit 1
fi

MIRROR='https://mirrors.zju.edu.cn/openeuler/'
VERSION='24.09'
RELEASE="openEuler-$VERSION/"
FILEPATH='OS/x86_64/images/install.img'

ROOTIMGPATH='LiveOS/rootfs.img'

CHROOT_BASE=/pxe/rootfs/openeuler
TIMESTAMP=$(date +%Y%m%dT%H%M%S%Z)
CHROOT_TARGET=$CHROOT_BASE/$VERSION.$TIMESTAMP
mkdir -p "$CHROOT_TARGET"
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


wget -O "$IMGFILE" $MIRROR$RELEASE$FILEPATH 
# 7z can also extract squashfs filesystem, but it's very very slow now...
# 7z x "$IMGFILE" -o"$TMPDIR" $ROOTIMGPATH
unsquashfs -d "$TMPDIR" "$IMGFILE" $ROOTIMGPATH
7z x -snld "$TMPDIR/$ROOTIMGPATH" -o"$CHROOT_TARGET"

rm -rf "$TMPDIR"
