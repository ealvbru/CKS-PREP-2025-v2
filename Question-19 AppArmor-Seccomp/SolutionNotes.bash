#!/bin/bash
cat <<'SOLUTION'
╔══════════════════════════════════════════════════════════════════════╗
║  Solution Notes — Question 19: AppArmor + Seccomp Hardening         ║
╚══════════════════════════════════════════════════════════════════════╝

APPROACH:
  Edit the deployment to add both seccomp and AppArmor profiles.

  kubectl -n cks-hardening edit deployment hardened-app

  Or apply the full corrected YAML:

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hardened-app
  namespace: cks-hardening
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hardened-app
  template:
    metadata:
      labels:
        app: hardened-app
      annotations:
        container.apparmor.security.beta.kubernetes.io/app: runtime/default
    spec:
      securityContext:
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: app
        image: nginx:1.27
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
---

APPLY:
  kubectl apply -f hardened-app-fixed.yaml

VERIFY:
  kubectl -n cks-hardening get pods
  kubectl -n cks-hardening get deployment hardened-app -o yaml | grep -A2 seccompProfile
  kubectl -n cks-hardening get pod -o yaml | grep -i apparmor -A2

KEY NOTES:
  - seccompProfile goes under spec.securityContext (pod level) or
    spec.containers[].securityContext (container level)
  - AppArmor annotation goes on Pod template metadata.annotations
    (NOT on the Deployment metadata)
  - The annotation key format is:
    container.apparmor.security.beta.kubernetes.io/<container-name>: <profile>
  - "runtime/default" is the standard AppArmor profile

KEY REFERENCES:
  - https://kubernetes.io/docs/tutorials/security/seccomp/
  - https://kubernetes.io/docs/tutorials/security/apparmor/

SOLUTION
