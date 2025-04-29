#! /bin/bash

# Installer ETCD
ETCD_VER=v3.6.0-rc.4
DOWNLOAD_URL=https://storage.googleapis.com/etcd
mkdir -p /home/vagrant/etcd
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /home/vagrant/etcd --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
ln -sf /home/vagrant/etcd/etcdctl /usr/bin/etcdctl

# Install Argocd
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
mkdir argocd

# Config kubelet.service configuration file
sudo rm -rf /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo ln -s /home/vagrant/volumes/10-kubeadm.conf /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf 
sudo systemctl daemon-reload

# Config etcd_backup
mkdir -p /home/vagrant/etcd_backup/
ln -s /home/vagrant/volumes/etcd-backup.sh /home/vagrant/etcd_backup/etcd-backup.sh
sudo chmod +x /home/vagrant/etcd_backup/etcd-backup.sh
sudo chown vagrant: /home/vagrant/etcd_backup/etcd-backup.sh

# Ajouter au crontab pour backup à chaque reboot
(crontab -l 2>/dev/null; echo "@reboot /home/vagrant/etcd_backup/etcd-backup.sh >> /home/vagrant/etcd_backup/backup.log 2>&1") | crontab -

chown -R vagrant: /home/vagrant
usermod -aG admin vagrant

sudo reboot
