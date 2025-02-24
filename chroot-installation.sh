#!/bin/bash

set -x

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <DISTRO> [RELEASE] [INCREDIMENTAL]"
	exit 1
fi

#################
# Configuration #
#################
DEBUG=true
MIRROR=https://mirrors.zju.edu.cn/
# use squid caching proxy
PROXY=http://172.25.2.253:7890
CACHE_PROXY=http://squid:3128
CACHE_PROXY_EX=http://172.25.2.11:3128
CHROOT_BASE=/pxe/rootfs
# TODO: change private file into modules
PRIVATE_BASE=/pxe/private/

DISTRO=$1
RELEASE=$2
INCREDIMENTAL=${3:-false}

if $INCREDIMENTAL; then
	TIMESTAMP=incr
else
	TIMESTAMP=$(date +%Y%m%dT%H%M%S%Z)
fi

if [ ! -f "distro/$DISTRO.sh" ]; then
	echo "Unsupported distro."
	exit 1
fi

. common-functions.sh
# shellcheck disable=SC1090
. "distro/$DISTRO.sh"

check_release || {
	echo "unsupported release."
	exit 1
}
common_init "$@"

####################
# Bootstrap System #
####################
CHROOT_BASE=$CHROOT_BASE/$DISTRO/$RELEASE
CHROOT_TARGET=$CHROOT_BASE.$TIMESTAMP
if $INCREDIMENTAL; then
	if [ ! -d "$CHROOT_TARGET" ]; then
		cp -al "$CHROOT_BASE" "$CHROOT_TARGET"
	fi
else
	echo "Bootstraping $DISTRO $RELEASE into $CHROOT_TARGET now."

	mkdir -p "$CHROOT_TARGET"
	# workaround #844220 / #872812
	chmod +x "$CHROOT_TARGET"

	make_rootfs
	cp /usr/local/share/ca-certificates/bump.crt "$CHROOT_TARGET"/root/bump.crt
fi

###################
# Modular Scripts #
###################
trap cleanup_all INT TERM EXIT
set -e

# use these settings in the scripts in the (s)chroots too
export MODULE_HEADER="#!/bin/bash
if $DEBUG ; then
	set -x
fi
set -e
export CHROOT_METHOD=$CHROOT_METHOD
export DEBUG=$DEBUG
export DISTRO=$DISTRO
export RELEASE=$RELEASE
export TIMESTAMP=$TIMESTAMP
export ARCH=$ARCH
export LC_ALL=$LC_ALL
export LC_CTYPE=$LC_CTYPE
export LANG=$LANG
export http_proxy=$CACHE_PROXY
export https_proxy=$CACHE_PROXY
export MIRROR=$MIRROR
export PROXY=$PROXY
export CACHE_PROXY=$CACHE_PROXY
export INCREDIMENTAL=$INCREDIMENTAL
"

if $INCREDIMENTAL; then
	MODULES=(
		modules/00-bootstrap.sh
		modules-incremental/*
		modules/99-clean.sh
	)
else
	MODULES=(modules/*)
fi

for script in "${MODULES[@]}"; do
	echo "Debug: Running $script."
	prepare_module "$script"
	execute_module
done

# private files
if ! $INCREDIMENTAL; then
	rsync -a "$PRIVATE_BASE"/ "$CHROOT_TARGET"/
fi

echo "Debug: Cleanup fine"
cleanup_all fine
