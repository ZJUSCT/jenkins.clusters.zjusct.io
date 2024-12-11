#!/bin/bash

set -x

debian() {
	# https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel
	# https://wiki.debian.org/KernelFAQ
	# https://debian-handbook.info/browse/stable/sect.kernel-compilation.html

	# deps
	apt-get install debhelper-compat libelf-dev libssl-dev rsync devscripts

	# get the source code
	cd /root || exit
	apt-get source linux/"$VERSION_CODENAME"
	cd linux-*/ || exit

	# enable the feature
	cp /boot/config-"$KERNEL_VERSION" .config
	./scripts/config --enable AMD_HSMP
	./scripts/config --disable DEBUG_INFO
	./scripts/config --disable DEBUG_INFO_BTF

	# update the version

	# make the kernel
	# avoid error arch/amd64/Makefile: No such file or directory
	# this is because dpkg outputs the architecture as amd64, but the kernel expects x86
	unset ARCH
	MAKEFLAGS="-j$(nproc)"
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

# Ubuntu seems to have problem compiling amd drivers
#   CC [M]  drivers/gpu/drm/amd/amdgpu/amdgpu_isp.o
#   CC [M]  drivers/gpu/drm/amd/amdgpu/isp_v4_1_0.o
#   CC [M]  drivers/gpu/drm/amd/amdgpu/isp_v4_1_1.o
#   LD [M]  drivers/gpu/drm/amd/amdgpu/amdgpu.o
#   AR      drivers/gpu/built-in.a
#   AR      drivers/built-in.a
# make[4]: *** [Makefile:1931: .] Error 2
# make[3]: *** [debian/rules:74: build-arch] Error 2
# dpkg-buildpackage: error: make -f debian/rules binary subprocess returned exit status 2
# make[2]: *** [scripts/Makefile.package:121: bindeb-pkg] Error 2
# ubuntu() {
# 	debian
# }

check_and_exec "$DISTRO"
