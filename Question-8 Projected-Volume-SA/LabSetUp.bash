#!/bin/bash
set -e

echo "🔹 Creating namespace: secure-app"
kubectl create namespace secure-app --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Creating ServiceAccount 'backend-sa'..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend-sa
  namespace: secure-app
automountServiceAccountToken: true
EOF

echo "🔹 Creating deployment YAML at ~/backend-deploy.yaml..."
cat <<'DEPLOY' > ~/backend-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: secure-app
  labels:
    app: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      serviceAccountName: backend-sa
      containers:
      - name: backend
        image: busybox:1.36
        command: ["sleep", "3600"]
        # TODO: Add volumeMount for projected SA token
      # TODO: Add projected volume with serviceAccountToken
DEPLOY

echo "🔹 Applying initial deployment..."
kubectl apply -f ~/backend-deploy.yaml

echo ""
echo "✅ Lab setup complete!"
echo "   - Namespace: secure-app"
echo "   - ServiceAccount: backend-sa (automountServiceAccountToken: true)"
echo "   - Deployment YAML: ~/backend-deploy.yaml"
echo "   - Your task: disable automount, add projected volume, apply"
