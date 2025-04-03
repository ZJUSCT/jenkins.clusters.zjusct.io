#!/usr/bin/env bash

# https://www.intel.com/content/www/us/en/developer/articles/code-sample/vtune-profiler-sampling-driver-downloads.html
# https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2024-2/build-install-sampling-drivers-for-linux-targets.html

set -x

export

URL="https://cdrdv2.intel.com/v1/dl/getContent/778889"
case $DISTRO in
debian|ubuntu)
	KERNEL_SRC_DIR="/usr/src/linux-headers-${KERNEL_VERSION}"
	;;
*)
	KERNEL_SRC_DIR="/usr/src/linux-headers-${KERNEL_VERSION}"
	;;
esac

cd /tmp || exit 1
wget "$URL" -O vtune.tar.gz
mkdir -p /opt/intel/vtune/sepdk
tar -xzf vtune.tar.gz -C /opt/intel/vtune/sepdk --strip-components=1
cd /opt/intel/vtune/sepdk/src || exit 1
./build-driver --non-interactive \
	--kernel-version="$KERNEL_VERSION" \
	--kernel-src-dir="$KERNEL_SRC_DIR"
# ./rmmod-sep -s
./insmod-sep --no-udev
./boot-script --install
