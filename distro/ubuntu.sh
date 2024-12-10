#!/bin/bash
. distro/debian.sh

PREREQUISITES+=(ubuntu-keyring)

# override
check_release() {
	if [ -z "$RELEASE" ]; then
		RELEASE=oracular
	fi
	case $RELEASE in
	# latest release, latest LTS
	oracular | noble) ;;
	*)
		return 1
		;;
	esac
}
