#! /bin/bash

sudo apt install -y apt-transport-https ca-certificates curl gpg -y
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt remove $pkg; done

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

# Install docker
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Install kubeadm, kubelet, kubectl
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet docker containerd

# Create group docker
sudo groupadd docker
sudo usermod -aG docker vagrant
newgrp docker

# Update containerd config
sudo containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
sudo sed -i 's/sandbox_image = ".*"/sandbox_image = "registry.k8s.io\/pause:3.10"/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Enable br_netfilter
sudo modprobe br_netfilter
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
echo br_netfilter | sudo tee /etc/modules-load.d/k8s.conf
sudo systemctl restart kubelet

# Create alias
echo 'alias k="kubectl"' >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y

# Install Kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo ln -n ./kustomize /usr/bin/

# START script controlplane
if [ "$(hostname)" = "controlplane" ]; then
  # Installer ETCD
  ETCD_VER=v3.6.0-rc.4
  DOWNLOAD_URL=https://storage.googleapis.com/etcd

  mkdir -p /home/vagrant/etcd_backup/
  mkdir -p /home/vagrant/etcd

  rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
  curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
  tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /home/vagrant/etcd --strip-components=1
  rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
  ln -sf /home/vagrant/etcd/etcdctl /usr/bin/etcdctl

  # Ajouter au crontab pour backup à chaque reboot
  (crontab -l 2>/dev/null; echo "@reboot /home/vagrant/etcd_backup/etcd-backup.sh >> /home/vagrant/etcd_backup/backup.log 2>&1") | crontab -

  # Install Argocd
  curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
  sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
  rm argocd-linux-amd64
  mkdir argocd
fi
# END HOSTNAME Controlplane

chown -R vagrant: /home/vagrant
usermod -aG admin vagrant
