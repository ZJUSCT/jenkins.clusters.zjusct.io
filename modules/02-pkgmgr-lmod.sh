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
	# install_pkg bc lua lua-posix procps-ng tcl tcsh zsh
	# lmod_git

	# checking for lua modules: lfs... no
	# checking for lua modules: term... no
	# checking for pkg-config... (cached) /usr/bin/pkg-config
	#
	# Error can not find lua.h which is needed to build lua-term.
	# You can either install lua-term or the lua development package.
	# Quitting!
	# checking for tcl.h... no
	# configure: Unable to build Lmod without tcl.h.  Please install the tcl devel package or configure --with-fastTCLInterp=no to not require tcl.h.  You can also provide your own tcl installation.  Please set TCL_PKG_CONFIG_DIR to point to the directory containing tcl.pc. This is typically in <tcl-installation>/lib/pkgconfig.  Or specify TCL_INCLUDE and TCL_LIBS w/o TCL_PKG_CONFIG_DIR.  If you use TCL_INCLUDE and TCL_LIBS you must provide the -I for TCL_INCLUDE and the -L -l to TCL_LIBS.  The directories alone are not sufficient!
	echo "Not implemented yet."
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
