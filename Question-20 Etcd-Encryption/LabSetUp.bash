#!/bin/bash
set -euo pipefail
echo "[Q20] Setting up etcd Encryption lab..."

# Create the enc directory
mkdir -p /etc/kubernetes/enc

# Ensure no previous encryption config exists
rm -f /etc/kubernetes/enc/enc.yaml 2>/dev/null || true

# Clean up previous test namespace/secret
kubectl delete namespace cks-etcd --ignore-not-found=true 2>/dev/null || true

echo "[Q20] Lab setup complete."
echo "  Directory: /etc/kubernetes/enc/ (empty, you must create enc.yaml)"
echo "  kube-apiserver manifest: /etc/kubernetes/manifests/kube-apiserver.yaml"
echo "  NOTE: You need access to the control plane node"
echo "  NOTE: etcdctl must be available for verification"
