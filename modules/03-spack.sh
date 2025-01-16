#!/bin/bash
# spack managed software

# debug: check fs size
df -h
# intel installer needs / to be mounted to get volume information
mount --bind / /

SPACK_PATH="/opt/spack"
export PATH=$SPACK_PATH/bin:$PATH

pkgs=(
	# cuda
	cuda+dev@12.4.0
	# cuda+dev@12.3.0
	# cuda+dev@12.2.0
	cuda+dev@12.1.0
	# cuda+dev@12.0.0
	# cuda+dev@11.8.0
	# cuda+dev@11.7.0
	# cuda+dev@11.6.0
	cuda+dev@11.5.0
	# cuda+dev@11.4.0
	# cuda+dev@11.3.0
	# cuda+dev@11.2.0
	# cuda+dev@11.1.0
	# nvidia-nsight-systems

	# intel
	# warning: intel-* packages are usually deprecated, use intel-oneapi-* instead
	# intel-oneapi-advisor
	# intel-oneapi-dal
	# intel-oneapi-inspector
	intel-oneapi-mkl
	# intel-oneapi-vpl
	intel-oneapi-ccl
	# intel-oneapi-dnn
	# intel-oneapi-ipp
	intel-oneapi-mpi
	intel-oneapi-vtune
	intel-oneapi-compilers
	# intel-oneapi-dpct
	# intel-oneapi-ippcp
	# intel-oneapi-compilers-classic
	# intel-oneapi-dpl
	intel-oneapi-itac
	# intel-oneapi-tbb

	# amd
	# hip

	# others
	mpich
	mvapich2
	openmpi
	scorep
)

spack spec -I "${pkgs[@]}"

# try 20 times to recover from network failure
counter=5
while [ $counter -gt 0 ]; do
	spack install "${pkgs[@]}" && break
	counter=$((counter - 1))
	sleep 1
done

umount /
