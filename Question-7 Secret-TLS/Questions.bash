#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 7 — Secret TLS: Create & Mount TLS Secret in Deployment
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   You have been given:
#     - A certificate file: /root/certs/tls.crt
#     - A private key file: /root/certs/tls.key
#     - A deployment YAML file: ~/nginx-tls-deploy.yaml
#   The deployment is for an nginx server in the "tls-app" namespace.
#
# Tasks:
#   1. Create a TLS Secret named "nginx-tls-secret" in the "tls-app"
#      namespace using the provided certificate and key files
#   2. Edit the deployment file ~/nginx-tls-deploy.yaml:
#      - Add a volume that references the secret "nginx-tls-secret"
#      - Mount the secret volume at /etc/nginx/ssl in the nginx container
#   3. Apply the updated deployment to the cluster
#   4. Verify the deployment is running and the secret is mounted
#
# Hints:
#   - kubectl create secret tls <name> --cert=<cert> --key=<key> -n <ns>
#   - The deployment YAML has placeholder comments showing where to add
#     the volume and volumeMount
#
# Weight: 14%
# ══════════════════════════════════════════════════════════════════════
EOF
