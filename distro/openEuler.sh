#!/bin/bash

# note: 7zip needs version 24.08 or later
# https://sourceforge.net/p/sevenzip/support-requests/435/
# version 22.01 in debian stable can't extract ext4 filesystem correctly
PREREQUISITES+=(squashfs-tools wget 7zip/stable-backports)

check_release() {
	case $RELEASE in
	24.09)
		return 0
		;;
	*)
		return 1
		;;
	esac
}

make_rootfs() {
	IMAGEURL="https://mirrors.zju.edu.cn/openeuler/openEuler-$RELEASE/OS/x86_64/images/install.img"

	ROOTIMGPATH='LiveOS/rootfs.img'
	TMPDIR=/tmp/openeuler-$TIMESTAMP
	mkdir -p "$TMPDIR"
	IMGFILE=$TMPDIR/install.img

	wget --tries=5 --quiet -O "$IMGFILE" "$IMAGEURL"
	# 7z can also extract squashfs filesystem, but it's very very slow now...
	# 7z x "$IMGFILE" -o"$TMPDIR" $ROOTIMGPATH
	unsquashfs -q -d "$TMPDIR" "$IMGFILE" $ROOTIMGPATH
	7z x -snld "$TMPDIR/$ROOTIMGPATH" -o"$CHROOT_TARGET"
	rm -rf "$TMPDIR"

	echo "rootfs is extracted to $CHROOT_TARGET."
}
