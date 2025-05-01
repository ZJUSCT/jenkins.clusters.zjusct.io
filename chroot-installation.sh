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
DEBUG=false
MIRROR=https://mirrors.zju.edu.cn/
PROXY=http://172.25.4.40:6152
CACHE_PROXY=http://trafficserver:8080
CHROOT_BASE=/pxe/rootfs
# TODO: change private file into modules
PRIVATE_BASE=/pxe/private/

DISTRO=$1
RELEASE=$2
TIMESTAMP=$(date +%Y%m%dT%H%M%S%Z)

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

echo "Bootstraping $DISTRO $RELEASE into $CHROOT_TARGET now."

mkdir -p "$CHROOT_TARGET"
# workaround #844220 / #872812
chmod +x "$CHROOT_TARGET"

make_rootfs

# trust the certificate from cache proxy
# need to do in 00-bootstrap.sh
cp /usr/local/share/ca-certificates/bump.crt "$CHROOT_TARGET"/root/bump.crt

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
export MIRROR=$MIRROR
export PROXY=$PROXY
export CACHE_PROXY=$CACHE_PROXY
export http_proxy=$PROXY
export https_proxy=$PROXY
"

MODULES=(modules/*)

for script in "${MODULES[@]}"; do
	echo "Debug: Running $script."
	prepare_module "$script"
	execute_module
done

# private files
rsync -a "$PRIVATE_BASE"/ "$CHROOT_TARGET"/

echo "Debug: Cleanup fine"
cleanup_all fine
