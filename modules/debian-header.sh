#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# APT option https://news.ycombinator.com/item?id=26588400
# output of dpkg can't be suppressed, see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=539617
apt-get() {
	command apt-get -qq -o=Dpkg::Use-Pty=0 "$@"
}

# VERSION_CODENAME of sid is same with testing, need to distinguish
if [ "$ID" = "debian" ] && echo "$PRETTY_NAME" | grep -q sid; then
	VERSION_CODENAME=sid
fi
