#!/bin/bash
# https://docs.docker.com/engine/install/ubuntu/
# https://docs.docker.com/engine/install/debian/
# https://docs.docker.com/engine/install/linux-postinstall/
set -x

export http_proxy=$PROXY
export https_proxy=$PROXY
DOCKER_MIRROR=https://mirrors.zju.edu.cn/docker-ce
# docker specific VERSION_CODENAME
case $ID in
debian)
	VERSION_CODENAME=bookworm
	;;
esac

install -m 0755 -d /etc/apt/keyrings
curl $DOCKER_MIRROR/linux/"$ID"/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] $DOCKER_MIRROR/linux/$ID $VERSION_CODENAME stable
EOF
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
