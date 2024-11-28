#!/usr/bin/env bash

KERNEL_VERSION=$(pacman -Q linux | awk '{print $2}' | sed 's/\(.*\)\.\(arch1-1\)/\1-\2/')

# picked from debian source:
# dracut rootfs overlayfs module
#
# Make any rootfs ro, but writable via overlayfs.
# This is convenient, if for example using an ro-nfs-mount.
#
# Add the parameter "rootovl" to the kernel, to activate this feature
#
# This happens pre-pivot. Therefore the final root file system is already
# mounted. It will be set ro, and turned into an overlayfs mount with an
# underlying tmpfs.
#
# The original root and the tmpfs will be mounted at /live/image and
# /live/cow in the final rootfs.

mkdir /usr/lib/dracut/modules.d/90overlay-root
cat >/usr/lib/dracut/modules.d/90overlay-root/module-setup.sh <<'EOF'
#!/bin/bash

check() {
    # do not add modules if the kernel does not have overlayfs support
    [ -d /lib/modules/$kernel/kernel/fs/overlayfs ] || return 1
}

depends() {
    # We do not depend on any modules - just some root
    return 0
}

# called by dracut
installkernel() {
    hostonly='' instmods overlay
}

install() {
    inst_hook pre-pivot 10 "$moddir/overlay-mount.sh"
}
EOF
cat >/usr/lib/dracut/modules.d/90overlay-root/overlay-mount.sh <<'EOF'
#!/bin/sh

# make a read-only nfsroot writeable by using overlayfs
# the nfsroot is already mounted to $NEWROOT
# add the parameter rootovl to the kernel, to activate this feature

. /lib/dracut-lib.sh

if ! getargbool 0 rootovl ; then
    return
fi

modprobe overlay

# a little bit tuning
mount -o remount,nolock,noatime $NEWROOT

# Move root
# --move does not always work. Google >mount move "wrong fs"< for
#     details
mkdir -p /live/image
mount --bind $NEWROOT /live/image
umount $NEWROOT

# Create tmpfs
mkdir /cow
mount -n -t tmpfs -o mode=0755 tmpfs /cow
mkdir /cow/work /cow/rw

# Merge both to new Filesystem
mount -t overlay -o noatime,lowerdir=/live/image,upperdir=/cow/rw,workdir=/cow/work,default_permissions overlay $NEWROOT

# Let filesystems survive pivot
mkdir -p $NEWROOT/live/cow
mkdir -p $NEWROOT/live/image
mount --bind /cow/rw $NEWROOT/live/cow
umount /cow
mount --bind /live/image $NEWROOT/live/image
umount /live/image
EOF

dracut --list-modules --kver "$KERNEL_VERSION"
dracut --add "base network nfs overlayfs" --kver "$KERNEL_VERSION" --force
cp "/usr/lib/modules/$KERNEL_VERSION/vmlinuz" "/boot/vmlinuz-$KERNEL_VERSION"
