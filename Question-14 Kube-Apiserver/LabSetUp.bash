#!/bin/bash
set -e

echo "🔹 Ensuring kube-apiserver manifest has anonymous-auth=true..."
MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [ -f "$MANIFEST" ]; then
  # If anonymous-auth flag exists, set to true; otherwise add it
  if grep -q 'anonymous-auth' "$MANIFEST"; then
    sed -i 's/--anonymous-auth=false/--anonymous-auth=true/' "$MANIFEST"
  else
    sed -i '/- kube-apiserver/a\    - --anonymous-auth=true' "$MANIFEST"
  fi
else
  echo "⚠️  kube-apiserver manifest not found at $MANIFEST"
  echo "   Run Q10 LabSetUp first to create the simulated manifest, or use a real cluster"
fi

echo "🔹 Creating ClusterRoleBinding system:anonymous..."
cat <<EOF | kubectl apply -f - 2>/dev/null || true
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:anonymous
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:anonymous
EOF

echo ""
echo "✅ Lab setup complete!"
echo "   - kube-apiserver: --anonymous-auth=true (insecure)"
echo "   - ClusterRoleBinding: system:anonymous → cluster-admin (insecure)"
echo "   - Your task: disable anonymous auth, delete the ClusterRoleBinding"
