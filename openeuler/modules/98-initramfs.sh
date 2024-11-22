#!/bin/bash
dnf install dracut dracut-network nfs-utils

dracut --list-modules --kver "$KERNEL_VERSION"
dracut --add "base network nfs overlayfs" --kver "$KERNEL_VERSION" --force  --no-hostonly
