#!/bin/bash

apt-get autopurge
apt-get clean
rm -f /etc/apt/apt.conf.d/80proxy
rm -f /etc/apt/apt.conf.d/80debug
echo "" >/usr/sbin/policy-rc.d
rm -f /etc/dpkg/dpkg.cfg.d/02dpkg-unsafe-io
echo "" >/etc/hostname
