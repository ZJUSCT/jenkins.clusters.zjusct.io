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
		exit
	fi
	bw config server https://key.clusters.zjusct.io
	if [ -z "$BW_SESSION" ]; then
		echo "BW_SESSION is not set, please login to bitwarden"
		# check if logged in, if success, then logout and login again
		if bw login --check; then
			bw logout
		fi
		BW_SESSION=$(bw login --raw)
		export BW_SESSION
	else
		# check if BW_SESSION is still valid
		if ! bw unlock --check; then
			echo "BW_SESSION is not valid, please login to bitwarden"
			BW_SESSION=$(bw login --raw)
			export BW_SESSION
		fi
	fi
	if ! bw login --check; then
		echo "bw login failed, exit"
		exit
	fi
}

###################
# get credentials #
###################

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
		echo "$credential_name=\"$password\"" >>jenkins/.env
	done
	bw logout
fi

################
# install cert #
################

(
	cd cert || exit 1
	./cert_gen.sh
)

cp cert/bump.crt jenkins/bump.crt

#################
# build jenkins #
#################

docker compose build #--no-cache --progress plain
rm jenkins/bump.crt

# jenkins_jobs.ini is private, mounted by docker
if [ ! -f job_builder/jenkins_jobs.ini ]; then
	bw_login
	JENKINS_PASSWORD=$(bw get password JENKINS_PASSWORD)
	cat >job_builder/jenkins_jobs.ini <<EOF
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

	bw logout
fi

mkdir -p trafficserver/var
chmod 777 trafficserver/var

docker compose up -d

if ! command -v jenkins-jobs &>/dev/null; then
	echo "jenkins-jobs could not be found, installing..."
	sudo apt-get install -y jenkins-job-builder
fi

. job_builder/update-jobs.sh
