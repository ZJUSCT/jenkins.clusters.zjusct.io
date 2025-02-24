#!/bin/bash

cat >/etc/profile.d/z00_spack.sh <<EOF
spack() {
    export https_proxy="http://storage:3128"
    export http_proxy="http://storage:3128"
    if ! type -P spack >/dev/null 2>&1; then
        local _spack_def
        _spack_def=\$(declare -f spack)
        unset -f spack
        . ~/spack/share/spack/setup-env.sh
        eval "\$_spack_def"
    fi
    command spack \$@
}
EOF

# # fish
# cat >/etc/fish/conf.d/z00_spack.fish <<EOF
# spack() {
#     export https_proxy="http://storage:3128"
#     export http_proxy="http://storage:3128"
#     command spack "\$@"
# }
# EOF

