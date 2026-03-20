#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 10: Kubernetes Auditing
# ══════════════════════════════════════════════════════════════════════

# Step 1: Complete the audit policy
cat <<'YAML' > /etc/kubernetes/audit/audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  # Log Secret access in kube-system at Metadata level
  - level: Metadata
    resources:
    - group: ""
      resources: ["secrets"]
    namespaces: ["kube-system"]

  # Log all resources in core and extensions at Request level
  - level: Request
    resources:
    - group: ""
    - group: "extensions"

  # Catch-all: log everything else at RequestResponse level
  - level: RequestResponse
YAML

# Step 2: Edit kube-apiserver manifest to add audit flags
# Add these flags to the command section:
#   - --audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml
#   - --audit-log-path=/var/log/kubernetes/audit/audit.log
#   - --audit-log-maxage=30
#   - --audit-log-maxbackup=10
#   - --audit-log-maxsize=100

# Add volumeMounts:
#   - mountPath: /etc/kubernetes/audit
#     name: audit-policy
#     readOnly: true
#   - mountPath: /var/log/kubernetes/audit
#     name: audit-log

# Add volumes:
#   - hostPath:
#       path: /etc/kubernetes/audit
#       type: DirectoryOrCreate
#     name: audit-policy
#   - hostPath:
#       path: /var/log/kubernetes/audit
#       type: DirectoryOrCreate
#     name: audit-log

# Step 3: Wait for apiserver to restart (static pod auto-restarts)
# Watch: crictl ps | grep apiserver
# Or: kubectl get pods -n kube-system -l component=kube-apiserver

# Step 4: Verify audit logs
ls -la /var/log/kubernetes/audit/audit.log
tail -5 /var/log/kubernetes/audit/audit.log

# ══════════════════════════════════════════════════════════════════════
EOF
