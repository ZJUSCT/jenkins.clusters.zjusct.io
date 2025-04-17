#!/bin/bash

debian() {
	install_pkg zfs-dkms zfsutils-linux
}

ubuntu() {
	debian
}

check_and_exec "$ID"
