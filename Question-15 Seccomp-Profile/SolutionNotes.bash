#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 15: Seccomp Profile
# ══════════════════════════════════════════════════════════════════════

# Step 1: Edit the deployment to apply Localhost seccomp profile
kubectl -n seccomp-ns patch deployment seccomp-app --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/securityContext", "value": {
    "seccompProfile": {
      "type": "Localhost",
      "localhostProfile": "profiles/audit.json"
    }
  }}
]'

# OR edit the deployment YAML directly:
# kubectl edit deployment seccomp-app -n seccomp-ns
# Add under spec.template.spec:
#   securityContext:
#     seccompProfile:
#       type: Localhost
#       localhostProfile: profiles/audit.json

# Step 2: Verify the deployment restarted
kubectl rollout status deployment seccomp-app -n seccomp-ns
kubectl get pods -n seccomp-ns

# Step 3: Create the default-seccomp pod
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: default-seccomp
  namespace: seccomp-ns
spec:
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: busybox:1.36
    command: ["sleep", "3600"]
YAML

# Verify both:
kubectl get pods -n seccomp-ns
kubectl get pod default-seccomp -n seccomp-ns -o jsonpath='{.spec.securityContext.seccompProfile}'

# ══════════════════════════════════════════════════════════════════════
EOF
