#!/bin/bash

# bitwarden/clients
apt install zip
tmpfile=$(mktemp -u).zip
get_asset_from_github 'bitwarden/clients' 'startswith("bw-linux") and endswith(".zip")' "$tmpfile"
unzip -d /usr/local/bin "$tmpfile"

# esnet/gdg
install_deb_from_github 'esnet/gdg' 'endswith("amd64.deb")'

# wagoodman/dive
install_deb_from_github 'wagoodman/dive' 'endswith("amd64.deb")'
