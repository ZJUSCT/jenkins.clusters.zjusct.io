#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
debian(){
	apt-get install -y apt-transport-https ca-certificates curl gnupg
	curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
	chmod 644 /etc/apt/sources.list.d/kubernetes.list
	apt-get update
	install_pkg kubectl kubeadm kubelet
	systemctl disable kubelet
}

ubuntu()
{
	debian
}

openEuler(){
	cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF
	install_pkg kubelet kubeadm kubectl --disableexcludes=kubernetes
	systemctl disable kubelet
}

check_and_exec "$ID"

# configure containerd
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
mkdir -p /etc/containerd
cat > /etc/containerd/config.toml <<EOF
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.k8s.io/pause:3.10"
EOF

mkdir -p /etc/systemd/system/containerd.service.d
cat > /etc/systemd/system/containerd.service.d/override.conf <<EOF
[Service]
Environment="HTTPS_PROXY=${PROXY}"
Environment="HTTP_PROXY=${PROXY}"
EOF
