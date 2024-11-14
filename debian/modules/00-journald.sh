#!/bin/bash
# centralized logging for otelcol
cat >/etc/systemd/journald.conf <<EOF
[Journal]
Storage=volatile
EOF
