#!/bin/bash

#####################
# bitwarden/clients #
#####################
install_pkg zip
case $ID in
arch)
	install_pkg unzip
	;;
esac

tmpfile=$(mktemp -u).zip
get_asset_from_github 'bitwarden/clients' 'startswith("bw-linux") and endswith(".zip")' "$tmpfile"
unzip -d /usr/local/bin "$tmpfile"
