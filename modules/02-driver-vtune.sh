#!/usr/bin/env bash

# https://www.intel.com/content/www/us/en/developer/articles/code-sample/vtune-profiler-sampling-driver-downloads.html
# https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2024-2/build-install-sampling-drivers-for-linux-targets.html

URL="https://cdrdv2.intel.com/v1/dl/getContent/778889"

cd /tmp || exit 1
wget "$URL" -O vtune.tar.gz
mkdir -p /opt/intel/vtune/sepdk
tar -xzf vtune.tar.gz -C /opt/intel/vtune/sepdk --strip-components=1
cd /opt/intel/vtune/sepdk/src || exit 1
./build-driver --non-interactive \
	--kernel-version="$KERNEL_VERSION" \
	--kernel-src-dir="/usr/src/linux-headers-${KERNEL_VERSION//-amd64/}-common" \
# ./rmmod-sep -s
./insmod-sep --no-udev
./boot-script --install
