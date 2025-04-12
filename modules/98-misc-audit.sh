#!/bin/bash

# Reference:
# https://github.com/Neo23x0/auditd
# https://wiki.archlinux.org/title/Audit_framework
# https://www.sudo.ws/posts/2022/05/looking-inside-sudo-shell-sessions-auditd-session-recordings-log_subcmds/
# 'sudo ausearch --interpret -k <key>' to search for specific key

install_pkg auditd
cat > /etc/audit/rules.d/zjusct.rules <<EOF
# Remove any existing rules
-D

# Self Auditing ---------------------------------------------------------------

### Successful and unsuccessful attempts to modify the audit records
-w /var/log/audit/ -p wa -F exe!=/usr/bin/otelcol-contrib -k auditlog
-w /var/audit/ -p wa -F exe!=/usr/bin/otelcol-contrib -k auditlog

## Auditd configuration
### Modifications to audit configuration that occur while the audit collection functions are operating
-w /etc/audit/ -p wa -k auditconfig
-w /etc/libaudit.conf -p wa -k auditconfig
-w /etc/audisp/ -p wa -k audispconfig

# Rules -----------------------------------------------------------------------

## root ssh key tampering
-w /root/.ssh -p wa -k rootkey

## Kernel parameters
-w /etc/sysctl.conf -p wa -k sysctl
-w /etc/sysctl.d -p wa -k sysctl

## Kernel module loading and unloading
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/insmod -k modules
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/modprobe -k modules
-a always,exit -F perm=x -F auid!=-1 -F path=/sbin/rmmod -k modules
-a always,exit -F arch=b64 -S finit_module -S init_module -S delete_module -F auid!=-1 -k modules

### NFS mount: maybe fake NFS client
-a always,exit -F path=/sbin/mount.nfs -F perm=x -F auid>=500 -F auid!=-1 -k nfs_mount
-a always,exit -F path=/usr/sbin/mount.nfs -F perm=x -F auid>=500 -F auid!=-1 -k nfs_mount

# Core Files that should not be touched on any compute node
## Cron configuration & scheduled jobs
-w /etc/cron.allow -p wa -k cron
-w /etc/cron.deny -p wa -k cron
-w /etc/cron.d/ -p wa -k cron
-w /etc/cron.daily/ -p wa -k cron
-w /etc/cron.hourly/ -p wa -k cron
-w /etc/cron.monthly/ -p wa -k cron
-w /etc/cron.weekly/ -p wa -k cron
-w /etc/crontab -p wa -k cron
-w /var/spool/cron/ -p wa -k cron

## Network configuration files
-w /etc/resolv.conf -p wa -k network_modify
-w /etc/hosts -p wa -k network_modify
-w /etc/nsswitch.conf -p wa -k network_modify
-w /etc/systemd/resolved.conf -p wa -k network_modify

## User, group, password databases
-w /etc/group -p wa -k group_modification
-w /etc/passwd -p wa -k user_modification
-w /etc/gshadow -k group_modification
-w /etc/shadow -k user_modification
-w /etc/security/opasswd -k opasswd

## Sudoers file changes
-w /etc/sudoers -p wa -k actions
-w /etc/sudoers.d/ -p wa -k actions

## Passwd
-w /usr/bin/passwd -p x -k passwd_modification

## Tools to change group identifiers
-w /usr/sbin/groupadd -p x -k group_modification
-w /usr/sbin/groupmod -p x -k group_modification
-w /usr/sbin/addgroup -p x -k group_modification
-w /usr/sbin/useradd -p x -k user_modification
-w /usr/sbin/userdel -p x -k user_modification
-w /usr/sbin/usermod -p x -k user_modification
-w /usr/sbin/adduser -p x -k user_modification

## Login configuration and information
-w /etc/login.defs -p wa -k login
-w /var/log/faillog -p wa -k login
-w /var/log/lastlog -p wa -k login

## SSH configuration
-w /etc/ssh/sshd_config -k sshd
-w /etc/ssh/sshd_config.d -k sshd

# Anything about authentication and permissions
## Process ID change (switching accounts) applications
-w /bin/su -p x -k priv_esc
-w /usr/bin/sudo -p x -k priv_esc

## Discretionary Access Control (DAC) modifications
-a always,exit -F arch=b64 -S chmod -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S chown -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchmod -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchmodat -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchown -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fchownat -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fremovexattr -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S fsetxattr -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lchown -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lremovexattr -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S lsetxattr -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S removexattr -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -F auid!=-1 -k perm_mod

# Suspicious Activities
-w /usr/bin/whoami -p x -k susp_activity
-w /usr/bin/id -p x -k susp_activity
-w /bin/hostname -p x -k susp_activity
-w /bin/uname -p x -k susp_activity
-w /etc/issue -p r -k susp_activity
-w /etc/hostname -p r -k susp_activity

-w /usr/bin/wget -p x -k susp_activity
-w /usr/bin/curl -p x -k susp_activity
-w /usr/bin/base64 -p x -k susp_activity
-w /bin/nc -p x -k susp_activity
-w /bin/netcat -p x -k susp_activity
-w /usr/bin/ss -p x -k susp_activity
-w /usr/bin/netstat -p x -k susp_activity
-w /usr/bin/ps -p x -k susp_activity

## File Access
### Unauthorized Access (unsuccessful)
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=-1 -F exe!=/usr/bin/ps -k file
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=-1 -F exe!=/usr/bin/ps -k file

### Unsuccessful Creation
-a always,exit -F arch=b64 -S mkdir,creat,link,symlink,mknod,mknodat,linkat,symlinkat -F exit=-EACCES -k file
-a always,exit -F arch=b64 -S mkdir,link,symlink,mkdirat -F exit=-EPERM -k file

### Unsuccessful Modification
-a always,exit -F arch=b64 -S rename,renameat,truncate -F exit=-EACCES -k file
-a always,exit -F arch=b64 -S rename,renameat,truncate -F exit=-EPERM -k file

# Record all commands executed
# -a exit,always -S execve

## Root command executions
-a always,exit -F arch=b64 -F euid=0 -F auid!=-1 -S execve -k rootcmd
EOF

systemctl disable auditd

cat > /etc/sudoers.d/audit <<EOF
Defaults log_subcmds
#Defaults log_format=json
#Defaults logfile=/var/log/sudo.log
#Defaults !syslog
# https://www.sudo.ws/pipermail/sudo-users/2023-February/006538.html
Defaults !intercept_verify
EOF
