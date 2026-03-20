#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 3: Ingress with TLS
# ══════════════════════════════════════════════════════════════════════

# Create the Ingress resource with TLS and ssl-redirect annotation
cat <<'YAML' > /tmp/web-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: secure-web
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - secure.example.com
    secretName: app-tls
  rules:
  - host: secure.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
YAML
kubectl apply -f /tmp/web-ingress.yaml

# Verify
kubectl get ingress -n secure-web
kubectl describe ingress web-ingress -n secure-web

# ══════════════════════════════════════════════════════════════════════
EOF
