#!/bin/bash

curl https://gitlab.star-home.top:4430/star/deploy-ctld/-/raw/main/ctld_1.0.0_amd64.deb -o /tmp/ctld_1.0.0_amd64.deb

dpkg -i /tmp/ctld_1.0.0_amd64.deb

systemctl enable ctld