#!/bin/bash

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install K3s if not already installed
if ! command_exists k3s; then
    echo "Installing K3s..."
    curl -sfL https://get.k3s.io | sh -
    # Wait for K3s to be ready
    until kubectl get nodes; do sleep 1; done
else
    echo "K3s is already installed."
fi

# Install Helm if not already installed
if ! command_exists helm; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
else
    echo "Helm is already installed."
fi

# Add Grafana Helm repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install Loki and Promtail
helm upgrade --install loki grafana/loki-stack -f loki-values.yaml --namespace monitoring

# Install Grafana
helm upgrade --install grafana grafana/grafana -f grafana-values.yaml --namespace monitoring

# Setup psql database credentials in secret file template

cat <<EOF > k3s-configs/psql-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
stringData:
  DB_HOST: "your_db_host_or_ip"
  DB_PORT: "5432"
  DB_NAME: "video_processing"
  DB_USER: "your_db_user"
  DB_PASSWORD: "your_db_password"
EOF


echo "Setup complete."
echo "Grafana is accessible at http://<your-k3s-node-ip>:30300"
echo "Use the following command to get the Grafana admin password:"
echo "kubectl get secret --namespace monitoring grafana -o jsonpath=\"{.data.admin-password}\" | base64 --decode ; echo"
echo "To deploy your worker, build the Docker image and update the image in worker-job.yaml, then run:"
echo "kubectl apply -f worker-job.yaml"
echo ""
echo "To add worker nodes to this cluster:"
echo "1. On this master node, run:"
echo "   sudo cat /var/lib/rancher/k3s/server/node-token"
echo "2. On each worker node, run:"
echo "   curl -sfL https://raw.githubusercontent.com/TwoAbove/video_extractor_pipeline/master/join-worker.sh | bash -s -- <master_ip> <node_token>"
echo "   Replace <master_ip> with the IP address of this master node, and <node_token> with the token from step 2"
