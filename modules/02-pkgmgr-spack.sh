#!/bin/bash
# https://spack.readthedocs.io/en/latest/getting_started.html

# spack is preserved in /home/spack
# here we only configure the environment instead of installing spack

SPACK_PATH="/home/spack/spack"

case $ID in
debian | ubuntu)
	install_pkg bzip2 ca-certificates file g++ gcc gfortran git gzip lsb-release patch python3 tar unzip xz-utils zstd
	;;
openEuler)
	dnf group install "Development Tools"
	install_pkg gcc-gfortran python3 unzip
esac

# bash, zsh
cat >/etc/profile.d/z00_spack.sh <<EOF
. $SPACK_PATH/share/spack/setup-env.sh
EOF
# fish
cat >/etc/fish/conf.d/z00_spack.fish <<EOF
. $SPACK_PATH/share/spack/setup-env.fish
EOF

mkdir -p /etc/lmod
echo "$SPACK_PATH/share/spack/lmod" >/etc/lmod/.modulespath
