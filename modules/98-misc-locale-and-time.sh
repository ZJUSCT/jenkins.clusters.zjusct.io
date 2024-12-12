#!/bin/bash

case $ID in
debian | ubuntu)
	# https://unix.stackexchange.com/questions/269159/problem-of-cant-set-locale-make-sure-lc-and-lang-are-correct
	apt-get install locales
	echo "LC_ALL=en_US.UTF-8" >>/etc/environment
	echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
	echo "LANG=en_US.UTF-8" >/etc/locale.conf
	locale-gen en_US.UTF-8
	locale -a
	# dpkg-reconfigure locales
	;;
esac

# Set TimeZone To Asia/Shanghai
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
