#!/bin/bash
set -e

echo "🔹 Creating namespace: seccomp-ns"
kubectl create namespace seccomp-ns --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Creating custom seccomp profile on node..."
mkdir -p /var/lib/kubelet/seccomp/profiles
cat <<'SECCOMP' > /var/lib/kubelet/seccomp/profiles/audit.json
{
  "defaultAction": "SCMP_ACT_LOG"
}
SECCOMP

echo "🔹 Deploying seccomp-app WITHOUT seccomp profile..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: seccomp-app
  namespace: seccomp-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: seccomp-app
  template:
    metadata:
      labels:
        app: seccomp-app
    spec:
      containers:
      - name: app
        image: busybox:1.36
        command: ["sleep", "3600"]
EOF

echo ""
echo "✅ Lab setup complete!"
echo "   - Namespace: seccomp-ns"
echo "   - Seccomp profile: /var/lib/kubelet/seccomp/profiles/audit.json"
echo "   - Deployment: seccomp-app (no seccomp profile applied)"
echo "   - Your task: apply Localhost seccomp to deployment, create RuntimeDefault pod"
