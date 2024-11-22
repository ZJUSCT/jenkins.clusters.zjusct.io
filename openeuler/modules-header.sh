#!/bin/bash
# https://unix.stackexchange.com/questions/1496/why-doesnt-my-bash-script-recognize-aliases
shopt -s expand_aliases
alias dnf="dnf -y"

KERNEL_VERSION=$(for file in /boot/vmlinuz-*; do echo "${file#/boot/vmlinuz-}"; done | sort -V | tail -n 1)
# https://superuser.com/questions/1017959/how-to-know-if-i-am-using-systemd-on-linux
# ps fail at first chroot because /proc is not mounted
INIT=$(ps --no-headers -o comm 1) || true
