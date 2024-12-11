#!/bin/bash

PREREQUISITES+=(mmdebstrap)

check_release() {
	if [ -z "$RELEASE" ]; then
		RELEASE=stable
	fi
	case $RELEASE in
	# stable, testing
	stable | testing) ;;
	*)
		return 1
		;;
	esac
}

make_rootfs() {
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
		--include="$BASIC_PKGS" --components="$COMPONENTS"
}
