#!/bin/bash
cat <<'SOLUTION'
╔══════════════════════════════════════════════════════════════════════╗
║  Solution Notes — Question 22: Runtime Detection & Mitigation       ║
╚══════════════════════════════════════════════════════════════════════╝

TASK 1 — Investigate Falco Alerts:

  # Check Falco logs
  kubectl -n falco logs ds/falco --since=10m > /tmp/falco-full.log

  # Filter for our namespace
  grep -i 'cks-runtime-detect' /tmp/falco-full.log > /root/runtime-detect-evidence.txt

  # Or filter for specific suspicious activities
  kubectl -n falco logs ds/falco --since=10m | grep -Ei 'write|passwd|shell|container|curl|wget|network' >> /root/runtime-detect-evidence.txt

TASK 2 — Correlate with Kubernetes Events:

  kubectl -n cks-runtime-detect get events --sort-by=.lastTimestamp >> /root/runtime-detect-evidence.txt

TASK 3 — Mitigate:

  # Delete offending pods
  kubectl -n cks-runtime-detect delete pod suspicious-writer
  kubectl -n cks-runtime-detect delete pod net-tool

  # Or delete all pods in the namespace
  kubectl -n cks-runtime-detect delete pods --all

TASK 4 — Verify:

  # Confirm no pods running
  kubectl -n cks-runtime-detect get pods
  # Should show: No resources found

  # Confirm evidence file exists
  cat /root/runtime-detect-evidence.txt

KEY REFERENCES:
  - https://falco.org/docs/
  - kubectl -n falco logs ds/falco --since=<time>
  - kubectl get events --sort-by=.lastTimestamp

SOLUTION
