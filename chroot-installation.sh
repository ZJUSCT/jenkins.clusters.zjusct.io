#!/bin/bash

set -x

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"

if [ "$#" -lt 1 ]; then
	echo "Usage: $0 <DISTRO> [RELEASE]"
	exit 1
fi

#################
# Configuration #
#################
DEBUG=true
MIRROR=https://mirrors.zju.edu.cn/
# use squid caching proxy
CACHE_PROXY=http://squid:3128
CHROOT_BASE=/pxe/rootfs
# TODO: change private file into modules
PRIVATE_BASE=/pxe/private/

INIT=$(ps --no-headers -o comm 1)
TIMESTAMP=$(date +%Y%m%dT%H%M%S%Z)
ARCH=$(dpkg --print-architecture)

DISTRO=$1
RELEASE=$2

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
echo "Bootstraping $DISTRO $RELEASE into $CHROOT_TARGET now."
set -e
trap cleanup_all INT TERM EXIT

CHROOT_BASE=$CHROOT_BASE/$DISTRO/$RELEASE
CHROOT_TARGET=$CHROOT_BASE.$TIMESTAMP
mkdir -p "$CHROOT_TARGET"
# workaround #844220 / #872812
chmod +x "$CHROOT_TARGET"

make_rootfs
cp /usr/local/share/ca-certificates/bump.crt "$CHROOT_TARGET"/root/bump.crt

###################
# Modular Scripts #
###################

# choose chroot method
case $INIT in
systemd)
	# use systemd-nspawn
	CHROOT_METHOD=systemd
	;;
tini)
	CHROOT_METHOD=chroot
	;;
*)
	echo "Unsupported init system."
	exit 1
	;;
esac

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
"

for script in modules/*; do
	echo "Debug: Running $script."
	prepare_module "$script"
	execute_module
done

# private files
rsync -a "$PRIVATE_BASE"/ "$CHROOT_TARGET"/

echo "Debug: Cleanup fine"
cleanup_all fine
