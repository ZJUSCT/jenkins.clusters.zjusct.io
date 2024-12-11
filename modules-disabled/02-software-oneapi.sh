#!/bin/bash
# https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-linux/
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB |
	gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg >/dev/null

# add signed entry to apt sources and configure the APT client to use Intel repository:
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list

apt-get update

apt-get install intel-oneapi-hpc-toolkit intel-oneapi-base-toolkit

/opt/intel/oneapi/modulefiles-setup.sh --output-dir=/opt/intel/oneapi/modulefiles
echo "/opt/intel/oneapi/modulefiles" >/etc/lmod/.modulespath

# deprecated, see https://git.zju.edu.cn/zjusct/ops/conf-diskless/-/issues/1
# INSTALL_DIR=/opt/intel
# cd "${INSTALL_DIR}//oneapi/vtune/latest/sepdk/src" || exit
# ./build-driver --non-interactive \
# 	--kernel-version="$KERNEL_VERSION" \
# 	--kernel-src-dir="/usr/src/linux-headers-${KERNEL_VERSION//-amd64/}-common"
# ./rmmod-sep -s
# ./insmod-sep --no-udev || true
# ./boot-script --install
