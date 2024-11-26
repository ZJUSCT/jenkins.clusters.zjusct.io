#!/bin/bash
# https://unix.stackexchange.com/questions/1496/why-doesnt-my-bash-script-recognize-aliases
shopt -s expand_aliases
# APT option https://news.ycombinator.com/item?id=26588400
# output of dpkg can't be suppressed, see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=539617
alias apt-get="apt-get -qq -o=Dpkg::Use-Pty=0"
alias curl="curl --retry-all-errors --retry 5 --silent --show-error --location"
alias wget="wget --tries=5 --quiet"

enable_apt_debug() {
	alias apt-get="apt-get -y"
	cat >/etc/apt/apt.conf.d/80debug <<APTEOF
# solution calculation
Debug::pkgDepCache::Marker "true";
Debug::pkgDepCache::AutoInstall "true";
Debug::pkgProblemResolver "true";
# installation order
Debug::pkgPackageManager "true";
APTEOF
}

enable_apt_proxy() {
	if [ -n "$http_proxy" ]; then
		cat >/etc/apt/apt.conf.d/80proxy <<EOF
Acquire::http::Proxy "$http_proxy";
Acquire::https::Proxy "$http_proxy";
EOF
	fi
}

install_deb_from_url() {
	url=$1
	tmpfile=$(mktemp).deb
	if ! wget -O "$tmpfile" "$url"; then
		echo "Failed to download $url"
		exit 1
	fi
	dpkg -i "$tmpfile" >/dev/null || apt-get -f install
	rm "$tmpfile"
}

# https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8

get_github_url() {
	repo=$1
	match=$2
	set -o pipefail
	local debugfile
	debugfile=$(mktemp)
	curl "http://api.github.com/repos/$repo/releases" |
		tee "$debugfile" |
		jq -r ".[].assets[] | select(.name|$match) | .browser_download_url" |
		head -n 1
	set +o pipefail
}

# https://ghp.ci/
install_deb_from_github() {
	repo=$1
	match=$2
	url=$(get_github_url "$repo" "$match")
	install_deb_from_url https://ghp.ci/"$url"
}

get_asset_from_github() {
	repo=$1
	match=$2
	output=$3
	url=$(get_github_url "$repo" "$match")
	wget -O "$output" https://ghp.ci/"$url"
}

get_tarball_from_github() {
	repo=$1
	output=$2
	set -o pipefail
	url=$(curl -x "$PROXY" "https://api.github.com/repos/$repo/releases/latest" | jq -r ".tarball_url")
	set +o pipefail
	wget -O "$output" https://ghp.ci/"$url"
}

# https://unix.stackexchange.com/questions/351557/on-what-linux-distributions-can-i-rely-on-the-presence-of-etc-os-release
. /etc/os-release
case $ID in
debian)
	# VERSION_CODENAME of sid is same with testing
	if echo "$PRETTY_NAME" | grep -q sid; then
		VERSION_CODENAME=sid
	fi
	;;
ubuntu) ;;
*)
	echo "OS not supported"
	exit 1
	;;
esac

ARCH=$(dpkg --print-architecture)
KERNEL_VERSION=$(for file in /boot/vmlinuz-*; do echo "${file#/boot/vmlinuz-}"; done | sort -V | tail -n 1)
# https://superuser.com/questions/1017959/how-to-know-if-i-am-using-systemd-on-linux
# ps fail at first chroot because /proc is not mounted
INIT=$(ps --no-headers -o comm 1) || true
