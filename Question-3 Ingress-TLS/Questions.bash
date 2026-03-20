#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 3 — Ingress with TLS & HTTP-to-HTTPS Redirect
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   A TLS Secret named "app-tls" already exists in the "secure-web"
#   namespace. A deployment "web-app" and a ClusterIP service
#   "web-service" (port 80) are already running.
#
# Tasks:
#   1. Create an Ingress resource named "web-ingress" in the
#      "secure-web" namespace with the following configuration:
#      - ingressClassName: nginx
#      - Host: secure.example.com
#      - TLS enabled using the existing secret "app-tls"
#      - Route path "/" (Prefix) to the service "web-service" on port 80
#   2. Add the appropriate annotation to redirect all HTTP requests
#      to HTTPS (ssl-redirect)
#   3. Verify the Ingress is created with TLS configured
#
# References:
#   - https://kubernetes.github.io/ingress-nginx/user-guide/tls/
#   - https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
#     (search for ssl-redirect and force-ssl-redirect)
#
# Weight: 15%
# ══════════════════════════════════════════════════════════════════════
EOF
