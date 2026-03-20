#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 16 — Upgrade Worker Node from v1.33.0 to v1.33.1
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   The control plane has already been upgraded to v1.33.1.
#   A worker node named "worker-node01" is still running v1.33.0.
#   You need to upgrade the worker node to v1.33.1.
#
# Tasks:
#   1. SSH to the worker node (or if on the worker node already):
#   2. Drain the worker node:
#        kubectl drain worker-node01 --ignore-daemonsets --delete-emptydir-data
#   3. Upgrade kubeadm on the worker node:
#        apt-get update
#        apt-get install -y kubeadm=1.33.1-*
#   4. Run kubeadm upgrade on the worker:
#        kubeadm upgrade node
#   5. Upgrade kubelet and kubectl:
#        apt-get install -y kubelet=1.33.1-* kubectl=1.33.1-*
#   6. Restart kubelet:
#        systemctl daemon-reload
#        systemctl restart kubelet
#   7. Uncordon the worker node:
#        kubectl uncordon worker-node01
#   8. Verify the node is Ready and shows v1.33.1
#
# References:
#   - https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
#
# Weight: 4%
# ══════════════════════════════════════════════════════════════════════
EOF
