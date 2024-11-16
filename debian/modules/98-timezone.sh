#!/bin/bash
# Set TimeZone To Asia/Shanghai

case $INIT in
  systemd)
    timedatectl set-timezone Asia/Shanghai
    ;;
  *)
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    ;;
esac
