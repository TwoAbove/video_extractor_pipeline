# K3s Video Processing Pipeline

This repository contains the setup scripts and configuration files for a scalable video processing pipeline using K3s.

## Prerequisites

- A machine with K3s installed (the setup script will install K3s if not present)
- Docker (for building worker images)

## Setup

1. Clone this repository:

   ```sh
   git clone https://github.com/TwoAbove/video_extractor_pipeline.git
   cd video_extractor_pipeline
   ```

2. Run the setup script:

   ```sh
   chmod +x setup.sh
   ./setup.sh
   ```

   This script will:
   - Install K3s (if not already installed)
   - Install Helm
   - Deploy Loki, Promtail, and Grafana

3. Access Grafana:
   - Navigate to `http://<your-k3s-node-ip>:30300` in your web browser
   - Use "admin" as the username
   - Get the password by running `kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`

## Troubleshooting

If you encounter any issues, check the logs of the respective components:

```bash
kubectl logs -n monitoring deployment/loki
kubectl logs -n monitoring daemonset/promtail
kubectl logs -n monitoring deployment/grafana
```

For worker logs, use:

```bash
kubectl logs job/video-processing-job
```

## Adding Worker Nodes

To scale your cluster by adding worker nodes:

1. On the master node, retrieve the node token:

   ```sh
   sudo cat /var/lib/rancher/k3s/server/node-token
   ```

2. On each machine you want to add as a worker node, run `join-worker.sh` with the IP address of the master node and the node token. Replace `<master_ip>` with the IP address of your master node, and `<node_token>` with the token retrieved in step 1.

   ```sh
   curl -sfL https://raw.githubusercontent.com/TwoAbove/video_extractor_pipeline/master/join-worker.sh | bash -s -- <master_ip> <node_token>
   ```

3. Verify that the new node has joined the cluster by running on the master node:

   ```sh
   sudo k3s kubectl get nodes
   ```
