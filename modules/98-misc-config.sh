#!/bin/bash

#########
# Shell #
#########
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

#########
# umask #
#########
# default is 0022, we want 0002
# https://manpages.debian.org/bookworm/libpam-modules/pam_umask.8.en.html
cat > /etc/pam.d/common-session <<EOF
session    optional     pam_umask.so umask=0002
EOF
sed -i 's/^UMASK.*$/UMASK		002/' /etc/login.defs

##############
# Filesystem #
##############
cat >/etc/fstab <<EOF
storage:/river		/river		nfs	defaults	0	0
storage:/riverhome	/home		nfs	defaults	0	0
# root:/lake		/lake		nfs	defaults	0	0
storage:/ocean		/ocean		nfs	defaults	0	0
storage:/slurm		/slurm		nfs	defaults	0	0
EOF

mkdir -p /pxe/rootfs
mkdir -p /pxe/opt

cat >/usr/local/bin/mount-local.sh <<'EOF'
#!/bin/bash
# conditional mount /local:
# if /dev/sda, /dev/nvme0n1 is present and is ext4, mount it
# also bind mount /tmp, /var/tmp, /var/lib/docker
set -e

if [ -b /dev/sda ] && blkid /dev/sda | grep -q ext4; then
	mkdir -p /local-sata
	mount /dev/sda /local-sata
	chmod 777 /local-sata


	mkdir -p /local-sata/tmp
	mount --bind /local-sata/tmp /tmp
	chmod 777 /tmp

	mkdir -p /local-sata/var
	mkdir -p /local-sata/var/tmp
	mount --bind /local-sata/var/tmp /var/tmp
        chmod 777 /var/tmp

	mkdir -p /local-sata/docker
	mkdir -p /var/lib/docker
	mount --bind /local-sata/docker /var/lib/docker
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
