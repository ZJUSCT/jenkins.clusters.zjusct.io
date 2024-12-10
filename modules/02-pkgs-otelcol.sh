#!/bin/bash

case $ID in
debian | ubuntu)
	# otelcol will start the systemd service in the postinst script, causing errors in the nspawn environment
	install_pkg_from_github "open-telemetry/opentelemetry-collector-releases" 'contains("contrib")' || true
	rm -f /var/lib/dpkg/info/otelcol-contrib.postinst
	dpkg --configure -a >/dev/null
	apt-get --fix-broken --fix-missing install
	;;
arch)
	# TODO
	;;
*)
	install_pkg_from_github "open-telemetry/opentelemetry-collector-releases" 'contains("contrib")'
	;;
esac

curl https://ghp.ci/https://raw.githubusercontent.com/ZJUSCT/clusters.zju.edu.cn/refs/heads/main/config/otelcol/agent.yaml -o /etc/otelcol-contrib/config.yaml
mkdir -p /etc/systemd/system/otelcol-contrib.service.d
cat >/etc/systemd/system/otelcol-contrib.service.d/override.conf <<EOF
[Unit]
After=docker.service
Requires=docker.service
[Service]
User=root
Group=root
Environment=OTEL_CLOUD_REGION=zjusct-cluster
EOF

# remember to set Environment=OTEL_BEARER_TOKEN=
# centralized logging for otelcol
cat >/etc/systemd/journald.conf <<EOF
[Journal]
Storage=volatile
EOF
