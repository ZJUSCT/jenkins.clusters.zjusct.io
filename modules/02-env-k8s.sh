#!/bin/bash
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

debian(){
	apt-get install -y apt-transport-https ca-certificates curl gnupg
	curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
	chmod 644 /etc/apt/sources.list.d/kubernetes.list
	apt-get update
	apt-get install -y kubectl kubeadm kubelet
	apt-mark hold kubelet kubeadm kubectl
	systemctl enable kubelet
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
	yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
	systemctl enable kubelet
}

check_and_exec "$ID"
