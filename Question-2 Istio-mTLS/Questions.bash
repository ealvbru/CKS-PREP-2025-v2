#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 2 — Istio: Apply mTLS Sidecar & Lock Down Namespace
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   Istio is already installed in the cluster. A namespace called
#   "mesh-app" exists with a deployment "httpbin" running without
#   Istio sidecar injection.
#
# Tasks:
#   1. Enable Istio sidecar injection for the "mesh-app" namespace
#      by adding the appropriate label
#   2. Restart the "httpbin" deployment so the sidecar proxy is injected
#   3. Verify the pods now have 2 containers (app + istio-proxy)
#   4. Create a PeerAuthentication resource named "strict-mtls" in the
#      "mesh-app" namespace to enforce STRICT mutual TLS for all
#      workloads in that namespace
#
# References:
#   - https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#deploying-an-app
#   - https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/#lock-down-to-mutual-tls-by-namespace
#
# Weight: 15%
# ══════════════════════════════════════════════════════════════════════
EOF
