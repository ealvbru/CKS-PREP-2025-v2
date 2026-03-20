#!/bin/bash
set -euo pipefail
echo "[Q17] Setting up Falco Rules lab..."

# Create namespace
kubectl create namespace cks-falco --dry-run=client -o yaml | kubectl apply -f -

# Create devmem-pod (suspicious - accesses /dev/mem)
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: devmem-pod
  namespace: cks-falco
spec:
  containers:
  - name: devmem
    image: alpine:3.20
    command: ["sh","-c","sleep 3600"]
    securityContext:
      privileged: true
    volumeMounts:
    - name: devmem
      mountPath: /host/dev/mem
  volumes:
  - name: devmem
    hostPath:
      path: /dev/mem
      type: CharDevice
EOF

# Create interactive-shell pod
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: interactive-shell
  namespace: cks-falco
spec:
  containers:
  - name: shell
    image: alpine:3.20
    command: ["sh","-c","sleep 3600"]
EOF

# Ensure Falco rules local file exists (backup if present)
if [ -f /etc/falco/falco_rules.local.yaml ]; then
  cp /etc/falco/falco_rules.local.yaml /etc/falco/falco_rules.local.yaml.bak 2>/dev/null || true
fi

# Clean up any previous output files
rm -f /root/falco-rules-output.txt /root/falco-shadow-evidence.txt 2>/dev/null || true

echo "[Q17] Lab setup complete."
echo "  Namespace: cks-falco"
echo "  Pods: devmem-pod, interactive-shell"
echo "  NOTE: Falco must be installed as DaemonSet in 'falco' namespace"
