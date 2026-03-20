#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 8 — Projected Volume & ServiceAccount Token
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   A ServiceAccount named "backend-sa" exists in the "secure-app"
#   namespace. A deployment YAML file is located at ~/backend-deploy.yaml
#   The deployment currently auto-mounts the SA token.
#
# Tasks:
#   1. Edit the ServiceAccount "backend-sa" in the "secure-app" namespace
#      and set automountServiceAccountToken to false
#   2. Edit the deployment file ~/backend-deploy.yaml to use a projected
#      volume that mounts the ServiceAccount token at:
#        /var/run/secrets/kubernetes.io/serviceaccount/token
#      The projected volume must use:
#        - serviceAccountToken source with:
#            path: token
#            expirationSeconds: 3600
#   3. Apply the updated deployment
#   4. Verify the pod is running with the projected volume mounted
#
# References:
#   - https://kubernetes.io/docs/concepts/storage/projected-volumes/
#   - https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
#
# Weight: 7%
# ══════════════════════════════════════════════════════════════════════
EOF
