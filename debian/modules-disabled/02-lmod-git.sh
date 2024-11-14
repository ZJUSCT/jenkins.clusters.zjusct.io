#!/bin/bash
# https://lmod.readthedocs.io/en/latest/030_installing.html
apt-get update
apt-get build-dep lmod
lua_ver=$(which lua | xargs realpath -e | xargs basename)
apt-get install lib"${lua_ver}"-dev tcl-dev

tmpfile=/tmp/lmod.tar.gz
get_tarball_from_github "TACC/Lmod" "$tmpfile"
tar -C /opt -xzf "$tmpfile"
rm -f "$tmpfile"
mv /opt/Lmod* /opt/lmod

cd /opt/lmod || exit
./configure --prefix=/opt/lmod
make
make install
ln -s /opt/lmod/lmod/init/profile        /etc/profile.d/z00_lmod.sh
ln -s /opt/lmod/lmod/init/cshrc          /etc/profile.d/z00_lmod.csh
ln -s /opt/lmod/lmod/init/profile.fish   /etc/fish/conf.d/z00_lmod.fish
