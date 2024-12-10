#!/bin/bash

make_kernel_debian() {
	# https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel
	# https://wiki.debian.org/KernelFAQ
	# https://debian-handbook.info/browse/stable/sect.kernel-compilation.html

	# deps
	apt-get install debhelper-compat libelf-dev libssl-dev rsync devscripts

	# get the source code
	cd /tmp || exit
	apt-get source linux/"$VERSION_CODENAME"
	cd linux-*/ || exit

	# enable the feature
	cp /boot/config-"$KERNEL_VERSION" .config
	./scripts/config --enable AMD_HSMP
	./scripts/config --disable DEBUG_INFO
	./scripts/config --disable DEBUG_INFO_BTF

	# update the version

	# make the kernel
	MAKEFLAGS=-j$(nproc)
	export MAKEFLAGS
	export DEB_BUILD_PROFILES='pkg.linux.nokerneldbg pkg.linux.nokerneldbginfo'
	yes "" | make bindeb-pkg LOCALVERSION=-zjusct KDEB_PKGVERSION="$(make kernelversion)-1"

	# install the kernel
	cd ..
	dpkg -i linux-image-*.deb linux-headers-*.deb

	# clean up
	rm -rf linux-*
	apt-get autoremove
	apt-get clean
}

make_kernel_ubuntu() {
	make_kernel_debian
}

check_and_exec make_kernel_"$DISTRO"
