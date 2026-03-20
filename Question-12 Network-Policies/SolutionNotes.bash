#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 12: Network Policies
# ══════════════════════════════════════════════════════════════════════

# Policy 1: backend-netpol
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-netpol
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          ns: frontend
    ports:
    - protocol: TCP
      port: 8080
YAML

# Policy 2: database-netpol
cat <<'YAML' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-netpol
  namespace: database
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          ns: backend
    ports:
    - protocol: TCP
      port: 3306
  egress: []
YAML

# Verify
kubectl get networkpolicy -n backend
kubectl get networkpolicy -n database
kubectl describe networkpolicy backend-netpol -n backend
kubectl describe networkpolicy database-netpol -n database

# ══════════════════════════════════════════════════════════════════════
EOF
