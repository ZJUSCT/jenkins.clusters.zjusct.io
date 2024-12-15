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
storage:/pxe		/pxe		nfs	defaults	0	0
/dev/sda		/local		auto	defaults	0	0
# # tmpfs mount are useless because we already use overlay root
# none			/pxe		tmpfs	defaults	0	0
# none			/tmp		tmpfs	defaults	0	0
# none			/var/tmp	tmpfs	defaults	0	0
# none			/var/log	tmpfs	defaults	0	0
EOF

mkdir -p /local
chmod 777 /local
