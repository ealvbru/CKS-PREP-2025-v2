#!/bin/bash
set -e

echo "🔹 Creating namespaces with labels..."
for ns in frontend backend database; do
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -
  kubectl label namespace $ns ns=$ns --overwrite
done

echo "🔹 Deploying frontend..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

echo "🔹 Deploying backend..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: backend
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
      containers:
      - name: backend
        image: nginx:1.25
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: backend
spec:
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080
EOF

echo "🔹 Deploying database..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  namespace: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: mysql
        image: busybox:1.36
        command: ["sleep", "3600"]
        ports:
        - containerPort: 3306
---
apiVersion: v1
kind: Service
metadata:
  name: database-svc
  namespace: database
spec:
  selector:
    app: database
  ports:
  - port: 3306
    targetPort: 3306
EOF

echo ""
echo "✅ Lab setup complete!"
echo "   - Namespaces: frontend (ns=frontend), backend (ns=backend), database (ns=database)"
echo "   - All pods can currently communicate freely"
echo "   - Your task: create 2 NetworkPolicies to restrict traffic"
