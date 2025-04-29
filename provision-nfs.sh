#! /bin/bash

sudo apt-get update -y
sudo apt-get install -y nfs-kernel-server
sudo mkdir -p /srv/nfs/k8s
sudo chown nobody:nogroup /srv/nfs/k8s
sudo chmod 777 /srv/nfs/k8s
echo "/srv/nfs/k8s 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
sudo systemctl restart nfs-kernel-server
sudo exportfs -rav
