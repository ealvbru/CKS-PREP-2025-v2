#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 5: BOM / SBOM
# ══════════════════════════════════════════════════════════════════════

# Step 1: Scan each image to find the vulnerable libcrypto3
trivy image alpine:3.20.0 2>/dev/null | grep -i libcrypto
trivy image alpine:3.19.6 2>/dev/null | grep -i libcrypto
trivy image alpine:3.16.1 2>/dev/null | grep -i libcrypto
# alpine:3.16.1 will show the vulnerable/outdated version

# Step 2: Edit ~/alpine-deploy.yaml and REMOVE the alpine-v3 container
# The file should only have alpine-v1 and alpine-v2 containers:
cat <<'YAML' > ~/alpine-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alpine-multi
  namespace: sbom
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alpine-multi
  template:
    metadata:
      labels:
        app: alpine-multi
    spec:
      containers:
      - name: alpine-v1
        image: alpine:3.20.0
        command: ["sleep", "3600"]
      - name: alpine-v2
        image: alpine:3.19.6
        command: ["sleep", "3600"]
YAML

# Reapply the deployment
kubectl apply -f ~/alpine-deploy.yaml

# Step 3: Generate SPDX SBOM report
trivy image --format spdx alpine:3.20.0 > /root/sbom-report.spdx
# OR using bom:
# bom generate -i alpine:3.20.0 -o /root/sbom-report.spdx

# Verify
cat /root/sbom-report.spdx | head -20

# ══════════════════════════════════════════════════════════════════════
EOF
