#!/bin/bash
# https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html
# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/
# https://developer.nvidia.com/cuda-downloads

debian() {
	NVIDIA_VERSION=${NVIDIA_VERSION:-debian12/x86_64}
	# check if cuda-keyring is installed
	# if not, install it
	if ! dpkg -l | grep -q cuda-keyring; then
		install_pkg_from_url https://developer.download.nvidia.com/compute/cuda/repos/"$NVIDIA_VERSION"/cuda-keyring_1.1-1_all.deb
		apt-get update
	fi
	apt-get install nvidia-open
	apt-get install nvidia-container-toolkit
}

ubuntu() {
	NVIDIA_VERSION=ubuntu2404/x86_64
	debian
}

arch() {
	# AMD, YES
	# https://wiki.archlinux.org/title/NVIDIA
	pacman -S nvidia-open
}

openEuler()
{
	# https://forum.openeuler.org/t/topic/979
	echo "not planned"
}

check_and_exec "$ID"
