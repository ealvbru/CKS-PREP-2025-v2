#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 13 — Pod Security Standards (PSS)
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   The namespace "restricted-ns" has the Pod Security Admission label
#   set to enforce the "restricted" profile. A deployment YAML file
#   at ~/pss-deploy.yaml has been applied but the pods are NOT running.
#
# Tasks:
#   1. Check the ReplicaSet events to understand why the pods are
#      failing to be created
#      (kubectl get events -n restricted-ns or kubectl describe rs -n restricted-ns)
#   2. Fix the deployment YAML file ~/pss-deploy.yaml to comply with
#      the "restricted" Pod Security Standard:
#      - Remove privileged: true from securityContext
#      - Remove hostNetwork: true
#      - Remove hostPID: true
#      - Add runAsNonRoot: true to pod securityContext
#      - Add allowPrivilegeEscalation: false to container securityContext
#      - Add seccompProfile type RuntimeDefault to pod securityContext
#      - Add capabilities drop ALL to container securityContext
#      - Ensure runAsUser is NOT 0 (root)
#   3. Reapply the fixed deployment
#   4. Verify the pods are running successfully
#
# References:
#   - https://kubernetes.io/docs/concepts/security/pod-security-standards/
#   - https://kubernetes.io/docs/concepts/security/pod-security-admission/
#
# Weight: 7%
# ══════════════════════════════════════════════════════════════════════
EOF
