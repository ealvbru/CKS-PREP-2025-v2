#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 8: Projected Volume & ServiceAccount
# ══════════════════════════════════════════════════════════════════════

# Step 1: Set automountServiceAccountToken to false on the SA
kubectl patch serviceaccount backend-sa -n secure-app \
  -p '{"automountServiceAccountToken": false}'
# Verify:
kubectl get sa backend-sa -n secure-app -o yaml | grep automount

# Step 2: Edit the deployment YAML to add projected volume
cat <<'YAML' > ~/backend-deploy.yaml
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
        volumeMounts:
        - name: sa-token
          mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          readOnly: true
      volumes:
      - name: sa-token
        projected:
          sources:
          - serviceAccountToken:
              path: token
              expirationSeconds: 3600
YAML

# Step 3: Apply the updated deployment
kubectl apply -f ~/backend-deploy.yaml

# Step 4: Verify
kubectl get pods -n secure-app
kubectl exec -n secure-app deploy/backend -- ls /var/run/secrets/kubernetes.io/serviceaccount/

# ══════════════════════════════════════════════════════════════════════
EOF
