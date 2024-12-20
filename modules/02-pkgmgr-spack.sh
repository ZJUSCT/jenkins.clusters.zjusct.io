#!/bin/bash
# https://spack.readthedocs.io/en/latest/getting_started.html
SPACK_PATH="/opt/spack"

case $ID in
debian | ubuntu)
	install_pkg bzip2 ca-certificates file g++ gcc gfortran git gzip lsb-release patch python3 tar unzip xz-utils zstd
	;;
openEuler)
	dnf group install "Development Tools"
	install_pkg gcc-gfortran python3 unzip
esac

tmpfile=/tmp/spack.tar.gz
get_asset_from_github "spack/spack" 'startswith("spack-")' "$tmpfile"
tar -C /opt -xzf "$tmpfile"
rm -f "$tmpfile"
mv /opt/spack* "$SPACK_PATH"

# bash, zsh
cat >/etc/profile.d/z00_spack.sh <<EOF
. $SPACK_PATH/share/spack/setup-env.sh
EOF
# fish
cat >/etc/fish/conf.d/z00_spack.fish <<EOF
. $SPACK_PATH/share/spack/setup-env.fish
EOF

export PATH=$SPACK_PATH/bin:$PATH

spack compiler find --scope=site
spack external find --scope=site
spack config --scope=site add modules:default:enable:[lmod]
spack config --scope=site add modules:default:lmod:hide_implicits:true

mkdir -p /etc/lmod
echo "$SPACK_PATH/share/spack/lmod" >/etc/lmod/.modulespath
