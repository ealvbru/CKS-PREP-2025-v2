#!/bin/bash
set -euo pipefail
echo "[Q22] Setting up Runtime Detection lab..."

# Create namespace
kubectl create namespace cks-runtime-detect --dry-run=client -o yaml | kubectl apply -f -

# Create suspicious-writer pod
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: suspicious-writer
  namespace: cks-runtime-detect
spec:
  containers:
  - name: writer
    image: alpine:3.20
    command:
    - sh
    - -c
    - |
      touch /tmp/ok;
      cat /etc/passwd;
      sleep 3600
EOF

# Create net-tool pod (uses network tools — suspicious)
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: net-tool
  namespace: cks-runtime-detect
spec:
  containers:
  - name: net
    image: alpine:3.20
    command:
    - sh
    - -c
    - |
      apk add --no-cache curl 2>/dev/null || true;
      sleep 3600
EOF

# Clean up previous evidence
rm -f /root/runtime-detect-evidence.txt 2>/dev/null || true

echo "[Q22] Lab setup complete."
echo "  Namespace: cks-runtime-detect"
echo "  Pods: suspicious-writer, net-tool"
echo "  NOTE: Falco must be running to generate alerts"
