#!/bin/bash

export ETCDCTL_API=3
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/home/vagrant/etcd_backup"
SNAPSHOT="${BACKUP_DIR}/snapshot-${TIMESTAMP}.db"

sudo etcdctl snapshot save "$SNAPSHOT" \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key

# Garder seulement les 7 derniers backups
cd "$BACKUP_DIR"
ls -1tr snapshot-*.db | head -n -7 | xargs --no-run-if-empty rm -f

