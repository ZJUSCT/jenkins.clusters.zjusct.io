#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR" || exit

if ! command -v shellcheck &>/dev/null; then
	apt-get install -y shellcheck
fi

SHELLCHECK_EXCLUDES="SC2034"

# validate bash scripts
# https://stackoverflow.com/questions/762348/how-can-i-exclude-all-permission-denied-messages-from-find
find .  ! -readable -prune \
	-o \
	! -path "./jenkins/jenkins_home/*" \
	-name "*.sh" \
	-exec shellcheck -x --severity warning --exclude $SHELLCHECK_EXCLUDES {} \;
