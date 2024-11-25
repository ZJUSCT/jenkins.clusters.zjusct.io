#!/bin/bash

# Copyright 2018-2023 Petr Všetečka <vsetecka@cesnet.cz>
#           2024-2025 Baolin Zhu <zhubaolin228@gmail.com> and ZJUSCT
#
# The following code is a derivative work of the code from the jenkins.debian.net,
# which is licensed GPLv3. This code therefore is also licensed under the terms
# of the GNU Public License, verison 3.

rm -f /etc/update-motd.d/*
cat >/etc/update-motd.d/00-nice-motd <<'EOF'
#!/bin/sh
printf "\nWelcome to "; lsb_release -ds
printf "  Kernel: "; uname -v
printf "System is "; uptime -p
printf "\nSystem information as of "; date
printf "\n"
# CPU
printf "  CPU load: "; cat /proc/loadavg | awk '{ printf "%s %s %s", $1, $2, $3; }'
printf " ("
printf $(($(ps -e --no-headers | wc -l) - 1))
printf " processes)\n"
# RAM
free -m | awk '/Mem/  { printf "  Memory:  %4sM  (%2d%%)  out of %2.1fG\n", $3, ($3/$2) * 100, $2/1000; }
               /Swap/ {
                        if ( $3 == 0 )
                            printf "  Swap:     not available\n";
                        else
                            printf "  Swap:    %4sM  (%2d%%)  out of %2.1fG\n", $3, ($3/$2) * 100, $2/1000;

                      }'
# Disk
df -h   | awk '/^\//  { printf "  Disk:    %5s  (%3s)  out of %4s %s\n", $3, $5, $2, $6; }'
printf "\n"
w -h | awk 'BEGIN { printf "Users logged in:"; }
                  { printf " %s", $1; }'
top -bn1 | awk 'BEGIN { FS=",  "; }
                $2~/user/ { print " (" $2 " total)"; }
                $3~/user/ { print " (" $3 " total)"; }'
printf "\n"
apt-get -s upgrade | awk '/newly installed,/ { print $1 " packages can be updated."; }'
printf $(($(apt-get -s upgrade | grep -ci "security") / 2))
printf " updates are security updates.\n\n"
EOF
chmod +x /etc/update-motd.d/00-nice-motd

cat >/etc/motd <<EOF
See https://go.zjusct.io/opendocs for more information.
EOF
