#!/bin/bash

case $ID in
arch) # arch has no update-motd
	;;
*)
	rm -f /etc/update-motd.d/*
# https://github.com/Gaeldrin/nice-motd
# 	cat >/etc/update-motd.d/00-nice-motd <<'EOF'
# #!/bin/sh
# printf "\nWelcome to "; lsb_release -ds
# printf "  Kernel: "; uname -v
# printf "System is "; uptime -p
# printf "\nSystem information as of "; date
# printf "\n"
# # CPU
# printf "  CPU load: "; cat /proc/loadavg | awk '{ printf "%s %s %s", $1, $2, $3; }'
# printf " ("
# printf $(($(ps -e --no-headers | wc -l) - 1))
# printf " processes)\n"
# # RAM
# free -m | awk '/Mem/  { printf "  Memory:  %4sM  (%2d%%)  out of %2.1fG\n", $3, ($3/$2) * 100, $2/1000; }
# 		/Swap/ {
#                         if ( $3 == 0 )
# 				printf "  Swap:     not available\n";
#                         else
#                             printf "  Swap:    %4sM  (%2d%%)  out of %2.1fG\n", $3, ($3/$2) * 100, $2/1000;

# 			}'
# # Disk
# df -h   | awk '/^\//  { printf "  Disk:    %5s  (%3s)  out of %4s %s\n", $3, $5, $2, $6; }'
# printf "\n"
# w -h | awk 'BEGIN { printf "Users logged in:"; }
# 		{ printf " %s", $1; }'
# top -bn1 | awk 'BEGIN { FS=",  "; }
#                 $2~/user/ { print " (" $2 " total)"; }
#                 $3~/user/ { print " (" $3 " total)"; }'
# printf "\n"
# EOF
	# chmod +x /etc/update-motd.d/00-nice-motd

# motd for cluster manager
# 	cat >/etc/update-motd.d/01-cluster-manager <<'EOF'
# #!/bin/sh
# # warn if /home has less than 500GB
# if [ $(df -h /home | awk '/\// { print $4 }' | sed 's/G//') -lt 500 ]; then
# 	echo -e "\e[31mWARNING: /home has less than 500GB free space\e[0m"
# fi
# EOF

	cat >/etc/motd <<EOF
See https://go.zjusct.io/opendocs for more information.
See https://clusters.zju.edu.cn for cluster metrics.
EOF
	;;
esac
