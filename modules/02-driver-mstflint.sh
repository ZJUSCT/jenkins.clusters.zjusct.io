#!/bin/bash
# https://github.com/Mellanox/mstflint

# Debian packaged mstflint

case $ID in
debian|ubuntu)
	install_pkg libibmad-dev mstflint
	;;
openEuler)
	install_pkg mstflint
	;;
*)
	install_pkg rdma-core
	get_asset_from_github "Mellanox/mstflint" 'startswith("mstflint")' /tmp/mstflint.tar.gz
	tar xf /tmp/mstflint.tar.gz -C /tmp
	rm -f /tmp/mstflint.tar.gz
	cd /tmp/mstflint* || exit
	./configure
	make -j"$(nproc)"
	make install
	;;
esac
