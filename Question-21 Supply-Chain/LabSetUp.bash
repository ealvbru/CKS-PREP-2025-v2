#!/bin/bash
set -euo pipefail
echo "[Q21] Setting up Supply Chain lab..."

# Create namespace
kubectl create namespace cks-supply --dry-run=client -o yaml | kubectl apply -f -

# Create deployment with insecure "latest" tag
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: untrusted-app
  namespace: cks-supply
spec:
  replicas: 1
  selector:
    matchLabels:
      app: untrusted-app
  template:
    metadata:
      labels:
        app: untrusted-app
    spec:
      containers:
      - name: app
        image: docker.io/library/nginx:latest
EOF

# Clean up previous evidence
rm -f /root/supply-chain-evidence.txt 2>/dev/null || true

echo "[Q21] Lab setup complete."
echo "  Namespace: cks-supply"
echo "  Deployment: untrusted-app (uses nginx:latest — INSECURE)"
