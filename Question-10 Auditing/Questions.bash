#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 10 — Kubernetes API Server Auditing
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   Auditing is currently NOT enabled on the kube-apiserver.
#   An audit policy file template is at /etc/kubernetes/audit/audit-policy.yaml
#   but it is incomplete.
#
# Tasks:
#   1. Complete the audit policy file at /etc/kubernetes/audit/audit-policy.yaml:
#      - Log Secret resources in the "kube-system" namespace at Metadata level
#      - Log all resources in core and extensions API groups at Request level
#      - Log everything else at RequestResponse level
#   2. Configure the kube-apiserver to enable auditing:
#      - Edit /etc/kubernetes/manifests/kube-apiserver.yaml
#      - Add the following flags:
#          --audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml
#          --audit-log-path=/var/log/kubernetes/audit/audit.log
#          --audit-log-maxage=30
#          --audit-log-maxbackup=10
#          --audit-log-maxsize=100
#      - Add the necessary volume and volumeMount for the audit
#        policy file and log directory
#   3. Wait for the kube-apiserver to restart and verify audit logs
#      are being written
#
# References:
#   - https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/
#   - https://kubernetes.io/docs/reference/config-api/apiserver-audit.v1/
#
# Weight: 7%
# ══════════════════════════════════════════════════════════════════════
EOF
