#!/bin/bash

set -xe

docker compose down
sudo rm -rf /pxe/rootfs/debian/*.2*
sudo rm -rf /pxe/rootfs/ubuntu/*.2*
