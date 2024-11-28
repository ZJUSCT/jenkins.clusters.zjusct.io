#!/usr/bin/env bash

# Visit: https://wiki.archlinux.org/title/Kernel to choose a flavor
pacman --noconfirm -S dracut linux linux-headers
pacman --noconfirm -S nfs-utils
