#!/bin/bash
set -e

echo "🔹 Creating namespace: secure-web"
kubectl create namespace secure-web --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Generating self-signed TLS certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/app-tls.key -out /tmp/app-tls.crt \
  -subj "/CN=secure.example.com/O=secure-web" 2>/dev/null

echo "🔹 Creating TLS Secret 'app-tls'..."
kubectl create secret tls app-tls \
  --cert=/tmp/app-tls.crt \
  --key=/tmp/app-tls.key \
  -n secure-web --dry-run=client -o yaml | kubectl apply -f -
rm -f /tmp/app-tls.key /tmp/app-tls.crt

echo "🔹 Deploying web application..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: secure-web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

echo "🔹 Creating ClusterIP Service..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: secure-web
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF

echo ""
echo "✅ Lab setup complete!"
echo "   - Namespace: secure-web"
echo "   - Secret: app-tls (TLS certificate for secure.example.com)"
echo "   - Deployment: web-app"
echo "   - Service: web-service (ClusterIP, port 80)"
echo "   - Your task: create an Ingress with TLS and HTTP→HTTPS redirect"
