#!/bin/bash

# https://wiki.archlinux.org/title/Audit_framework
# https://www.sudo.ws/posts/2022/05/looking-inside-sudo-shell-sessions-auditd-session-recordings-log_subcmds/

install_pkg auditd
cat > /etc/audit/rules.d/all.rules <<EOF
# 记录所有用户的命令
-a exit,always -S execve
EOF

cat > /etc/sudoers.d/audit <<EOF
Defaults log_subcmds
#Defaults log_format=json
#Defaults logfile=/var/log/sudo.log
#Defaults !syslog
# https://www.sudo.ws/pipermail/sudo-users/2023-February/006538.html
Defaults !intercept_verify
EOF
