#!/bin/bash
cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════╗
║  CKS Practice Lab — Question 21                                     ║
║  Topic: Supply Chain — Image Signing & Verification                 ║
║  Domain: Supply Chain Security                                      ║
║  Weight: 4%                                                         ║
╚══════════════════════════════════════════════════════════════════════╝

CONTEXT:
  A deployment "untrusted-app" in namespace "cks-supply" uses an image
  with the "latest" tag, which is considered insecure.
  You must verify and fix the image reference.

  Kubernetes docs:
    https://kubernetes.io/docs/concepts/containers/images/

TASK 1 — Identify the Problem:
  - Check the deployment "untrusted-app" in namespace "cks-supply"
  - Note that it uses "docker.io/library/nginx:latest" (insecure tag)

TASK 2 — Fix Image Reference:
  - Update the deployment to use a fixed version tag: "nginx:1.27"
  - Do NOT use "latest" tag
  - Apply the change

TASK 3 — Use Image Digest (Optional/Bonus):
  - For maximum security, use the image digest instead of tag
  - Get the digest: skopeo inspect docker://docker.io/library/nginx:1.27
    or: crane digest nginx:1.27
  - Update the deployment to use: nginx@sha256:<digest>

TASK 4 — Save Evidence:
  - Save the verification output to /root/supply-chain-evidence.txt
  - The file should contain the image reference used by the deployment

EOF
