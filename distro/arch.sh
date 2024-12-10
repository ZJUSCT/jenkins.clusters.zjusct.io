#!/usr/bin/env bash
# Running Arch Linux on HPC Cluster?
# Why not! :evil:
# Latest kernel, More packages, Arch is all you need!

# https://wiki.archlinux.org/title/Pacstrap
PREREQUISITES+=(arch-install-scripts wget zstd)

check_release() {
	# Since Arch Linux is a rolling update distro
	# It's not a good idea to stick to some specific 'version'
	if [ -n "$RELEASE" ]; then
		echo "Warning: Arch Linux is a rolling release distro."
		echo "Warning: Ignoring the release version $RELEASE."
	fi
	RELEASE=rolling
}

make_rootfs() {
	# Arch Linux requires the bootstrap tarball method for creating a rootfs
	# https://wiki.archlinux.org/title/Install_Arch_Linux_from_existing_Linux#Method_A:_Using_the_bootstrap_tarball_(recommended)
	IMAGEURL="$MIRROR/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.zst"
	ROOTIMGPATH='root.x86_64'
	TMPDIR=/tmp/archlinux-$TIMESTAMP
	mkdir -p "$TMPDIR"
	IMGFILE=$TMPDIR/archlinux-bootstrap-x86_64.tar.zst

	wget --tries=5 --quiet -O "$IMGFILE" "$IMAGEURL"
	# Extract the Arch Linux bootstrap tarball
	tar xf "$IMGFILE" -C "$CHROOT_TARGET" --numeric-owner

	# Copy from $CHROOT_TARGET/$ROOTIMGPATH to $CHROOT_TARGET
	mv "$CHROOT_TARGET/$ROOTIMGPATH"/* "$CHROOT_TARGET/"
	rmdir "$CHROOT_TARGET/$ROOTIMGPATH"

	echo "rootfs is extracted to $CHROOT_TARGET."
}
