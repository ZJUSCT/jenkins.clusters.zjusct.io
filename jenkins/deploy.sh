#!/bin/bash

set -xe

bw_login() {
	if ! command -v bw &>/dev/null; then
		echo "bw could not be found, please install it"
		exit 1
	fi

	if [ -z "$BW_SESSION" ] || ! bw unlock --check &>/dev/null; then
		echo "Logging into Bitwarden..."
		BW_SESSION=$(bw login --raw)
		if [ $? -ne 0 ]; then
			echo "bw login failed, exit"
			exit 1
		fi
		export BW_SESSION
	fi
}

if ! command -v jenkins-jobs &>/dev/null; then
	echo "jenkins-jobs could not be found, installing..."
	sudo apt-get install -y jenkins-job-builder
fi

credential_names=(
	"JENKINS_PASSWORD"
	"GITLAB_ACCESS_TOKEN"
)

if [ ! -f .env ]; then
	echo ".env not found, generating..."
	bw_login
	# create .env file
	if [ -f .env ]; then
		rm .env
	fi

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

docker compose down
docker compose build # --progress plain

if [ ! -f jenkins_jobs.ini ]; then
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
