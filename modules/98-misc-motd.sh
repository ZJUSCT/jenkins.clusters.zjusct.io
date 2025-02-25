#!/bin/bash

case $ID in
arch) # arch has no update-motd
	;;
*)
	rm -f /etc/update-motd.d/*
# https://github.com/Gaeldrin/nice-motd
	cat >/etc/update-motd.d/00-nice-motd <<'EOF'
#!/bin/bash --norc
printf "\nWelcome to "; hostname 
# printf "  Kernel: "; uname -v
printf "  "; uptime -p
printf "\nSystem information as of "; date --rfc-3339=seconds
printf "\n"

printf "  CPU load: "; cat /proc/loadavg | awk '{ printf "%s %s %s\n", $1, $2, $3; }'
# RAM
free -m | awk '/Mem/  { printf "  Memory:  %4sM  (%2d%%)  out of %2.1fG\n", $3, ($3/$2) * 100, $2/1000; }
			/Swap/ {
                       if ( $3 == 0 )
			printf "  Swap:     not available\n";
                       else
                           printf "  Swap:    %4sM  (%2d%%)  out of %2.1fG\n", $3, ($3/$2) * 100, $2/1000;

			}'

df -h | awk '/^\//  { printf "  Disk:    %5s  (%3s)  out of %4s %s\n", $3, $5, $2, $6; }'
df -h | awk '/^storage/ { printf "   NFS:    %5s  (%3s)  out of %4s %s\n", $3, $5, $2, $6; }'
printf "\n"
users
EOF
	chmod +x /etc/update-motd.d/00-nice-motd

	cat >/etc/motd <<EOF
See https://go.zjusct.io/opendocs for more information.
See https://clusters.zju.edu.cn for cluster metrics.
EOF
	;;
esac
