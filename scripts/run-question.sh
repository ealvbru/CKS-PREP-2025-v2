#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/run-question.sh \"Question-XX Topic\"" >&2
  echo "" >&2
  echo "Available questions:" >&2
  echo "  \"Question-1 Falco\"" >&2
  echo "  \"Question-2 Istio-mTLS\"" >&2
  echo "  \"Question-3 Ingress-TLS\"" >&2
  echo "  \"Question-4 Docker-Daemon-Secure\"" >&2
  echo "  \"Question-5 BOM-SBOM\"" >&2
  echo "  \"Question-6 Static-Analysis\"" >&2
  echo "  \"Question-7 Secret-TLS\"" >&2
  echo "  \"Question-8 Projected-Volume-SA\"" >&2
  echo "  \"Question-9 Kube-Bench\"" >&2
  echo "  \"Question-10 Auditing\"" >&2
  echo "  \"Question-11 ImagePolicyWebhook\"" >&2
  echo "  \"Question-12 Network-Policies\"" >&2
  echo "  \"Question-13 PSS\"" >&2
  echo "  \"Question-14 Kube-Apiserver\"" >&2
  echo "  \"Question-15 Seccomp-Profile\"" >&2
  echo "  \"Question-16 Upgrade-Worker-Node\"" >&2
  echo "  \"Question-17 Falco-Rules\"" >&2
  echo "  \"Question-18 Trivy-SPDX\"" >&2
  echo "  \"Question-19 AppArmor-Seccomp\"" >&2
  echo "  \"Question-20 Etcd-Encryption\"" >&2
  echo "  \"Question-21 Supply-Chain\"" >&2
  echo "  \"Question-22 Runtime-Detection\"" >&2
  exit 1
fi

QUESTION_DIR="$*"
if [[ ! -d "$QUESTION_DIR" ]]; then
  echo "Question directory '$QUESTION_DIR' not found" >&2
  exit 1
fi

SETUP="$QUESTION_DIR/LabSetUp.bash"
QUESTION_TEXT="$QUESTION_DIR/Questions.bash"
SOLUTION="$QUESTION_DIR/SolutionNotes.bash"

[[ -f "$SETUP" ]] || { echo "Missing $SETUP" >&2; exit 1; }
[[ -f "$QUESTION_TEXT" ]] || { echo "Missing $QUESTION_TEXT" >&2; exit 1; }

chmod +x "$SETUP"

echo "==> Running lab setup for $QUESTION_DIR"
"$SETUP"

echo
echo "==> Question"
bash "$QUESTION_TEXT"

echo
if [[ -f "$SOLUTION" ]]; then
  echo "Hints: see $SOLUTION"
fi
