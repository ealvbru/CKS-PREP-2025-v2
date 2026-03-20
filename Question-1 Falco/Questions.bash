#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 1 — Falco: Detect Pods Accessing /dev/mem
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   Falco is already installed and running in the cluster (namespace: falco).
#   Three deployments — nvidia, cpu, and ollama — are running in the
#   "gpu-workloads" namespace. These pods are accessing /dev/mem, which
#   is a sensitive device file that should not be read by normal workloads.
#
# Tasks:
#   1. Check the Falco logs and identify which pods are accessing /dev/mem
#   2. Save the relevant Falco alert lines to /root/falco-alerts.txt
#   3. Scale down ALL three offending deployments (nvidia, cpu, ollama)
#      in the "gpu-workloads" namespace to 0 replicas
#   4. Verify that no pods remain running in the gpu-workloads namespace
#
# Hints:
#   - Falco logs can be viewed with: kubectl logs -n falco -l app.kubernetes.io/name=falco
#   - The Falco rule that triggers is related to reading sensitive files
#
# References:
#   - https://falco.org/docs/reference/rules/examples/
#   - https://falco.org/docs/concepts/outputs/
#
# Weight: 13%
# ══════════════════════════════════════════════════════════════════════
EOF
