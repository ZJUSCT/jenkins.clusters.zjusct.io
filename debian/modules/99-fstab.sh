#!/bin/bash
cat >/etc/fstab <<EOF
#root:/lake /lake nfs defaults 0 0
storage:/home /home nfs defaults 0 0
storage:/river /river nfs defaults 0 0
storage:/slurm /slurm nfs defaults 0 0
storage:/ocean /ocean nfs defaults 0 0
none /tmp tmpfs defaults 0 0
none /var/tmp tmpfs defaults 0 0
none /var/log tmpfs defaults 0 0
/dev/sda /local auto defaults 0 0
EOF

mkdir -p /local
chmod 777 /local
