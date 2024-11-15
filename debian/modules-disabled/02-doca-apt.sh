#!/bin/bash
# https://developer.nvidia.com/doca-downloads
case $ID in
debian)
	export DOCA_URL="https://linux.mellanox.com/public/repo/doca/2.9.0/debian12.5/x86_64/"
	;;
ubuntu)
	export DOCA_URL="https://linux.mellanox.com/public/repo/doca/2.9.0/ubuntu24.04/x86_64/"
	;;
*)
	echo "OS not supported"
	exit 1
esac
	
curl https://linux.mellanox.com/public/repo/doca/GPG-KEY-Mellanox.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/GPG-KEY-Mellanox.pub
echo "deb [signed-by=/etc/apt/trusted.gpg.d/GPG-KEY-Mellanox.pub] $DOCA_URL ./" > /etc/apt/sources.list.d/doca.list

apt-get update
apt-get -y install doca-all
