#!/bin/bash
cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════╗
║  CKS Practice Lab — Question 18                                     ║
║  Topic: Trivy — Vulnerability Scan & SPDX/SBOM Generation          ║
║  Domain: Supply Chain Security                                      ║
║  Weight: 5%                                                         ║
╚══════════════════════════════════════════════════════════════════════╝

CONTEXT:
  A Dockerfile and deployment exist at /root/cks-lab-trivy/.
  The image alpine:3.16.1 is known to have vulnerabilities.

  Kubernetes docs: https://trivy.dev/docs/latest/

TASK 1 — Vulnerability Scan:
  - Run a Trivy image scan on "alpine:3.16.1"
  - Save the scan output to /root/trivy-image-report.txt

TASK 2 — Configuration Scan:
  - Run a Trivy config scan on the deployment file at /root/cks-lab-trivy/deploy.yaml
  - Save the output to /root/trivy-config-report.txt

TASK 3 — Generate SPDX SBOM:
  - Generate an SPDX-JSON format SBOM for image "alpine:3.20.0" using Trivy
  - Save the output to /root/trivy-sbom.spdx.json

TASK 4 — Fix Vulnerable Image:
  - The deployment in /root/cks-lab-trivy/deploy.yaml uses alpine:3.16.1
  - Update it to use alpine:3.20.0 (less vulnerable)
  - Apply the updated deployment to the cluster

EOF
