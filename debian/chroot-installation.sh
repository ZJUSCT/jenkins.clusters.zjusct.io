#!/bin/bash
# vim: set noexpandtab:

# Copyright 2012-2024 Holger Levsen <holger@layer-acht.org>
#           2018-2023 Mattia Rizzolo <mattia@debian.org>
#           2024-2025 Baolin Zhu <zhubaolin228@gmail.com> and ZJUSCT
#
# The following code is a derivative work of the code from the jenkins.debian.net,
# which is licensed GPLv2. This code therefore is also licensed under the terms
# of the GNU Public License, verison 2.

set -x

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"

# $1 = distro
# $2 = release

if [ "$#" -ne 2 ]; then
	cat <<-EOF
		usage: $0 <distro> <release>
		<distro>:
			- debian
			- ubuntu
		<release>:
			- debian:
				- stable
				- testing
				- sid
			- ubuntu:
				- oracular
				- noble
	EOF
	exit 1
fi

if [ "$1" == "debian" ]; then
	case $2 in
	# stable, testing, unstable
	stable | testing | sid) ;;
	*)
		echo "unsupported release."
		exit 1
		;;
	esac
elif [ "$1" == "ubuntu" ]; then
	case $2 in
	# latest release, latest LTS
	oracular | noble) ;;
	*)
		echo "unsupported release."
		exit 1
		;;
	esac
else
	echo "unsupported distro."
	exit 1
fi
DISTRO="$1"
RELEASE="$2"

DEBUG=false
. common-functions.sh
common_init "$@"
set -e

CHROOT_BASE=$CHROOT_BASE/$DISTRO/$RELEASE

CHROOT_TARGET=$CHROOT_BASE.$TIMESTAMP
mkdir -p "$CHROOT_TARGET"
chmod +x "$CHROOT_TARGET"   # workaround #844220 / #872812
TMPFILE=/root/$TIMESTAMP.sh # /tmp is mount to tmpfs in systemd-nspawn
CTMPFILE=$CHROOT_TARGET/$TMPFILE
TMPLOG=/tmp/$DISTRO-$RELEASE-$TIMESTAMP.log

cleanup_all() {
	echo "Doing cleanup now."
	echo "Debug: Removing trap."
	trap - INT TERM EXIT
	set -x
	if mountpoint -q "$CHROOT_TARGET/proc"; then
		umount -l "$CHROOT_TARGET/proc"
	fi
	if mountpoint -q "$CHROOT_TARGET/run"; then
		umount -l "$CHROOT_TARGET/run"
	fi
	if mountpoint -q "$CHROOT_TARGET/tmp"; then
		umount -l "$CHROOT_TARGET/tmp"
	fi
	echo "\$1 = $1"
	rm -f "$TMPLOG"
	if [ "$1" != "fine" ]; then
		# rename to .error
		rm -rf "$CHROOT_BASE".error ||
			fuser -mv "$CHROOT_BASE".error
		mv "$CHROOT_TARGET" "$CHROOT_BASE".error ||
			fuser -mv "$CHROOT_TARGET" "$CHROOT_BASE".error
		echo "Something went wrong, $CHROOT_TARGET is moved to $CHROOT_BASE.error for further inspection."
		exit 1
	else
		# remove .error
		rm -rf "$CHROOT_BASE".error ||
			fuser -mv "$CHROOT_BASE".error
		# rename to .latest
		rm -rf "$CHROOT_BASE".latest ||
			fuser -mv "$CHROOT_BASE".latest
		echo "$CHROOT_TARGET succeeded."
		mv "$CHROOT_TARGET" "$CHROOT_BASE".latest ||
			fuser -mv "$CHROOT_TARGET" "$CHROOT_BASE".latest
		echo "$CHROOT_BASE/$RELEASE.latest can now be released."
	fi
}

execute_ctmpfile() {
	echo "echo xxxxxSUCCESSxxxxx" >>"$CTMPFILE"
	set -x
	chmod +x "$CTMPFILE"
	set -o pipefail # see eg http://petereisentraut.blogspot.com/2010/11/pipefail.html
	# use this is you run on a physical machine with systemd
	# (systemd-nspawn --resolv-conf=replace-stub --hostname="$DISTRO"-"$RELEASE" -D "$CHROOT_TARGET" "$TMPFILE" 2>&1 | tee "$TMPLOG") || true
	# but now we are running in a container, so systemd-nspawn can't be used
	(chroot "$CHROOT_TARGET" "$TMPFILE" 2>&1 | tee "$TMPLOG") || true
	RESULT=$(grep "xxxxxSUCCESSxxxxx" "$TMPLOG" || true)
	if [ -z "$RESULT" ]; then
		echo "Failed to run $TMPFILE in $CHROOT_TARGET."
		exit 1
	fi
	rm "$CTMPFILE"
	set +o pipefail
	set +x
}

trap cleanup_all INT TERM EXIT

echo "Bootstraping $DISTRO $RELEASE into $CHROOT_TARGET now."
set -x
BASIC_PKGS="ca-certificates,curl,wget,jq,dracut"
COMPONENTS=main
case $DISTRO in
debian)
	BASIC_PKGS+=",linux-image-amd64,linux-headers-amd64"
	COMPONENTS+=",contrib,non-free,non-free-firmware"
	;;
ubuntu)
	BASIC_PKGS+=",linux-image-generic,linux-headers-generic"
	COMPONENTS+=",restricted,universe,multiverse"
	;;
esac
mmdebstrap "$RELEASE" "$CHROOT_TARGET" "$MIRROR"/"$DISTRO" \
	--include=$BASIC_PKGS --components=$COMPONENTS
# try fix DNS problem in Ubuntu
mount -o bind /run "$CHROOT_TARGET/run"
mount -t tmpfs tmpfs "$CHROOT_TARGET/tmp"
set +x

prepare_module() {
	# https://www.shellcheck.net/wiki/SC2129
	{
		echo "$SCRIPT_HEADER"
		cat modules-header.sh
		cat "$1"
	} >>"$CTMPFILE"
}

for script in modules/*; do
	echo "Debug: Running $script."
	prepare_module "$script"
	execute_ctmpfile
done

echo "Debug: Cleanup fine"
cleanup_all fine
