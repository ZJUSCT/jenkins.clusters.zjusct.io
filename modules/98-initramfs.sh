#!/bin/bash

install_pkg dracut

case $ID in
debian | ubuntu)
	install_pkg dracut-network
	;;
openEuler)
	install_pkg dracut-network nfs-utils
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

# options nvidia NVreg_RestrictProfilingToAdminUsers=0 for nvidia driver

cat > /etc/modprobe.d/nvidia-perf.conf <<EOF
options nvidia NVreg_RestrictProfilingToAdminUsers=0
EOF

if $DEBUG; then
	dracut --list-modules --kver "$KERNEL_VERSION"
fi
dracut \
	--add "base network nfs overlayfs" \
	--omit "iscsi" \
	--kver "$KERNEL_VERSION" --force

case $ID in
arch)
	cp "/usr/lib/modules/$KERNEL_VERSION/vmlinuz" "/boot/vmlinuz-$KERNEL_VERSION"
esac
