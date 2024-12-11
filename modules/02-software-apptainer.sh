#!/bin/bash

case $ID in
debian|ubuntu)
	install_pkg_from_github apptainer/apptainer 'contains("apptainer")'
	;;
arch)
	pacman -S apptainer
	;;
*)
	echo "Warning: apptainer needs support in $ID"
	;;
esac
