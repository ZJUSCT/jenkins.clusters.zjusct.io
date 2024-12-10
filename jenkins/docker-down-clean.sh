#!/bin/bash

set -xe

docker compose down
sudo rm -rf /pxe/rootfs/debian/*.2*
sudo rm -rf /pxe/rootfs/ubuntu/*.2*
sudo rm -rf /pxe/rootfs/openEuler/*.2*
sudo rm -rf /pxe/rootfs/arch/*.2*
