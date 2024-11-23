#!/bin/bash
export http_proxy=$PROXY
export https_proxy=$PROXY

# otelcol will start the systemd service in the postinst script, causing errors in the nspawn environment
install_deb_from_github "open-telemetry/opentelemetry-collector-releases" 'endswith("linux_amd64.deb") and contains("contrib")' || true
rm -f /var/lib/dpkg/info/otelcol-contrib.postinst
dpkg --configure -a >/dev/null
apt-get --fix-broken --fix-missing install

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
