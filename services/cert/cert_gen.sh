#!/usr/bin/env bash

# Input: bump.conf
# Output: bump.key, bump.crt
# Description: Generate a self-signed certificate for bumping
# Usage: ./cert_gen.sh

if [ ! -f bump.key ] || [ ! -f bump.crt ]; then
	echo "Generating bump key and cert..."
	if [ ! -f bump.conf ]; then
		echo "bump.conf not found, exit"
		exit 1
	fi
	openssl req \
		-new -newkey rsa:2048 \
		-sha256 -days 365 -nodes \
		-x509 \
		-keyout bump.key \
		-out bump.crt \
		-addext "crlDistributionPoints=URI:http://localhost/revocationlist.crl" \
		-config bump.conf
	chown proxy:proxy bump.key bump.crt
	chmod 400 bump.key bump.crt
fi
