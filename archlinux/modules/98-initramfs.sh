#!/usr/bin/env bash

KERNEL_VERSION=$(pacman -Q linux | awk '{print $2}' | sed 's/\(.*\)\.\(arch1-1\)/\1-\2/')

dracut --list-modules --kver "$KERNEL_VERSION"
dracut --add "base network nfs overlayfs" --kver "$KERNEL_VERSION" --force --no-hostonly
cp "/usr/lib/modules/$KERNEL_VERSION/vmlinuz" "/boot/vmlinuz-$KERNEL_VERSION"
