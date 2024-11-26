#!/usr/bin/env bash
# https://wiki.archlinux.org/title/Docker

set -x

PROXY=http://172.25.2.253:7890
export http_proxy=$PROXY
export https_proxy=$PROXY

pacman --noconfirm -S docker docker-buildx docker-compose containerd

mkdir -p /etc/docker
cat >/etc/docker/daemon.json <<EOF
{
        "proxies": {
                "http-proxy": "$http_proxy",
                "https-proxy": "$https_proxy",
                "no-proxy": ""
        },
        "log-opts": {
                "tag": "container.name={{.Name}} container.id={{.ID}} container.image.name={{.ImageName}} container.runtime={{.DaemonName}}"
        }
}
EOF

# align with LDAP
sed -i '/^docker:/s/:[0-9]*:/:700:/' /etc/group
