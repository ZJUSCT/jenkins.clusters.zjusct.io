#!/bin/bash

# https://stackoverflow.com/questions/29926773/run-shell-command-in-jenkins-as-root-user
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root."
	exit 1
fi

PREREQUISITES=(psmisc rsync)
case "$INIT" in
systemd)
	PREREQUISITES+=(systemd-container systemd-resolved)
	;;
esac

common_init() {
	if ! dpkg -l "${PREREQUISITES[@]}" &>/dev/null; then
		apt-get -qq update
		apt-get -qq install "${PREREQUISITES[@]}"
		case "$INIT" in
		systemd)
			systemctl restart systemd-resolved
			;;
		esac
	fi
	# some sensible default
	export LC_ALL=C.UTF-8
	export LC_CTYPE=$LC_ALL
	export LANG=$LC_ALL
	echo "===================================================================================="
	echo "$(date) - running $0 on $(hostname), called using \"$*\" as arguments."
	echo "$(date) - actually running \"$(basename "$0")\" (md5sum $(md5sum "$0" | cut -d ' ' -f1))"
	echo
	export MIRROR=$MIRROR
	# do not enable proxy by default
	# if [ -n "$PROXY" ]; then
	# 	export http_proxy=$PROXY
	# 	export https_proxy=$PROXY
	# fi
	# be more verbose, maybe
	if $DEBUG; then
		export
		set -x
	fi
}

cleanup_all() {
	if [ "$CHROOT_METHOD" = "chroot" ]; then
		for mount in tmp run dev/pts dev sys proc; do
			if mountpoint -q "$CHROOT_TARGET/$mount"; then
				# why we need lazy umount?
				# https://groups.google.com/g/linux.debian.user/c/ei2Guc_ZnXg?pli=1
				umount -l "$CHROOT_TARGET/$mount" ||
					fuser -mv "$CHROOT_TARGET/$mount"
			fi
		done
	fi
	echo "Doing cleanup now."
	echo "Debug: Removing trap."
	trap - INT TERM EXIT
	set -x
	echo "\$1 = $1"
	rm -f "$TMPLOG"
	if [ "$1" != "fine" ]; then
		# rename to .error
		rm -rf --one-file-system "$CHROOT_BASE".error ||
			fuser -mv "$CHROOT_BASE".error
		mv "$CHROOT_TARGET" "$CHROOT_BASE".error ||
			fuser -mv "$CHROOT_TARGET" "$CHROOT_BASE".error
		echo "Something went wrong, $CHROOT_TARGET is moved to $CHROOT_BASE.error for further inspection."
		exit 1
	else
		# remove .error
		rm -rf --one-file-system "$CHROOT_BASE".error ||
			fuser -mv "$CHROOT_BASE".error
		# rename to .latest
		rm -rf --one-file-system "$CHROOT_BASE".latest ||
			fuser -mv "$CHROOT_BASE".latest
		echo "$CHROOT_TARGET succeeded."
		mv "$CHROOT_TARGET" "$CHROOT_BASE".latest ||
			fuser -mv "$CHROOT_TARGET" "$CHROOT_BASE".latest
		echo "$CHROOT_BASE.latest can now be released."
	fi
}

prepare_module() {
	# /tmp is mount to tmpfs in systemd-nspawn
	TMPFILE=/root/$TIMESTAMP.sh
	CTMPFILE=$CHROOT_TARGET/$TMPFILE
	TMPLOG=/tmp/$DISTRO-$RELEASE-$TIMESTAMP.log
	# https://www.shellcheck.net/wiki/SC2129
	{
		echo "$MODULE_HEADER"
		cat common-header.sh
		cat distro/"$DISTRO"-header.sh
		cat "$1"
	} >>"$CTMPFILE"
}

execute_module() {
	echo "echo xxxxxSUCCESSxxxxx" >>"$CTMPFILE"
	set -x
	chmod +x "$CTMPFILE"
	set -o pipefail # see eg http://petereisentraut.blogspot.com/2010/11/pipefail.html
	case $CHROOT_METHOD in
	systemd)
		(systemd-nspawn --resolv-conf=replace-stub --hostname="$DISTRO"-"$RELEASE" -D "$CHROOT_TARGET" "$TMPFILE" 2>&1 | tee "$TMPLOG") || true
		;;
	chroot)
		(chroot "$CHROOT_TARGET" "$TMPFILE" 2>&1 | tee "$TMPLOG") || true
		;;
	esac
	RESULT=$(grep "xxxxxSUCCESSxxxxx" "$TMPLOG" || true)
	if [ -z "$RESULT" ]; then
		echo "Failed to run $TMPFILE in $CHROOT_TARGET."
		exit 1
	fi
	rm "$CTMPFILE"
	set +o pipefail
	set +x
}
