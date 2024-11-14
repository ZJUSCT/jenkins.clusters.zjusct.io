#!/bin/bash
set -xe

docker compose up -d

jenkins-jobs --conf jenkins_jobs.ini test jobs.yaml >/dev/null
sleep 10 # wait for jenkins to start
jenkins-jobs --conf jenkins_jobs.ini update jobs.yaml
