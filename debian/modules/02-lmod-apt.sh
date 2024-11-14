#!/bin/bash

apt-get install lmod
ln -s /usr/share/lmod/lmod/init/profile        /etc/profile.d/z00_lmod.sh
ln -s /usr/share/lmod/lmod/init/cshrc          /etc/profile.d/z00_lmod.csh
ln -s /usr/share/lmod/lmod/init/profile.fish   /etc/fish/conf.d/z00_lmod.fish
mkdir -p /etc/lmod
