#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 7: Secret TLS
# ══════════════════════════════════════════════════════════════════════

# Step 1: Create the TLS Secret
kubectl create secret tls nginx-tls-secret \
  --cert=/root/certs/tls.crt \
  --key=/root/certs/tls.key \
  -n tls-app

# Verify:
kubectl get secret nginx-tls-secret -n tls-app

# Step 2: Edit the deployment YAML to add volume and volumeMount
cat <<'YAML' > ~/nginx-tls-deploy.yaml
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
        volumeMounts:
        - name: tls-certs
          mountPath: /etc/nginx/ssl
          readOnly: true
      volumes:
      - name: tls-certs
        secret:
          secretName: nginx-tls-secret
YAML

# Step 3: Apply the deployment
kubectl apply -f ~/nginx-tls-deploy.yaml

# Step 4: Verify
kubectl get pods -n tls-app
kubectl describe deployment nginx-tls -n tls-app | grep -A5 "Mounts\|Volumes"

# ══════════════════════════════════════════════════════════════════════
EOF
