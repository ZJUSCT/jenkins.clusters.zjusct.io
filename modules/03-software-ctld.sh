#!/bin/bash

curl https://gitlab.star-home.top:4430/star/deploy-ctld/-/raw/main/ctld_1.0.1_amd64.deb -o /tmp/ctld_1.0.1_amd64.deb

dpkg -i /tmp/ctld_1.0.1_amd64.deb

cat << EOF > /etc/systemd/system/ctld.service
[Unit]
Description=Control Daemon
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/ctld client -server 172.25.4.11:4320
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


