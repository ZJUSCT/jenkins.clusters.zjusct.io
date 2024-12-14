#!/bin/bash

debian(){
	install_pkg munge slurmd
}

ubuntu(){
	debian
}

arch(){
	install_pkg munge slurm-llnl
}

openEuler(){
	install_pkg munge slurm
}

configure(){
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
}

check_and_exec "$ID"
configure
