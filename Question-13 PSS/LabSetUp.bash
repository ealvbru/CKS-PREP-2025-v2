#!/bin/bash
set -e

echo "🔹 Creating namespace with restricted PSS enforcement..."
kubectl create namespace restricted-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace restricted-ns \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/warn=restricted \
  pod-security.kubernetes.io/warn-version=latest \
  --overwrite

echo "🔹 Creating non-compliant deployment YAML at ~/pss-deploy.yaml..."
cat <<'DEPLOY' > ~/pss-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: restricted-ns
  labels:
    app: secure-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: app
        image: busybox:1.36
        command: ["sleep", "3600"]
        securityContext:
          privileged: true
          runAsUser: 0
DEPLOY

echo "🔹 Attempting to apply the non-compliant deployment..."
kubectl apply -f ~/pss-deploy.yaml 2>&1 || true

echo ""
echo "✅ Lab setup complete!"
echo "   - Namespace: restricted-ns (PSS enforce=restricted)"
echo "   - Deployment YAML: ~/pss-deploy.yaml (non-compliant — pods won't start)"
echo "   - Your task: check RS events, fix the deployment, reapply"
