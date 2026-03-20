#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 14: Kube-Apiserver Anonymous Auth
# ══════════════════════════════════════════════════════════════════════

# Step 1: Edit kube-apiserver manifest
# Change --anonymous-auth=true to --anonymous-auth=false
sed -i 's/--anonymous-auth=true/--anonymous-auth=false/' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

# Verify:
grep anonymous-auth /etc/kubernetes/manifests/kube-apiserver.yaml

# Step 2: Delete the ClusterRoleBinding
kubectl delete clusterrolebinding system:anonymous

# Verify:
kubectl get clusterrolebinding system:anonymous 2>&1
# Should show "not found"

# Step 3: Wait for apiserver to restart
# The static pod will auto-restart. Wait ~30 seconds.
sleep 30
kubectl get nodes  # should work with your kubeconfig

# Step 4: Verify anonymous requests are rejected
curl -k https://localhost:6443/api/v1/namespaces 2>&1 | head -5
# Should show 401 Unauthorized

# ══════════════════════════════════════════════════════════════════════
EOF
