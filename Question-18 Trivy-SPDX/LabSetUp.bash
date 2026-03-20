#!/bin/bash
set -euo pipefail
echo "[Q18] Setting up Trivy/SPDX lab..."

# Create working directory
mkdir -p /root/cks-lab-trivy

# Create Dockerfile
cat > /root/cks-lab-trivy/Dockerfile <<'EOF'
FROM alpine:3.16.1
RUN apk add --no-cache openssl curl busybox
CMD ["sh", "-c", "sleep 3600"]
EOF

# Create namespace
kubectl create namespace cks-trivy --dry-run=client -o yaml | kubectl apply -f -

# Create deployment with vulnerable image
cat > /root/cks-lab-trivy/deploy.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vuln-app
  namespace: cks-trivy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vuln-app
  template:
    metadata:
      labels:
        app: vuln-app
    spec:
      containers:
      - name: app
        image: alpine:3.16.1
        command: ["sh", "-c", "sleep 3600"]
EOF

kubectl apply -f /root/cks-lab-trivy/deploy.yaml

# Clean up previous output files
rm -f /root/trivy-image-report.txt /root/trivy-config-report.txt /root/trivy-sbom.spdx.json 2>/dev/null || true

echo "[Q18] Lab setup complete."
echo "  Namespace: cks-trivy"
echo "  Files: /root/cks-lab-trivy/Dockerfile, /root/cks-lab-trivy/deploy.yaml"
echo "  NOTE: trivy must be installed (apt install trivy or snap install trivy)"
