#!/bin/bash
cat >/etc/fstab <<EOF
172.25.2.11:/home /home nfs defaults 0 0
#172.25.2.11:/lake /lake nfs defaults 0 0
172.25.2.11:/river /river nfs defaults 0 0
172.25.2.11:/slurm /slurm nfs defaults 0 0
172.25.2.11:/ocean /ocean nfs defaults 0 0
none /tmp tmpfs defaults 0 0
none /var/tmp tmpfs defaults 0 0
none /var/log tmpfs defaults 0 0
EOF
