#!/bin/bash

debian() {
	# otelcol will start the systemd service in the postinst script, causing errors in the nspawn environment
	install_pkg_from_github "open-telemetry/opentelemetry-collector-releases" 'contains("contrib") and endswith ("linux_amd64.deb")' || true
	rm -f /var/lib/dpkg/info/otelcol-contrib.postinst
	dpkg --configure -a >/dev/null
	apt-get --fix-broken --fix-missing install
}

ubuntu() {
	debian
}

arch() {
	get_asset_from_github "open-telemetry/opentelemetry-collector-releases" 'contains("contrib") and endswith("linux_amd64.tar.gz")' /tmp/otelcol-contrib.tar.gz
	tar -C /usr/bin -xzf /tmp/otelcol-contrib.tar.gz otelcol-contrib
	mkdir -p /etc/otelcol-contrib
	wget https://raw.githubusercontent.com/open-telemetry/opentelemetry-collector-releases/refs/heads/main/distributions/otelcol-contrib/otelcol-contrib.service -O /etc/systemd/system/otelcol-contrib.service
	wget https://raw.githubusercontent.com/open-telemetry/opentelemetry-collector-releases/refs/heads/main/distributions/otelcol-contrib/otelcol-contrib.conf -O /etc/otelcol-contrib/otelcol-contrib.conf
	systemctl enable otelcol-contrib
}

openEuler() {
	install_pkg_from_github "open-telemetry/opentelemetry-collector-releases" 'contains("contrib") and endswith("linux_amd64.rpm")'
}

check_and_exec "$ID"

curl https://raw.githubusercontent.com/ZJUSCT/clusters.zju.edu.cn/refs/heads/main/config/otelcol/agent.yaml -o /etc/otelcol-contrib/config.yaml
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
