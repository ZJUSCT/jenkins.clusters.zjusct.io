#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"
set -xe

docker compose down
docker compose rm -f

# clean volumes
rm -rf jenkins/jenkins_home
rm -rf squid/squid_cache

# clean certificates
rm -rf squid/squid/bump.crt
rm -rf squid/squid/bump.key

# clean env
rm -rf jenkins/.env
rm -rf job_builder/jenkins_jobs.ini

rm -rf /pxe/rootfs/debian/*.2*
rm -rf /pxe/rootfs/ubuntu/*.2*
rm -rf /pxe/rootfs/openEuler/*.2*
rm -rf /pxe/rootfs/arch/*.2*
