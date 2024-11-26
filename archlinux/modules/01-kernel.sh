#!/usr/bin/env bash

# Visit: https://wiki.archlinux.org/title/Kernel to choose a flavor
pacman --noconfirm -S dracut linux linux-headers
pacman --noconfirm -S nfs-utils

KERNEL_VERSION=$(pacman -Q linux | awk '{print $2}' | sed 's/\(.*\)\.\(arch1-1\)/\1-\2/')
dracut --list-modules --kver "$KERNEL_VERSION"
dracut --add "base network nfs overlayfs" --kver "$KERNEL_VERSION" --force --no-hostonly
