#!/bin/bash

# goto /tmp
cd /tmp || exit 1

# https://unix.stackexchange.com/questions/1496/why-doesnt-my-bash-script-recognize-aliases
# shopt -s expand_aliases
# alias curl="curl --retry-all-errors --retry 5 --silent --show-error --location"
# alias wget="wget --tries=5 --quiet"

# Ideally, we should use functions instead of aliases
curl() {
	command curl --retry-all-errors --retry 5 --silent --show-error --location "$@"
}
wget() {
	# don't use --quiet, use --no-verbose instead, or you won't know what's going on
	# wget will retry 20 times by default, just need to add more retry conditions
	command wget --retry-connrefused --retry-on-host-error --no-verbose "$@"
}

# https://unix.stackexchange.com/questions/351557/on-what-linux-distributions-can-i-rely-on-the-presence-of-etc-os-release
# https://github.com/which-distro/os-release
. /etc/os-release

KERNEL_VERSION=$(for file in /boot/vmlinuz-*; do echo "${file#/boot/vmlinuz-}"; done | sort -V | tail -n 1)
# https://superuser.com/questions/1017959/how-to-know-if-i-am-using-systemd-on-linux
# ps fail at first chroot because /proc is not mounted
INIT=$(ps --no-headers -o comm 1) || true

check_and_exec() {
	if declare -f "$1" >/dev/null; then
		"$1"
	else
		echo "Warning: $1 is not supported"
		return 1
	fi
}

##########
# github #
##########

# https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
get_github_url() {
	# check if jq is installed
	if ! command -v jq >/dev/null; then
		install_pkg jq
	fi
	local repo=$1
	local match=$2
	set -o pipefail
	local url
	local counter=20
	# if url is empty, retry 20 times until it's not empty
	while [ -z "$url" ] && [ $counter -gt 0 ]; do
		# we can't use /latest because repository like bitwarden/client
		# release different products on different branches, so latest
		# might not contain the product we want
		url=$(curl "https://api.github.com/repos/$repo/releases" |
			jq -r "$match" |
			head -n 1)
		counter=$((counter - 1))
		sleep 1
	done
	set +o pipefail
	echo "$url"
}

get_asset_from_github() {
	local repo=$1
	local match=$2
	local output=$3
	local url
	url=$(get_github_url "$repo" ".[].assets[] | select(.name|$match) | .browser_download_url")
	local counter=20
	# if download fails, retry 20 times
	while [ $counter -gt 0 ]; do
		if wget -O "$output" "$url"; then
			break
		fi
		counter=$((counter - 1))
		sleep 1
	done

	if [ $counter -eq 0 ]; then
		echo "Failed to download $url after multiple attempts"
		exit 1
	fi
}

get_tarball_from_github() {
	local repo=$1
	local output=$2
	local url
	url=$(get_github_url "$repo" ".[].tarball_url")
	local counter=20
	# if download fails, retry 20 times
	while [ $counter -gt 0 ]; do
		if wget -O "$output" "$url"; then
			break
		fi
		counter=$((counter - 1))
		sleep 1
	done

	if [ $counter -eq 0 ]; then
		echo "Failed to download $url after multiple attempts"
		exit 1
	fi
}

########
# pkgs #
########

case $ID in
ubuntu | debian)
	PKG_FORMAT=deb
	;;
openEuler)
	PKG_FORMAT=rpm
	;;
arch)
	PKG_FORMAT=.tar.zst
	;;
*)
	echo "Unknown distribution: $ID"
	exit 1
	;;
esac

install_pkg() {
	case $ID in
	ubuntu | debian)
		apt-get update
		apt-get install "$@"
		;;
	openEuler)
		dnf install "$@"
		;;
	arch)
		pacman -S "$@"
		;;
	*)
		echo "Unknown distribution: $ID"
		exit 1
		;;
	esac
}

install_pkg_local() {
	case $ID in
	ubuntu | debian)
		dpkg -i "$@" || apt-get --fix-broken --fix-missing install
		;;
	openEuler)
		rpm -i "$@"
		# dnf install -y
		;;
	arch)
		pacman -U "$@"
		;;
	*)
		echo "Unknown distribution: $ID"
		exit 1
		;;
	esac
}

install_pkg_from_url() {
	local url=$1
	local tmpfile
	tmpfile=$(mktemp)
	if ! wget -O "$tmpfile" "$url"; then
		echo "Failed to download $url"
		exit 1
	fi
	install_pkg_local "$tmpfile"
	rm "$tmpfile"
}

install_pkg_from_github() {
	local repo=$1
	local match=$2
	local tmpfile
	tmpfile=$(mktemp)
	get_asset_from_github "$repo" "$match" "$tmpfile"
	install_pkg_local "$tmpfile"
	rm "$tmpfile"
}
