#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 12 — Network Policies
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   Three namespaces exist: "frontend", "backend", and "database".
#   Each namespace has a deployment with matching labels.
#   Currently, all pods can communicate with each other without
#   restrictions.
#
# Tasks:
#   1. Create a NetworkPolicy named "backend-netpol" in the "backend"
#      namespace that:
#      - Applies to pods with label app=backend
#      - Allows INGRESS traffic ONLY from pods in the "frontend"
#        namespace (use namespaceSelector with label ns=frontend)
#      - Allows INGRESS on port 8080 only
#      - Denies all other ingress traffic
#
#   2. Create a NetworkPolicy named "database-netpol" in the "database"
#      namespace that:
#      - Applies to pods with label app=database
#      - Allows INGRESS traffic ONLY from pods in the "backend"
#        namespace (use namespaceSelector with label ns=backend)
#      - Allows INGRESS on port 3306 only
#      - Denies all other ingress traffic
#      - Denies ALL egress traffic
#
# Important:
#   - Use standard Kubernetes NetworkPolicy (NOT CiliumNetworkPolicy)
#   - Do NOT modify existing deployments or services
#
# References:
#   - https://kubernetes.io/docs/concepts/services-networking/network-policies/
#
# Weight: 7%
# ══════════════════════════════════════════════════════════════════════
EOF
