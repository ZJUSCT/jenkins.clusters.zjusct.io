#!/bin/bash

apt install zip

tmpfile=$(mktemp -u).zip
get_asset_from_github 'bitwarden/clients' 'startswith("bw-linux") and endswith(".zip")' "$tmpfile"
unzip -d /usr/local/bin "$tmpfile"
