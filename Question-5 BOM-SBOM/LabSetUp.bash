#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sbom"
DEPLOY_FILE="${HOME}/alpine-deploy.yaml"
TRIVY_VERSION="0.58.0" # Removed 'v' for the direct download URL
BOM_VERSION="v0.6.0"
INSTALL_DIR="/usr/local/bin"

log() { echo "🔹 $1"; }
warn() { echo "⚠️  $1"; }
success() { echo "✅ $1"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_trivy() {
  if require_cmd trivy; then
    log "Trivy already installed: $(trivy --version | head -n 1)"
    return
  fi

  log "Installing Trivy ${TRIVY_VERSION}..."
  # Use a direct binary download if the install script fails
  # Adjusting for x86_64 Linux - common for CKS environments
  curl -Lo trivy.tar.gz "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"
  tar xzf trivy.tar.gz trivy
  
  # Try to move to /usr/local/bin, fallback to current dir if permission denied
  sudo mv trivy "${INSTALL_DIR}/" 2>/dev/null || mv trivy ./
  rm trivy.tar.gz
  
  if require_cmd trivy || [ -f "./trivy" ]; then
    success "Trivy ready."
  else
    warn "Trivy installation failed. Run: sudo apt-get install trivy"
  fi
}

install_bom() {
  if require_cmd bom; then
    log "bom already installed"
    return
  fi

  log "Installing bom..."
  curl -fsSL -o "bom" "https://github.com/kubernetes-sigs/bom/releases/download/${BOM_VERSION}/bom-amd64-linux"
  chmod +x "bom"
  sudo mv bom "${INSTALL_DIR}/" 2>/dev/null || log "bom kept in current directory (no sudo)"
}

# --- Execution Starts Here ---

log "Checking dependencies..."
for cmd in kubectl curl tar; do
  if ! require_cmd "$cmd"; then
    echo "❌ $cmd is required. Please install it first."
    exit 1
  fi
done

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

log "Applying deployment..."
kubectl apply -f "${DEPLOY_FILE}"

install_trivy
install_bom

echo ""
success "Lab setup complete!"
