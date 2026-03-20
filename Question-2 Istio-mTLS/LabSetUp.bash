#!/bin/bash
set -e

echo "🔹 Creating namespace: mesh-app"
kubectl create namespace mesh-app --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Installing Istio (if istioctl is available)..."
if command -v istioctl &>/dev/null; then
  istioctl install --set profile=default -y 2>/dev/null || echo "⚠️  Istio install skipped"
else
  echo "⚠️  istioctl not found. Installing Istio..."
  curl -sL https://istio.io/downloadIstio | ISTIO_VERSION=1.23.0 sh - 2>/dev/null || true
  if [ -d istio-*/bin ]; then
    export PATH=$PWD/istio-*/bin:$PATH
    istioctl install --set profile=default -y 2>/dev/null || echo "⚠️  Istio install may need manual setup"
  fi
fi

echo "🔹 Ensuring Istio CRDs are available..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/manifests/charts/base/crds/crd-all.gen.yaml 2>/dev/null || true

echo "🔹 Deploying httpbin application (WITHOUT sidecar injection)..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin
  namespace: mesh-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
  template:
    metadata:
      labels:
        app: httpbin
    spec:
      containers:
      - name: httpbin
        image: kennethreitz/httpbin
        ports:
        - containerPort: 80
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: httpbin
  namespace: mesh-app
spec:
  selector:
    app: httpbin
  ports:
  - port: 80
    targetPort: 80
EOF

echo ""
echo "✅ Lab setup complete!"
echo "   - Namespace: mesh-app (NO sidecar injection label yet)"
echo "   - Deployment: httpbin (single container, no istio-proxy)"
echo "   - Your task: enable sidecar injection, restart pods, enforce STRICT mTLS"
