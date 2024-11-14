#!/bin/bash
# vim: set noexpandtab:

# Copyright 2012-2024 Holger Levsen <holger@layer-acht.org>
#           2018-2023 Mattia Rizzolo <mattia@debian.org>
#           2024-2025 Baolin Zhu <zhubaolin228@gmail.com> and ZJUSCT
# 
# The following code is a derivative work of the code from the jenkins.debian.net, 
# which is licensed GPLv2. This code therefore is also licensed under the terms 
# of the GNU Public License, verison 2.

# https://stackoverflow.com/questions/29926773/run-shell-command-in-jenkins-as-root-user
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit 1
fi

PREREQUISITES=(systemd-container systemd-resolved mmdebstrap ubuntu-keyring)
for pkg in "${PREREQUISITES[@]}"; do
	if ! dpkg -l "$pkg" &>/dev/null; then
		apt-get -qq update
		apt-get -qq install "${PREREQUISITES[@]}"
		break
	fi
done

MIRROR=https://mirrors.zju.edu.cn/
PROXY=http://bridge.internal.zjusct.io:7890
CHROOT_BASE=/rootfs/
TIMESTAMP=$(date +%Y%m%dT%H%M%S%Z)

#
# run ourself with the same parameter as we are running
# but run a copy from /tmp so that the source can be updated
# (Running shell scripts fail weirdly when overwritten when running,
#  this hack makes it possible to overwrite long running scripts
#  anytime...)
#
common_init() {
	# some sensible default
	if [ -z "$LC_ALL" ]; then
		export LC_ALL=C.UTF-8
	fi
	echo "===================================================================================="
	echo "$(date) - running $0 on $(hostname), called using \"$*\" as arguments."
	echo "$(date) - actually running \"$(basename "$0")\" (md5sum $(md5sum "$0" | cut -d ' ' -f1))"
	echo
	export MIRROR=$MIRROR
	# do not enable proxy by default
	# if [ -n "$PROXY" ]; then
	# 	export http_proxy=$PROXY
	# 	export https_proxy=$PROXY
	# fi
	if [ ! -d "$CHROOT_BASE" ]; then
		echo "Directory $CHROOT_BASE does not exist, aborting."
		exit 1
	fi
	# use these settings in the scripts in the (s)chroots too
	export SCRIPT_HEADER="#!/bin/bash
	if $DEBUG ; then
		set -x
	fi
	set -e
	export DEBIAN_FRONTEND=noninteractive
	export LC_ALL=$LC_ALL
	# export http_proxy=$http_proxy
	# export https_proxy=$http_proxy
	export PROXY=$PROXY
	export MIRROR=$MIRROR"
	# be more verbose, maybe
	if $DEBUG; then
		export
		set -x
	fi
	set -e
}
