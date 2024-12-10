#!/bin/bash
# https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html
# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/
# https://developer.nvidia.com/cuda-downloads
NVIDIA_VERSION_DEBIAN=debian12/x86_64
NVIDIA_VERSION_UBUNTU=ubuntu2404/x86_64

case $ID in
debian)
	install_deb_from_url https://developer.download.nvidia.com/compute/cuda/repos/$NVIDIA_VERSION_DEBIAN/cuda-keyring_1.1-1_all.deb
	;;
ubuntu)
	install_deb_from_url https://developer.download.nvidia.com/compute/cuda/repos/$NVIDIA_VERSION_UBUNTU/cuda-keyring_1.1-1_all.deb
	;;
esac
apt-get update

# apt-get install cuda # NVIDIA's apt repository contains conflict itself
#
# cuda
# |
# +-----------+-----------+
# |                       |
# cuda-12-6               nvidia-open (is 565.57.01)
# |                       |
# cuda-runtime-12-6       |
# |                       ↓
# nvidia-open-560 -->!!! conflict !!!
apt-get install cuda-toolkit-12-6 # from cuda download page
