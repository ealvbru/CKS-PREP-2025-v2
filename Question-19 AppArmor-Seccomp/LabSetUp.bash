#!/bin/bash
set -euo pipefail
echo "[Q19] Setting up AppArmor + Seccomp lab..."

# Create namespace
kubectl create namespace cks-hardening --dry-run=client -o yaml | kubectl apply -f -

# Create deployment WITHOUT seccomp and apparmor (student must add them)
cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hardened-app
  namespace: cks-hardening
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hardened-app
  template:
    metadata:
      labels:
        app: hardened-app
    spec:
      containers:
      - name: app
        image: nginx:1.27
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop: ["ALL"]
EOF

echo "[Q19] Lab setup complete."
echo "  Namespace: cks-hardening"
echo "  Deployment: hardened-app (needs seccomp + apparmor)"
