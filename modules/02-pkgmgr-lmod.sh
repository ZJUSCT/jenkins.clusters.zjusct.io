#!/bin/bash

debian() {
	apt-get install lmod

	# https://lmod.readthedocs.io/en/latest/030_installing.html
	# The profile file is the Lmod initialization script for the bash and zsh shells, the cshrc file is for tcsh and csh shells, and the profile.fish file is for the fish shell, etc. Please copy or link the profile and cshrc files to /etc/profile.d, and optionally the fish file to /etc/fish/conf.d.

	# bash, zsh
	ln -s /usr/share/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh
	# fish
	ln -s /usr/share/lmod/lmod/init/profile.fish /etc/fish/conf.d/z00_lmod.fish
}

ubuntu() {
	debian
}

lmod_git() {
	# https://lmod.readthedocs.io/en/latest/030_installing.html
	tmpfile=/tmp/lmod.tar.gz
	get_tarball_from_github "TACC/Lmod" "$tmpfile"
	tar -C /opt -xzf "$tmpfile"
	rm -f "$tmpfile"
	mv /opt/TACC-Lmod-* /opt/lmod

	cd /opt/lmod || exit
	./configure --prefix=/opt/lmod
	make
	make install
	ln -s /opt/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh
	ln -s /opt/lmod/lmod/init/cshrc /etc/profile.d/z00_lmod.csh
	ln -s /opt/lmod/lmod/init/profile.fish /etc/fish/conf.d/z00_lmod.fish
}

openEuler() {
	install_pkg bc lua lua-devel lua-posix procps-ng tcl tcl-devel tcsh zsh
	lmod_git
}

arch() {
	## https://aur.archlinux.org/packages/lmod
	install_pkg bc lua-filesystem lua-posix procps-ng tcl tcsh zsh
	lmod_git
}

check_and_exec "$ID"

# for .modulespath, see
# https://lmod.readthedocs.io/en/latest/030_installing.html#installing-lmod
mkdir -p /etc/lmod

# https://lmod.readthedocs.io/en/latest/060_locating.html
# https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html
