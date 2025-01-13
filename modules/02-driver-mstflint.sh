#!/bin/bash
# https://github.com/Mellanox/mstflint

case $ID in
debian|ubuntu)
	install_pkg libibmad-dev
	;;
esac

get_asset_from_github "Mellanox/mstflint" 'startswith("mstflint")' /tmp/mstflint.tar.gz
tar xf /tmp/mstflint.tar.gz -C /tmp
cd /tmp/mstflint* || exit
./configure
make -j"$(nproc)"
make install
