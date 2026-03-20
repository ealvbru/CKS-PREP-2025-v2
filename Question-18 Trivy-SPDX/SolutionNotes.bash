#!/bin/bash
cat <<'SOLUTION'
╔══════════════════════════════════════════════════════════════════════╗
║  Solution Notes — Question 18: Trivy Vulnerability Scan & SBOM      ║
╚══════════════════════════════════════════════════════════════════════╝

TASK 1 — Vulnerability Scan:

  trivy image alpine:3.16.1 > /root/trivy-image-report.txt

  # Or with JSON output:
  trivy image --format json -o /root/trivy-image-report.json alpine:3.16.1

TASK 2 — Configuration Scan:

  trivy config /root/cks-lab-trivy/deploy.yaml > /root/trivy-config-report.txt

  # Or scan entire directory:
  trivy config /root/cks-lab-trivy >> /root/trivy-config-report.txt

TASK 3 — Generate SPDX SBOM:

  trivy image --format spdx-json -o /root/trivy-sbom.spdx.json alpine:3.20.0

  # Alternative with syft:
  # syft alpine:3.20.0 -o spdx-json > /root/trivy-sbom.spdx.json

TASK 4 — Fix Vulnerable Image:

  # Update the deployment to use alpine:3.20.0
  sed -i 's/alpine:3.16.1/alpine:3.20.0/' /root/cks-lab-trivy/deploy.yaml

  # Apply the updated deployment
  kubectl apply -f /root/cks-lab-trivy/deploy.yaml

  # Verify
  kubectl -n cks-trivy get deployment vuln-app -o jsonpath='{.spec.template.spec.containers[0].image}'

KEY REFERENCES:
  - https://trivy.dev/docs/latest/
  - https://trivy.dev/docs/latest/supply-chain/sbom/
  - trivy image --help
  - trivy config --help

SOLUTION
