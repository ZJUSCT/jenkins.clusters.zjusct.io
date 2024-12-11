#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# APT option https://news.ycombinator.com/item?id=26588400
# output of dpkg can't be suppressed, see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=539617
apt-get() {
	command apt-get -qq -o=Dpkg::Use-Pty=0 "$@"
}
