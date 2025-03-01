#!/bin/bash

cat >/etc/profile.d/z00_spack.sh <<EOF
spack() {
    export old_https_proxy=\$https_proxy
    export old_http_proxy=\$http_proxy
    export https_proxy="http://storage:8083"
    export http_proxy="http://storage:8083"
    
    if ! type _spack_shell_wrapper >/dev/null 2>&1; then
        local _spack_def
        _spack_def=\$(declare -f spack)
        unset -f spack

        if [ -f ~/spack/share/spack/setup-env.sh ]; then
            . ~/spack/share/spack/setup-env.sh
        else
            . /pxe/opt/spack/share/spack/setup-env.sh
        fi

        eval "\$_spack_def"
    fi

    _spack_shell_wrapper "\$@"
    export https_proxy=\$old_https_proxy
    export http_proxy=\$old_http_proxy
    unset old_https_proxy
    unset old_http_proxy
    return \$?
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

