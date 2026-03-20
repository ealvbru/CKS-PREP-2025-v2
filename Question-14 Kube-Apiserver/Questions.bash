#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 14 — Kube-Apiserver: Anonymous Auth & ClusterRoleBinding
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   The kube-apiserver currently has anonymous authentication enabled,
#   and a ClusterRoleBinding named "system:anonymous" grants the
#   system:anonymous user access to the cluster.
#
# Tasks:
#   1. Edit the kube-apiserver manifest at
#      /etc/kubernetes/manifests/kube-apiserver.yaml
#      Change the flag --anonymous-auth=true to --anonymous-auth=false
#   2. Delete the ClusterRoleBinding named "system:anonymous"
#   3. Wait for the kube-apiserver to restart and verify it is healthy
#   4. Verify that anonymous requests are now rejected
#
# Important:
#   - Be careful editing the static pod manifest — incorrect changes
#     can prevent the apiserver from starting
#   - Wait for the apiserver to fully restart before verifying
#
# References:
#   - https://kubernetes.io/docs/reference/access-authn-authz/authentication/#anonymous-requests
#
# Weight: 4%
# ══════════════════════════════════════════════════════════════════════
EOF
