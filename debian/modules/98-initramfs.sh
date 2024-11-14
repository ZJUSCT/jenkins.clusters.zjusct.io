#!/bin/bash
apt-get install dracut dracut-network

dracut --list-modules --kver "$KERNEL_VERSION"
dracut --add "base network nfs overlayfs" --omit "nouveau" --kver "$KERNEL_VERSION" --force
