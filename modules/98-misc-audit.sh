#!/bin/bash

# https://wiki.archlinux.org/title/Audit_framework
# https://www.sudo.ws/posts/2022/05/looking-inside-sudo-shell-sessions-auditd-session-recordings-log_subcmds/

# install_pkg auditd
# cat > /etc/audit/auditd.conf <<EOF
# # 记录 sudo 命令
# -a exit,always -S execve -F euid=0 -k sudo_log
# 
# # 记录 su 切换用户
# -a exit,always -S execve -F path=/bin/su -k su_log
# 
# # 记录 root 用户登录
# -a exit,always -S execve -F euid=0 -F path=/bin/login -k root_login
# 
# # 记录 root 用户执行的命令
# -a exit,always -F arch=b32 -S execve -F euid=0 -k root_cmd
# EOF

cat > /etc/sudoers.d/audit <<EOF
Defaults log_subcmds
Defaults log_format=json
Defaults logfile=/var/log/sudo.log
Defaults !syslog
# https://www.sudo.ws/pipermail/sudo-users/2023-February/006538.html
Defaults !intercept_verify
EOF
