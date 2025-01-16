#!/bin/bash

set -xe

docker compose down
docker compose rm -f

# clean volumes
sudo rm -rf jenkins/jenkins_home
sudo rm -rf squid/squid_cache

sudo rm -rf /pxe/rootfs/debian/*.2*
sudo rm -rf /pxe/rootfs/ubuntu/*.2*
sudo rm -rf /pxe/rootfs/openEuler/*.2*
sudo rm -rf /pxe/rootfs/arch/*.2*
