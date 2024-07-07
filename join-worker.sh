#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <master_ip> <node_token>"
    exit 1
fi

MASTER_IP=$1
NODE_TOKEN=$2

curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 K3S_TOKEN=${NODE_TOKEN} sh -

echo "Waiting for node to be ready..."
sleep 30

sudo k3s kubectl get nodes

echo "Worker node joined successfully!"
