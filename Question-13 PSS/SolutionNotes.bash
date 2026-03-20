#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 13: Pod Security Standards (PSS)
# ══════════════════════════════════════════════════════════════════════

# Step 1: Check events to understand the issue
kubectl get events -n restricted-ns --sort-by='.lastTimestamp'
kubectl describe rs -n restricted-ns

# Step 2: Fix the deployment YAML
cat <<'YAML' > ~/pss-deploy.yaml
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
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: app
        image: busybox:1.36
        command: ["sleep", "3600"]
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
YAML

# Step 3: Delete old deployment and reapply
kubectl delete deployment secure-app -n restricted-ns --ignore-not-found
kubectl apply -f ~/pss-deploy.yaml

# Step 4: Verify
kubectl get pods -n restricted-ns
# Should show 1/1 Running

# ══════════════════════════════════════════════════════════════════════
EOF
