#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR"

set -xe

if [ -f jenkins_jobs.ini ]; then
	CONFIG_FILE="jenkins_jobs.ini"
elif [ -f /var/jenkins_jobs.ini ]; then
	CONFIG_FILE="/var/jenkins_jobs.ini"
else
	echo "jenkins_jobs.ini not found"
	exit 1
fi

jenkins-jobs --conf $CONFIG_FILE test jobs.yaml >/dev/null
#sleep 10 # wait for jenkins server to start
jenkins-jobs --conf $CONFIG_FILE update --delete-old jobs.yaml
