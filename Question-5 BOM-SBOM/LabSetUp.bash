#!/bin/bash
set -e

echo "🔹 Creating namespace: sbom"
kubectl create namespace sbom --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Creating deployment YAML file at ~/alpine-deploy.yaml..."
cat <<'EOF' > ~/alpine-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alpine-multi
  namespace: sbom
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alpine-multi
  template:
    metadata:
      labels:
        app: alpine-multi
    spec:
      containers:
      - name: alpine-v1
        image: alpine:3.20.0
        command: ["sleep", "3600"]
      - name: alpine-v2
        image: alpine:3.19.6
        command: ["sleep", "3600"]
      - name: alpine-v3
        image: alpine:3.16.1
        command: ["sleep", "3600"]
EOF

echo "🔹 Applying the deployment..."
kubectl apply -f ~/alpine-deploy.yaml

echo "🔹 Installing trivy (if not present)..."
if ! command -v trivy &>/dev/null; then
  echo "   Downloading trivy..."
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.58.0 2>/dev/null || {
    echo "⚠️  trivy auto-install failed. Install manually:"
    echo "   curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
  }
fi

echo "🔹 Installing bom tool (if not present)..."
if ! command -v bom &>/dev/null; then
  echo "   Downloading bom..."
  BOM_VERSION="v0.6.0"
  curl -sLo /usr/local/bin/bom "https://github.com/kubernetes-sigs/bom/releases/download/${BOM_VERSION}/bom-amd64-linux" 2>/dev/null && \
    chmod +x /usr/local/bin/bom || echo "⚠️  bom auto-install failed. Install manually from https://github.com/kubernetes-sigs/bom"
fi

echo ""
echo "✅ Lab setup complete!"
echo "   - Namespace: sbom"
echo "   - Deployment: alpine-multi (3 containers: alpine-v1, alpine-v2, alpine-v3)"
echo "   - Deployment YAML: ~/alpine-deploy.yaml"
echo "   - Tools available: trivy, bom"
echo "   - Your task: find the vulnerable container, remove it, generate SPDX report"
