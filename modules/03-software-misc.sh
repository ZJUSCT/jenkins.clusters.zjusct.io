#!/bin/bash

##################
# wagoodman/dive #
##################

case $ID in
debian|ubuntu)
	install_pkg_from_github 'wagoodman/dive' 'endswith("amd64.deb")'
	;;
openEuler)
	install_pkg_from_github 'wagoodman/dive' 'endswith("amd64.rpm")'
	;;
arch)
	get_asset_from_github 'wagoodman/dive' 'endswith("amd64.tar.gz")' /tmp/dive.tar.gz
	tar -C /usr/bin -xzf /tmp/dive.tar.gz dive
	;;
esac

#####################
# bitwarden/clients #
#####################
install_pkg zip
case $ID in
arch)
	install_pkg unzip
	;;
esac

tmpfile=$(mktemp -u).zip
get_asset_from_github 'bitwarden/clients' 'startswith("bw-linux") and endswith(".zip")' "$tmpfile"
unzip -d /usr/local/bin "$tmpfile"

#############
# esnet/gdg #
#############

case $ID in
debian|ubuntu)
	install_pkg_from_github 'esnet/gdg' 'contains("gdg") and endswith("amd64.deb")'
	;;
openEuler)
	install_pkg_from_github 'esnet/gdg' 'contains("gdg") and endswith("x86_64.rpm")'
	;;
arch)
	get_asset_from_github 'esnet/gdg' 'contains("gdg") and endswith("x86_64.tar.gz")' /tmp/gdg.tar.gz
	tar -C /usr/bin -xzf /tmp/gdg.tar.gz gdg
	;;
esac

############
# sing-box #
############
case $ID in
debian|ubuntu)
	install_pkg_from_github 'SagerNet/sing-box' 'contains("sing-box") and endswith("amd64.deb")'
	;;
openEuler)
	bash <(curl -fsSL https://sing-box.app/rpm-install.sh)
	;;
arch)
	bash <(curl -fsSL https://sing-box.app/arch-install.sh)
	;;
esac
