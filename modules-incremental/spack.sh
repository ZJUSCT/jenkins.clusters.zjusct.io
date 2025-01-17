#!/bin/bash
# spack managed software, incremental only

# debug: check fs size
df -h
# intel installer needs / to be mounted to get volume information
mount --bind / /

SPACK_PATH="/opt/spack"
export PATH=$SPACK_PATH/bin:$PATH

pkgs=(
	# cuda
	# note: A100 80GB PCIe supports cuda 11.4 or later
	# https://docs.nvidia.com/deploy/cuda-compatibility/
	cuda
	# cuda@12.6.3
	# cuda@12.5.0
	# cuda@12.4.0
	# cuda@12.3.0
	# cuda@12.2.0
	# cuda@12.1.0
	# cuda@12.0.0
	# cuda@11.8.0
	# cuda@11.7.0
	# cuda@11.6.0
	# cuda@11.5.0
	# cuda@11.4.0
	nvidia-nsight-systems

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
	# scorep # due to https://github.com/spack/spack/issues/43700
)

spack spec -I "${pkgs[@]}"

# try 20 times to recover from network failure
counter=5
while [ $counter -gt 0 ]; do
	spack install --dont-restage --show-log-on-error -v -y \
		"${pkgs[@]}" && break
	counter=$((counter - 1))
	sleep 1
done

umount /
