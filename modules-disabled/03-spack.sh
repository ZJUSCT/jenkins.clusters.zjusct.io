#!/bin/bash
export PATH="/opt/spack/bin:$PATH"
case $ID in
openEuler)
	# TODO: checking for openssl/ssl.h... no
	;;
arch)
	# TODO: the key "core_compilers" must be set in modules.yaml
	;;
*)
	spack install openmpi hpl+openmp
	;;
esac
