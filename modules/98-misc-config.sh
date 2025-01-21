#!/bin/bash

# we change zsh to read profile.d as bash does
# https://lmod.readthedocs.io/en/latest/030_installing.html#zsh
cat >/etc/zsh/zshenv <<'EOF'
if [ -d /etc/profile.d ]; then
  setopt no_nomatch
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  setopt nomatch
fi
EOF

cat >/etc/fstab <<-EOF
storage:/home		/home		nfs	defaults	0	0
storage:/river		/river		nfs	defaults	0	0
#root:/lake		/lake		nfs	defaults	0	0
storage:/ocean		/ocean		nfs	defaults	0	0
storage:/slurm		/slurm		nfs	defaults	0	0
storage:/pxe/rootfs	/pxe/rootfs	nfs	defaults	0	0
# # tmpfs mount are useless because we already use overlay root
# none			/pxe		tmpfs	defaults	0	0
# none			/tmp		tmpfs	defaults	0	0
# none			/var/tmp	tmpfs	defaults	0	0
# none			/var/log	tmpfs	defaults	0	0
EOF

mkdir -p /pxe/rootfs

# conditional mount /local:
# if /dev/sda is present and is ext4, mount it
cat >/usr/local/bin/mount-local.sh <<'EOF'
#!/bin/bash
set -e

if [ -b /dev/sda ] && blkid /dev/sda | grep -q ext4; then
	mkdir -p /local-sata
	mount /dev/sda /local-sata
	chmod 777 /local-sata
	mkdir -p /local-sata/docker
	mkdir -p /local-sata/var
	mkdir -p /local-sata/tmp
	mkdir -p /local-sata/var/tmp
	mkdir -p /local-sata/var/log
	mkdir -p /var/lib/docker
	mount --bind /local-sata/docker /var/lib/docker
	mount --bind /local-sata/tmp /tmp
	mount --bind /local-sata/var/tmp /var/tmp
	mount --bind /local-sata/var/log /var/log
fi

if [ -b /dev/nvme0n1 ] && blkid /dev/nvme0n1 | grep -q ext4; then
	mkdir -p /local-nvme
	mount /dev/nvme0n1 /local-nvme
	chmod 777 /local-nvme
fi

EOF
chmod +x /usr/local/bin/mount-local.sh

cat >/etc/systemd/system/mount-local.service <<'EOF'
[Unit]
Description=Mount /local
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mount-local.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl enable mount-local

# a watchdog to restart machine when NFS break
case $ID in
debian | ubuntu)
	install_pkg watchdog
	;;
*)
	echo "TODO"
	;;
esac
