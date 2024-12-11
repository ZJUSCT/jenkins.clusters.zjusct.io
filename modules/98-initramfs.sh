#!/bin/bash

install_pkg dracut

case $ID in
debian | ubuntu | openEuler)
	install_pkg dracut-network
	;;
arch)
	KERNEL_VERSION=$(pacman -Q linux | awk '{print $2}' | sed 's/\(.*\)\.\(arch1-1\)/\1-\2/')
esac

# from debian source
# https://salsa.debian.org/debian/dracut/-/tree/master/debian/90overlay-root?ref_type=heads
if [ ! -d /usr/lib/dracut/modules.d/90overlay-root ]; then
	mkdir /usr/lib/dracut/modules.d/90overlay-root
	wget -O /usr/lib/dracut/modules.d/90overlay-root/module-setup.sh https://salsa.debian.org/debian/dracut/-/raw/master/debian/90overlay-root/module-setup.sh
	wget -O /usr/lib/dracut/modules.d/90overlay-root/overlay-mount.sh https://salsa.debian.org/debian/dracut/-/raw/master/debian/90overlay-root/overlay-mount.sh
	wget -O /usr/lib/dracut/modules.d/90overlay-root/README https://salsa.debian.org/debian/dracut/-/raw/master/debian/90overlay-root/README
fi

if $DEBUG; then
	dracut --list-modules --kver "$KERNEL_VERSION"
fi
dracut --add "base network nfs overlayfs" --kver "$KERNEL_VERSION" --force

case $ID in
arch)
	cp "/usr/lib/modules/$KERNEL_VERSION/vmlinuz" "/boot/vmlinuz-$KERNEL_VERSION"
esac
