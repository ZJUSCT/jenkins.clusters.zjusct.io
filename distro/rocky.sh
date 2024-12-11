#!/bin/bash
#############
# bootstrap #
#############

# openEuler's support for rpm sqlite db is not possible, so dnf can't be used
# see https://gitee.com/src-openeuler/rpm/issues/I5MAW5

# mount proc, sys before entering chroot
# https://discussion.fedoraproject.org/t/root-on-nfs-installing-system-using-dnf-installroot/132194

# for dir in proc sys; do
#         mkdir -p "$CHROOT_TARGET"/$dir
#         mount --bind /$dir "$CHROOT_TARGET"/$dir
# done
#
# dnf --installroot="$CHROOT_TARGET" \
#     --repo=openEuler \
#     --releasever="$RELEASE" \
#     -y groupinstall core
