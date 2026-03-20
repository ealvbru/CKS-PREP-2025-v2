#!/bin/bash
cat <<'SOLUTION'
╔══════════════════════════════════════════════════════════════════════╗
║  Solution Notes — Question 17: Falco Real Rule Checks               ║
╚══════════════════════════════════════════════════════════════════════╝

TASK 1 — Identify Suspicious Pods via Falco Logs:

  # Check Falco logs for /dev/mem alerts
  kubectl -n falco logs ds/falco --since=10m | grep -Ei 'dev.mem|/dev/mem|mem' > /root/falco-rules-output.txt

  # Or check specific Falco pod
  kubectl -n falco get pods
  kubectl -n falco logs <falco-pod-name> | grep -Ei 'dev.mem|/dev/mem' >> /root/falco-rules-output.txt

TASK 2 — Delete Offending Pods:

  kubectl -n cks-falco delete pod devmem-pod
  kubectl -n cks-falco delete pod interactive-shell

TASK 3 — Create Custom Falco Rule:

  # Edit or create the local rules file
  cat > /etc/falco/falco_rules.local.yaml <<'EOF'
  - rule: Read shadow file
    desc: Detect reading of /etc/shadow
    condition: open_read and fd.name=/etc/shadow
    output: "Shadow file opened (user=%user.name command=%proc.cmdline file=%fd.name container=%container.id image=%container.image.repository)"
    priority: WARNING
    tags: [filesystem, container, process]
  EOF

  # Restart Falco
  # If systemd:
  systemctl restart falco
  # If DaemonSet:
  kubectl -n falco rollout restart ds/falco

TASK 4 — Test and Verify:

  # Run test pod
  kubectl -n cks-falco run shadow-reader --image=alpine:3.20 --restart=Never -- sh -c "cat /etc/shadow || true; sleep 3600"

  # Wait a moment, then check Falco logs
  sleep 30
  kubectl -n falco logs ds/falco --since=5m | grep -i shadow > /root/falco-shadow-evidence.txt

KEY REFERENCES:
  - https://falco.org/docs/reference/rules/examples/
  - https://falco.org/docs/rules/
  - /etc/falco/falco_rules.local.yaml (custom rules file)

SOLUTION
