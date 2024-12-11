#!/bin/bash
export PATH="/opt/spack/bin:$PATH"
# case $ID in
# arch)
# 	export PATH="/opt/lmod/bin:$PATH"
# 	;;
# esac
spack install openmpi hpl+openmp
