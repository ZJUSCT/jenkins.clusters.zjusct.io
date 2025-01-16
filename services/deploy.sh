#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"
set -xe

bw_login() {
	if ! command -v bw &>/dev/null; then
		echo "bw could not be found, please install it"
		exit 1
	fi

	if [ -z "$BW_SESSION" ] || ! bw unlock --check &>/dev/null; then
		echo "Logging into Bitwarden..."
		if ! BW_SESSION=$(bw login --raw); then
			echo "bw login failed, exit"
			exit 1
		fi
		export BW_SESSION
	fi
}

credential_names=(
	"JENKINS_PASSWORD"
	"GITLAB_ACCESS_TOKEN"
	"GITHUB_ACCESS_TOKEN"
)

if [ ! -f jenkins/.env ]; then
	echo "jenkins/.env not found, generating..."
	bw_login

	# for each credential name, get the password, append it to .env using format CREDENTIAL_NAME=PASSWORD
	for credential_name in "${credential_names[@]}"; do
		echo "Getting $credential_name"
		password=$(bw get password "$credential_name")
		if [ -z "$password" ]; then
			echo "Failed to get $credential_name"
			continue
		fi
		echo "$credential_name=\"$password\"" >>.env
	done
fi

cd squid/squid || exit 1

if [ ! -f bump.key ] || [ ! -f bump.crt ] || [ ! -f bump_dhparam.pem ]; then
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
	openssl dhparam -outform PEM -out bump_dhparam.pem 2048
	chown proxy:proxy bump.key bump.crt bump_dhparam.pem
	chmod 400 bump.key bump.crt bump_dhparam.pem
fi

cd "$SCRIPT_DIR" || exit 1

docker compose build --progress plain
docker compose up -d

if ! command -v jenkins-jobs &>/dev/null; then
	echo "jenkins-jobs could not be found, installing..."
	sudo apt-get install -y jenkins-job-builder
fi

if [ ! -f job_builder/jenkins_jobs.ini ]; then
	bw_login
	JENKINS_PASSWORD=$(bw get password JENKINS_PASSWORD)
	cat >jenkins_jobs.ini <<EOF
[job_builder]
ignore_cache=True
keep_descriptions=False
update=all

[jenkins]
user=zjusct
password=$JENKINS_PASSWORD
url=https://jenkins.clusters.zjusct.io
query_plugins_info=False
EOF
fi

. job_builder/update-jobs.sh
