#!/bin/bash

# https://github.com/dun/munge/issues/92
groupadd --gid 701 munge
useradd --comment "MUNGE authentication service" \
	--uid 701 \
	--gid munge \
	--shell /sbin/nologin \
	--home-dir /usr/local/etc/munge \
	munge

# see Debian source
# slurm-wlm/debian/slurm-wlm-basic-plugins.preinst/
groupadd --gid 703 slurm
useradd --comment "Slurm workload manager" \
	--uid 703 \
	--gid slurm \
	--shell /sbin/nologin \
	--no-create-home \
	--home-dir /nonexistent \
	slurm

debian() {
	install_pkg munge slurmd
	rm -rf /etc/munge/munge.key
}

ubuntu() {
	debian
}

arch() {
	install_pkg munge slurm-llnl
}

openEuler() {
	install_pkg munge slurm
}

check_and_exec "$ID"

cat > /lib/systemd/system/munge.service  <<EOF
[Unit]
Description=MUNGE authentication service
Documentation=man:munged(8)
Wants=sssd-nss.service
After=network-online.target
After=time-sync.target
After=sockets.target
After=sssd-nss.service
After=slurm.mount remote-fs.target

[Service]
Type=forking
EnvironmentFile=-/slurm/etc/default/munge
ExecStart=/usr/sbin/munged \$OPTIONS
PIDFile=/run/munge/munged.pid
RuntimeDirectory=munge
RuntimeDirectoryMode=0755
User=munge
Group=munge
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/slurmd.service <<EOF
[Unit]
Description=Slurm node daemon
After=munge.service network-online.target remote-fs.target
Wants=network-online.target
ConditionPathExists=/slurm/etc/default/slurmd
Documentation=man:slurmd(8)

[Service]
Type=simple
EnvironmentFile=-/slurm/etc/default/slurmd
ExecStart=/usr/sbin/slurmd -D -s $SLURMD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/slurmd.pid
KillMode=process
LimitNOFILE=131072
LimitMEMLOCK=infinity
LimitSTACK=infinity
Delegate=yes
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF

# Slurm utils need SLURM_CONF env
cat >>/etc/environment <<EOF
SLURM_CONF="/slurm/etc/slurm/slurm.conf"
EOF
