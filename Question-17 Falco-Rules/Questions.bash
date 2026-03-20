#!/bin/bash
cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════╗
║  CKS Practice Lab — Question 17                                     ║
║  Topic: Falco — Real Rule Checks & Custom Rules                     ║
║  Domain: Runtime Security                                           ║
║  Weight: 5%                                                         ║
╚══════════════════════════════════════════════════════════════════════╝

CONTEXT:
  Falco is installed in the cluster as a DaemonSet in the "falco" namespace.
  Several suspicious workloads are running in the "cks-falco" namespace.

  Kubernetes docs: https://falco.org/docs/reference/rules/examples/

TASK 1 — Identify Suspicious Pods via Falco Logs:
  - Check Falco logs for alerts related to /dev/mem access
  - Identify which pods in namespace "cks-falco" are triggering alerts
  - Save the relevant Falco alerts to /root/falco-rules-output.txt

TASK 2 — Delete Offending Pods:
  - Delete the pod "devmem-pod" in namespace "cks-falco" that accesses /dev/mem
  - Delete the pod "interactive-shell" in namespace "cks-falco"

TASK 3 — Create Custom Falco Rule:
  - Create a custom Falco rule in /etc/falco/falco_rules.local.yaml
  - The rule must detect any process reading /etc/shadow
  - Rule name must be: "Read shadow file"
  - Priority: WARNING
  - Restart Falco after applying the rule

TASK 4 — Test and Verify:
  - Run a test pod "shadow-reader" in namespace "cks-falco" that reads /etc/shadow
  - Verify the alert appears in Falco logs
  - Save evidence to /root/falco-shadow-evidence.txt

EOF
