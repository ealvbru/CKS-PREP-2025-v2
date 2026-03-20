#!/bin/bash
set -e

echo "🔹 Creating namespace: tls-app"
kubectl create namespace tls-app --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Generating TLS certificate and key..."
mkdir -p /root/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /root/certs/tls.key -out /root/certs/tls.crt \
  -subj "/CN=nginx-tls.tls-app.svc.cluster.local/O=tls-app" 2>/dev/null

echo "🔹 Creating deployment YAML at ~/nginx-tls-deploy.yaml..."
cat <<'DEPLOY' > ~/nginx-tls-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-tls
  namespace: tls-app
  labels:
    app: nginx-tls
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-tls
  template:
    metadata:
      labels:
        app: nginx-tls
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 443
          protocol: TCP
        # TODO: Add volumeMount for TLS secret at /etc/nginx/ssl
      # TODO: Add volume referencing the TLS secret
DEPLOY

echo ""
echo "✅ Lab setup complete!"
echo "   - Namespace: tls-app"
echo "   - Certificate: /root/certs/tls.crt"
echo "   - Private Key: /root/certs/tls.key"
echo "   - Deployment YAML: ~/nginx-tls-deploy.yaml (needs volume + volumeMount)"
echo "   - Your task: create TLS secret, update deployment, apply it"
