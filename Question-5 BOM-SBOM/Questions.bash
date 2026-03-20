#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 5 — BOM: Software Bill of Materials
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   A deployment named "alpine-multi" exists in the "sbom" namespace.
#   It has 3 containers using the Alpine image with different versions:
#     - container "alpine-v1" → alpine:3.20.0
#     - container "alpine-v2" → alpine:3.19.6
#     - container "alpine-v3" → alpine:3.16.1
#
#   The deployment YAML file is located at ~/alpine-deploy.yaml
#
# Tasks:
#   1. Identify which container image has the package "libcrypto3"
#      at a VULNERABLE version. Use trivy or bom to scan the images.
#      The container using alpine:3.16.1 has an outdated libcrypto3.
#      Edit the deployment file ~/alpine-deploy.yaml to REMOVE that
#      container from the pod spec, then reapply the deployment.
#   2. Generate an SPDX SBOM report for the image alpine:3.20.0 and
#      save it to /root/sbom-report.spdx
#      Use: trivy image --format spdx alpine:3.20.0 > /root/sbom-report.spdx
#      OR:  bom generate -i alpine:3.20.0 -o /root/sbom-report.spdx
#
# Hints:
#   - trivy image alpine:3.16.1 | grep libcrypto
#   - trivy image --format spdx <image> > output.spdx
#
# References:
#   - https://trivy.dev/docs/latest/supply-chain/sbom/
#   - https://sigs.k8s.io/bom
#
# Weight: 14%
# ══════════════════════════════════════════════════════════════════════
EOF
