#!/usr/bin/env bash
# https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-linux/

pacman --noconfirm -S intel-oneapi-basekit

# TODO
# Uncomment these after configured lmod
#
# /opt/intel/oneapi/modulefiles-setup.sh --output-dir=/opt/intel/oneapi/modulefiles
# echo "/opt/intel/oneapi/modulefiles" > /etc/lmod/.modulespath
