#!/bin/bash

apt install zip

# apptainer/apptainer
install_deb_from_github apptainer/apptainer 'test("^apptainer_[0-9.]+_amd64\\.deb$")'

# bitwarden/clients
tmpfile=$(mktemp -u).zip
get_asset_from_github 'bitwarden/clients' 'startswith("bw-linux") and endswith(".zip")' "$tmpfile"
unzip -d /usr/local/bin "$tmpfile"

# esnet/gdg
install_deb_from_github 'esnet/gdg' 'endswith("amd64.deb")'

# wagoodman/dive
install_deb_from_github 'wagoodman/dive' 'endswith("amd64.deb")'
