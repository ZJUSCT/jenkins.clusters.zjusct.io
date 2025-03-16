#!/bin/bash

cat >/etc/chrony/chrony.conf <<EOF
confdir /etc/chrony/conf.d

# DONOT Use Debian vendor zone.
#pool 2.debian.pool.ntp.org iburst
# DONOT Use time sources from DHCP.
#sourcedir /run/chrony-dhcp
#sourcedir /etc/chrony/sources.d

server 172.25.4.253 iburst
#server time.zju.edu.cn iburst

keyfile /etc/chrony/chrony.keys

driftfile /var/lib/chrony/chrony.drift

ntsdumpdir /var/lib/chrony

log tracking measurements statistics

# Log files location.
logdir /var/log/chrony

# Stop bad estimates upsetting machine clock.
maxupdateskew 100.0

# This directive enables kernel synchronisation (every 11 minutes) of the
# real-time clock. Note that it can't be used along with the 'rtcfile' directive.
rtcsync

# Step the system clock instead of slewing it if the adjustment is larger than
# one second, but only in the first three clock updates.
makestep 1 3

# Get TAI-UTC offset and leap seconds from the system tz database.
# This directive must be commented out when using time sources serving
# leap-smeared time.
leapsectz right/UTC
EOF
