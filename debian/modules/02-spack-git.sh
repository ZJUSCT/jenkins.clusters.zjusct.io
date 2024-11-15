#!/bin/bash

apt-get install bzip2 ca-certificates file g++ gcc gfortran git gzip lsb-release patch python3 tar unzip xz-utils zstd

tmpfile=/tmp/spack.tar.gz
get_asset_from_github "spack/spack" 'startswith("spack-")' "$tmpfile"
tar -C /opt -xzf "$tmpfile"
rm -f "$tmpfile"
mv /opt/spack* /opt/spack

cat >/etc/profile.d/z00_spack.sh <<'EOF'
. /opt/spack/share/spack/setup-env.sh
EOF
cat >/etc/profile.d/z00_spack.csh <<'EOF'
source /opt/spack/share/spack/setup-env.csh
EOF
cat >/etc/profile.d/z00_spack.fish <<'EOF'
. /opt/spack/share/spack/setup-env.fish
EOF

export PATH=/opt/spack/bin:$PATH

spack compiler find --scope=site
spack external find --scope=site
spack config --scope=site add modules:default:enable:[lmod] 
spack config --scope=site add modules:default:lmod:hide_implicits:true

echo "/opt/spack/share/spack/lmod" > /etc/lmod/.modulespath
