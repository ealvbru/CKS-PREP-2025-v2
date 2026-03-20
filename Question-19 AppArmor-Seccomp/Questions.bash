#!/bin/bash
cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════╗
║  CKS Practice Lab — Question 19                                     ║
║  Topic: AppArmor + Seccomp — Combined Hardening                     ║
║  Domain: System Hardening                                           ║
║  Weight: 5%                                                         ║
╚══════════════════════════════════════════════════════════════════════╝

CONTEXT:
  A deployment "hardened-app" exists in namespace "cks-hardening".
  It currently has partial security settings but needs to be fully hardened
  with both Seccomp and AppArmor profiles.

  Kubernetes docs:
    - https://kubernetes.io/docs/tutorials/security/seccomp/
    - https://kubernetes.io/docs/tutorials/security/apparmor/

TASK 1 — Apply Seccomp RuntimeDefault:
  - Add a seccompProfile of type "RuntimeDefault" at the pod level
    in the deployment "hardened-app" in namespace "cks-hardening"

TASK 2 — Apply AppArmor runtime/default:
  - Add the AppArmor annotation for the container "app" to use "runtime/default"
  - The annotation must be:
    container.apparmor.security.beta.kubernetes.io/app: runtime/default
  - The annotation goes on the Pod template metadata (not the Deployment metadata)

TASK 3 — Verify:
  - Ensure the deployment pods are running after applying both profiles
  - Ensure the pod has both seccomp and AppArmor applied

EOF
