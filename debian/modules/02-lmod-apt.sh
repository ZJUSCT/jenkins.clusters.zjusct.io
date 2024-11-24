#!/bin/bash

apt-get install lmod

# https://lmod.readthedocs.io/en/latest/030_installing.html
# The profile file is the Lmod initialization script for the bash and zsh shells, the cshrc file is for tcsh and csh shells, and the profile.fish file is for the fish shell, etc. Please copy or link the profile and cshrc files to /etc/profile.d, and optionally the fish file to /etc/fish/conf.d.

# bash, zsh
ln -s /usr/share/lmod/lmod/init/profile        /etc/profile.d/z00_lmod.sh
# fish
ln -s /usr/share/lmod/lmod/init/profile.fish   /etc/fish/conf.d/z00_lmod.fish

# for .modulespath, see
# https://lmod.readthedocs.io/en/latest/030_installing.html#installing-lmod
mkdir -p /etc/lmod

# https://lmod.readthedocs.io/en/latest/060_locating.html
# https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html
