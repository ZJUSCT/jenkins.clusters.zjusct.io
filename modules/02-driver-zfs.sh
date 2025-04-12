#!/bin/bash

case $ID in
debian | ubuntu)
	install_pkg zfs-dkms zfsutils-linux
	;;
*)
	echo "Warning: zfs needs support in $ID"
	;;
esac
