#!/bin/bash
cat <<'SOLUTION'
╔══════════════════════════════════════════════════════════════════════╗
║  Solution Notes — Question 21: Supply Chain Image Verification      ║
╚══════════════════════════════════════════════════════════════════════╝

TASK 1 — Identify the Problem:

  kubectl -n cks-supply get deployment untrusted-app -o jsonpath='{.spec.template.spec.containers[0].image}'
  # Output: docker.io/library/nginx:latest

TASK 2 — Fix Image Reference:

  # Option A: kubectl set image
  kubectl -n cks-supply set image deployment/untrusted-app app=nginx:1.27

  # Option B: kubectl edit
  kubectl -n cks-supply edit deployment untrusted-app
  # Change: image: docker.io/library/nginx:latest
  # To:     image: nginx:1.27

  # Option C: kubectl patch
  kubectl -n cks-supply patch deployment untrusted-app \
    --type='json' -p='[{"op":"replace","path":"/spec/template/spec/containers/0/image","value":"nginx:1.27"}]'

TASK 3 — Use Image Digest (Bonus):

  # Get the digest
  # Using crane:
  crane digest nginx:1.27

  # Using skopeo:
  skopeo inspect docker://docker.io/library/nginx:1.27 | jq -r '.Digest'

  # Update deployment with digest
  kubectl -n cks-supply set image deployment/untrusted-app app=nginx@sha256:<digest-value>

TASK 4 — Save Evidence:

  kubectl -n cks-supply get deployment untrusted-app \
    -o jsonpath='{.spec.template.spec.containers[0].image}' > /root/supply-chain-evidence.txt
  echo "" >> /root/supply-chain-evidence.txt

  # Verify
  cat /root/supply-chain-evidence.txt

KEY REFERENCES:
  - https://kubernetes.io/docs/concepts/containers/images/
  - Use fixed tags or digests, never "latest"
  - cosign verify <image> (if cosign is available)

SOLUTION
