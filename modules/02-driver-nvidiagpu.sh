#!/bin/bash
# https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html
# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/
# https://developer.nvidia.com/cuda-downloads

debian() {
	NVIDIA_VERSION=${NVIDIA_VERSION:-debian12/x86_64}
	install_pkg_from_url https://developer.download.nvidia.com/compute/cuda/repos/$NVIDIA_VERSION/cuda-keyring_1.1-1_all.deb
	apt-get update
	apt-get install nvidia-open
}

ubuntu() {
	NVIDIA_VERSION=ubuntu2404/x86_64
	debian
}

check_and_exec "$ID"
