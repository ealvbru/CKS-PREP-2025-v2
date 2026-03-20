#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 16: Upgrade Worker Node
# ══════════════════════════════════════════════════════════════════════

# Step 1: Drain the worker node (from control plane)
kubectl drain worker-node01 --ignore-daemonsets --delete-emptydir-data

# Step 2: SSH to the worker node
ssh worker-node01

# Step 3: Upgrade kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm=1.33.1-*

# Step 4: Run kubeadm upgrade
sudo kubeadm upgrade node

# Step 5: Upgrade kubelet and kubectl
sudo apt-get install -y kubelet=1.33.1-* kubectl=1.33.1-*

# Step 6: Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Step 7: Exit worker node SSH
exit

# Step 8: Uncordon the worker node (from control plane)
kubectl uncordon worker-node01

# Step 9: Verify
kubectl get nodes
# worker-node01 should show Ready and v1.33.1

# ══════════════════════════════════════════════════════════════════════
EOF
