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

# Munge systemd service override
mkdir /etc/systemd/system/munge.service.d
cat >/etc/systemd/system/munge.service.d/override.conf <<EOF
[Unit]
After=remote-fs.target
ConditionPathExists=/slurm/etc/default/munge
[Service]
EnvironmentFile=
EnvironmentFile=-/slurm/etc/default/munge
EOF

# Slurm systemd service override
mkdir /etc/systemd/system/slurmd.service.d
cat >/etc/systemd/system/slurmd.service.d/override.conf <<EOF
[Unit]
After=remote-fs.target
ConditionPathExists=/slurm/etc/default/slurmd
[Service]
EnvironmentFile=
EnvironmentFile=-/slurm/etc/default/slurmd
EOF

# Slurm utils need SLURM_CONF env
cat >>/etc/environment <<EOF
SLURM_CONF="/slurm/etc/slurm/slurm.conf"
EOF
