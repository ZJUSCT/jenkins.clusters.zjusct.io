#!/bin/bash
set -x

##########
# docker #
##########
# group should be created before installing docker
# so that files can be created with the correct group
# GID should be the same as LDAP
if ! getent group docker; then
	groupadd --gid 700 docker
else
	groupmod --gid 700 docker
fi

debian_docker() {
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

	install_pkg docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

ubuntu_docker() {
	debian_docker
}

arch_docker() {
	# https://wiki.archlinux.org/title/Docker
	install_pkg docker docker-buildx docker-compose containerd
}

openEuler_docker() {
	install_pkg docker
}

check_and_exec "$ID"_docker

mkdir -p /etc/docker
cat >/etc/docker/daemon.json <<EOF
{
    "proxies": {
    "http-proxy":  "${PROXY}",
    "https-proxy": "${PROXY}",
    "no-proxy": ""
  },
  "log-opts": {
    "tag": "container.name={{.Name}} container.id={{.ID}} container.image.name={{.ImageName}} container.runtime={{.DaemonName}}"
  }
}
EOF

#############
# apptainer #
#############
debian_apptainer() {
	install_pkg_from_github apptainer/apptainer 'contains("apptainer_") and endswith("amd64.deb")'
}

ubuntu_apptainer() {
	debian_apptainer
}

arch_apptainer() {
	install_pkg apptainer
}

# openEuler_apptainer() {
# 	echo "not planned"
# }

check_and_exec "$ID"_apptainer

###############
# singularity #
###############
# singularity conflicts with apptainer
# debian_singularity() {
# 	install_pkg singularity-container # currently unstable
# }
# ubuntu_singularity() {
# 	debian_singularity
# }
#
# check_and_exec "$ID"_singularity
