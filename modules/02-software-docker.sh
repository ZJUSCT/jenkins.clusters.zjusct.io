#!/bin/bash
set -x

debian() {
	# https://docs.docker.com/engine/install/ubuntu/
	# https://docs.docker.com/engine/install/debian/
	# https://docs.docker.com/engine/install/linux-postinstall/
	DOCKER_MIRROR=https://mirrors.zju.edu.cn/docker-ce
	# docker does not support debian testing
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
}

ubuntu(){
	debian
}

arch() {
	# https://wiki.archlinux.org/title/Docker
	pacman -S docker docker-buildx docker-compose containerd
}

config() {
	# align with LDAP
	sed -i '/^docker:/s/:[0-9]*:/:700:/' /etc/group
}

check_and_exec "$ID"
config
