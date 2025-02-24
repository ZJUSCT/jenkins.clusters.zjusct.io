#!/bin/bash

curl https://gitlab.star-home.top:4430/star/deploy-ctld/-/blob/745728db34cdf940fa547b7831f9140bd6ca9757/ctld_1.0.0_amd64.deb -o /tmp/ctld_1.0.0_amd64.deb

dpkg -i /tmp/ctld_1.0.0_amd64.deb

systemctl enable ctld