#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sbom"
DEPLOY_FILE="${HOME}/alpine-deploy.yaml"
TRIVY_VER="0.58.0"
BOM_VER="v0.6.0"
INSTALL_DIR="/usr/local/bin"

log() { echo "🔹 $1"; }
success() { echo "✅ $1"; }

# 1. Setup Infrastructure
log "Creating namespace: ${NAMESPACE}"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

log "Creating deployment YAML..."
cat <<EOF > "${DEPLOY_FILE}"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alpine-multi
  namespace: ${NAMESPACE}
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
kubectl apply -f "${DEPLOY_FILE}"

# 2. Install Trivy (Robust Method)
if ! command -v trivy >/dev/null 2>&1; then
    log "Installing Trivy ${TRIVY_VER}..."
    # Explicitly targeting Linux 64-bit
    URL="https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VER}/trivy_${TRIVY_VER}_Linux-64bit.tar.gz"
    curl -sL "$URL" -o trivy.tar.gz
    tar -xzf trivy.tar.gz trivy
    chmod +x trivy
    sudo mv trivy "${INSTALL_DIR}/" || mv trivy ./
    rm trivy.tar.gz
    success "Trivy installed."
else
    log "Trivy already exists."
fi

# 3. Install BOM
if ! command -v bom >/dev/null 2>&1; then
    log "Installing bom ${BOM_VER}..."
    curl -sL -o bom "https://github.com/kubernetes-sigs/bom/releases/download/${BOM_VER}/bom-amd64-linux"
    chmod +x bom
    sudo mv bom "${INSTALL_DIR}/" || true
    success "bom installed."
else
    log "bom already exists."
fi

echo ""
success "Lab setup complete!"
echo "Next steps:"
echo "1. Run: trivy image alpine:3.16.1"
echo "2. Edit ${DEPLOY_FILE} to remove the vulnerable container."
echo "3. Run: bom generate --image alpine:3.20.0 -o spdx-report.json"
