#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"
set -xe

docker compose down

rm -rf /pxe/rootfs/debian/*.2*
rm -rf /pxe/rootfs/ubuntu/*.2*
rm -rf /pxe/rootfs/openEuler/*.2*
rm -rf /pxe/rootfs/arch/*.2*
