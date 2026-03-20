#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 15 — Seccomp Profile: Apply to Pod
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   A custom seccomp profile has been placed on the node at:
#     /var/lib/kubelet/seccomp/profiles/audit.json
#   A deployment named "seccomp-app" exists in the "seccomp-ns"
#   namespace but does NOT have any seccomp profile applied.
#
# Tasks:
#   1. Edit the deployment "seccomp-app" in the "seccomp-ns" namespace
#      to apply the custom seccomp profile using:
#        securityContext:
#          seccompProfile:
#            type: Localhost
#            localhostProfile: profiles/audit.json
#      Apply this at the POD level (spec.securityContext)
#   2. Verify the pod restarts with the seccomp profile applied
#   3. Also create a second pod named "default-seccomp" in "seccomp-ns"
#      that uses the RuntimeDefault seccomp profile:
#        securityContext:
#          seccompProfile:
#            type: RuntimeDefault
#      Use image busybox:1.36 with command ["sleep", "3600"]
#
# References:
#   - https://kubernetes.io/docs/tutorials/security/seccomp/
#   - https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
#
# Weight: 4%
# ══════════════════════════════════════════════════════════════════════
EOF
