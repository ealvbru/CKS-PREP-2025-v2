#!/bin/bash
set -e

echo "🔹 This question requires a multi-node cluster with kubeadm."
echo "   The control plane should already be at v1.33.1."
echo "   The worker node 'worker-node01' should be at v1.33.0."
echo ""
echo "   If using Killercoda/KillerShell, the environment should"
echo "   already have a multi-node cluster set up."
echo ""
echo "🔹 Verifying cluster nodes..."
kubectl get nodes -o wide 2>/dev/null || echo "⚠️  kubectl not available or no cluster"

echo ""
echo "✅ Lab setup complete!"
echo "   - Ensure control plane is at v1.33.1"
echo "   - Worker node 'worker-node01' should be at v1.33.0"
echo "   - Your task: upgrade the worker node to v1.33.1"
echo ""
echo "   NOTE: If your cluster versions differ, adjust the version"
echo "   numbers accordingly (e.g., 1.32.0 → 1.32.1)"
