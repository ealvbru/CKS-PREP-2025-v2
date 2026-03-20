#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sbom"
DEPLOY_FILE="${HOME}/alpine-deploy.yaml"
TRIVY_VERSION="v0.58.0"
BOM_VERSION="v0.6.0"
INSTALL_DIR="/usr/local/bin"

log() {
  echo "🔹 $1"
}

warn() {
  echo "⚠️  $1"
}

success() {
  echo "✅ $1"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_trivy() {
  if require_cmd trivy; then
    log "Trivy already installed: $(trivy --version | head -n 1)"
    return
  fi

  log "Installing Trivy..."
  if require_cmd curl; then
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b "${INSTALL_DIR}" "${TRIVY_VERSION}" || {
      warn "Automatic Trivy installation failed."
      warn "Install manually with:"
      echo "curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ${INSTALL_DIR}"
      return 1
    }
  else
    warn "curl not found. Cannot auto-install Trivy."
    return 1
  fi

  log "Trivy installed successfully: $(trivy --version | head -n 1)"
}

install_bom() {
  if require_cmd bom; then
    log "bom already installed"
    return
  fi

  log "Installing bom..."
  if require_cmd curl; then
    curl -fsSL -o "${INSTALL_DIR}/bom" \
      "https://github.com/kubernetes-sigs/bom/releases/download/${BOM_VERSION}/bom-amd64-linux" || {
      warn "Automatic bom installation failed."
      warn "Install manually from: https://github.com/kubernetes-sigs/bom"
      return 1
    }
    chmod +x "${INSTALL_DIR}/bom"
    log "bom installed successfully"
  else
    warn "curl not found. Cannot auto-install bom."
    return 1
  fi
}

log "Checking required tools..."
if ! require_cmd kubectl; then
  echo "❌ kubectl is required but not installed."
  exit 1
fi

if ! require_cmd curl; then
  echo "❌ curl is required but not installed."
  exit 1
fi

log "Creating namespace: ${NAMESPACE}"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

log "Creating deployment YAML file at ${DEPLOY_FILE}..."
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

log "Applying the deployment..."
kubectl apply -f "${DEPLOY_FILE}"

install_trivy || true
install_bom || true

echo ""
success "Lab setup complete!"
echo "   - Namespace: ${NAMESPACE}"
echo "   - Deployment: alpine-multi (3 containers: alpine-v1, alpine-v2, alpine-v3)"
echo "   - Deployment YAML: ${DEPLOY_FILE}"
echo "   - Tools available: trivy, bom"
echo "   - Your task: find the vulnerable container, remove it, generate SPDX report"
