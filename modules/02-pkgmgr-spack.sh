#!/bin/bash

cat >/etc/profile.d/z00_spack.sh <<EOF
spack() {
    export https_proxy="$CACHE_PROXY_EX"
    export http_proxy="$CACHE_PROXY_EX"
    command spack "\$@"
}
EOF

# fish
cat >/etc/fish/conf.d/z00_spack.fish <<EOF
spack() {
    export https_proxy="$CACHE_PROXY_EX"
    export http_proxy="$CACHE_PROXY_EX"
    command spack "\$@"
}
EOF


