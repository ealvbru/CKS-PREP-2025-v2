#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 2: Istio mTLS Sidecar
# ══════════════════════════════════════════════════════════════════════

# Step 1: Enable sidecar injection for the namespace
kubectl label namespace mesh-app istio-injection=enabled --overwrite

# Step 2: Restart the deployment to inject the sidecar
kubectl rollout restart deployment httpbin -n mesh-app
kubectl rollout status deployment httpbin -n mesh-app

# Step 3: Verify 2/2 containers (app + istio-proxy)
kubectl get pods -n mesh-app
# Should show 2/2 READY

# Step 4: Create PeerAuthentication to enforce STRICT mTLS
cat <<'YAML' > /tmp/peer-auth.yaml
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: strict-mtls
  namespace: mesh-app
spec:
  mtls:
    mode: STRICT
YAML
kubectl apply -f /tmp/peer-auth.yaml

# Verify
kubectl get peerauthentication -n mesh-app

# ══════════════════════════════════════════════════════════════════════
EOF
