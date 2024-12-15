#!/bin/bash

debian() {
	# https://wiki.debian.org/RDMA
	install_pkg rdma-core mstflint perftest libibverbs1 librdmacm1 \
		libibmad5 libibumad3 librdmacm1 ibverbs-providers rdmacm-utils \
		infiniband-diags libfabric1 ibverbs-utils
	if ! [[ $RELEASE == "testing" ]]; then
		install_pkg ibutils
	fi
}

ubuntu() {
	debian
}

arch() {
	install_pkg rdma-core
}

openEuler() {
	install_pkg rdma-core
}

check_and_exec "$ID"
