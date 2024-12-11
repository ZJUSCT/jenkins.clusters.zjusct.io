#!/bin/bash

debian(){
	install_pkg_from_github apptainer/apptainer 'contains("apptainer")'
}

ubuntu(){
	debian
}

arch() {
	pacman -S apptainer
}

check_and_exec "$ID"
