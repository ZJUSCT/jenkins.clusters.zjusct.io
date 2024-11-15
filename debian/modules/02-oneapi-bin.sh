#!/bin/bash
# https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-linux/
ONEAPI_BASE=http://storage/intel-oneapi-base-toolkit.sh
# ONEAPI_HPC=http://storage/intel-oneapi-hpc-toolkit.sh
tmpfile=$(mktemp -u).sh

wget "$ONEAPI_BASE" -O "$tmpfile"
sh "$tmpfile" -a --silent --eula accept
rm -f "$tmpfile"

# wget "$ONEAPI_HPC" -O "$tmpfile"
# sh "$tmpfile" -a --silent --eula accept
# rm -f "$tmpfile"
