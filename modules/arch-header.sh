#!/bin/bash

pacman() {
	command pacman --noconfirm "$@"
}

install_pkg_from_aur() {
	local url=$1
	local package
	package=$(basename "$url" .git)
	# temporary make nobody a sudoer without password
	echo 'nobody ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/nobody
	sudo -u nobody git clone "$url"
	cd "$package" || exit
	sudo -u nobody makepkg -si
	cd ..
	rm -rf "$package"
	# remove the sudoer permission
	rm -f /etc/sudoers.d/nobody
}
