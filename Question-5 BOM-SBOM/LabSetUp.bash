#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sbom"
DEPLOY_FILE="${HOME}/alpine-deploy.yaml"
# Use the full version string expected by their script
TRIVY_VERSION="0.58.0" 
BOM_VERSION="v0.6.0"
INSTALL_DIR="/usr/local/bin"

log() { echo "🔹 $1"; }
success() { echo "✅ $1"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_trivy() {
  if require_cmd trivy; then
    log "Trivy already installed."
    return
  fi

  log "Installing Trivy v${TRIVY_VERSION} via official installer..."
  
  # The official script is the most robust way to get the right arch/OS binary
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b "${INSTALL_DIR}" "v${TRIVY_VERSION}" || {
    log "Direct install failed, trying local directory..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b . "v${TRIVY_VERSION}"
  }
}

install_bom() {
  if require_cmd bom; then
    log "bom already installed"
    return
  fi

  log "Installing bom..."
  # Kubernetes SIGs use a very specific naming convention
  curl -L -o "bom" "https://github.com/kubernetes-sigs/bom/releases/download/${BOM_VERSION}/bom-amd64-linux"
  chmod +x "bom"
  sudo mv bom "${INSTALL_DIR}/" 2>/dev/null || log "bom kept in current directory"
}

# --- Infrastructure Setup ---

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

install_trivy
install_bom

echo ""
success "Lab setup complete!"
