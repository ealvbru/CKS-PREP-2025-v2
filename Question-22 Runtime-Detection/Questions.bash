#!/bin/bash
cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════╗
║  CKS Practice Lab — Question 22                                     ║
║  Topic: Runtime Detection — Investigate & Mitigate                  ║
║  Domain: Runtime Security                                           ║
║  Weight: 4%                                                         ║
╚══════════════════════════════════════════════════════════════════════╝

CONTEXT:
  Suspicious activity has been detected in the "cks-runtime-detect" namespace.
  A pod "suspicious-writer" is performing unauthorized file operations.
  Falco is running in the cluster and generating alerts.

  Kubernetes docs: https://falco.org/docs/

TASK 1 — Investigate Falco Alerts:
  - Check Falco logs for alerts from the "cks-runtime-detect" namespace
  - Identify the pod and container generating suspicious alerts
  - Save the relevant Falco log entries to /root/runtime-detect-evidence.txt

TASK 2 — Correlate with Kubernetes Events:
  - Check Kubernetes events in the "cks-runtime-detect" namespace
  - Append relevant event information to /root/runtime-detect-evidence.txt

TASK 3 — Mitigate:
  - Delete the offending pod "suspicious-writer"
  - Delete the pod "net-tool" if it exists
  - Ensure no suspicious pods remain in the namespace

TASK 4 — Verify Clean State:
  - Confirm no pods are running in "cks-runtime-detect" namespace
  - The evidence file /root/runtime-detect-evidence.txt must exist and contain data

EOF
