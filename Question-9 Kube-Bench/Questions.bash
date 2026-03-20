#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 9 — Kube-Bench: Fix CIS Benchmark Issues
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   kube-bench has been run against the cluster and identified 3
#   security issues that need to be fixed. The kube-bench report
#   has been saved to /root/kube-bench-report.txt
#
# Tasks:
#   1. Review the kube-bench report at /root/kube-bench-report.txt
#   2. Fix the following 3 issues:
#
#      Issue 1: kubelet — anonymous-auth is enabled
#        → Edit /var/lib/kubelet/config.yaml
#        → Set authentication.anonymous.enabled to false
#        → Restart kubelet
#
#      Issue 2: kubelet — authorization mode is AlwaysAllow
#        → Edit /var/lib/kubelet/config.yaml
#        → Set authorization.mode to Webhook
#        → Restart kubelet
#
#      Issue 3: etcd data directory permissions are too open
#        → Change permissions of /var/lib/etcd to 700
#        → Change ownership to etcd:etcd
#
#   3. After fixing all issues, restart the affected services
#
# References:
#   - https://github.com/aquasecurity/kube-bench
#   - https://www.cisecurity.org/benchmark/kubernetes
#
# Weight: 7%
# ══════════════════════════════════════════════════════════════════════
EOF
