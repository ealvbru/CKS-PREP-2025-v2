#!/bin/bash
set -e

echo "🔹 Creating namespace: gpu-workloads"
kubectl create namespace gpu-workloads --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Creating namespace: falco"
kubectl create namespace falco --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Deploying nvidia workload..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nvidia
  namespace: gpu-workloads
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nvidia
  template:
    metadata:
      labels:
        app: nvidia
    spec:
      containers:
      - name: nvidia
        image: busybox:1.36
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            cat /dev/mem > /dev/null 2>&1 || true
            echo "[nvidia] accessed /dev/mem at \$(date)"
            sleep 10
          done
        securityContext:
          privileged: true
EOF

echo "🔹 Deploying cpu workload..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu
  namespace: gpu-workloads
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cpu
  template:
    metadata:
      labels:
        app: cpu
    spec:
      containers:
      - name: cpu
        image: busybox:1.36
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            cat /dev/mem > /dev/null 2>&1 || true
            echo "[cpu] accessed /dev/mem at \$(date)"
            sleep 10
          done
        securityContext:
          privileged: true
EOF

echo "🔹 Deploying ollama workload..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: gpu-workloads
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      containers:
      - name: ollama
        image: busybox:1.36
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            cat /dev/mem > /dev/null 2>&1 || true
            echo "[ollama] accessed /dev/mem at \$(date)"
            sleep 10
          done
        securityContext:
          privileged: true
EOF

echo "🔹 Installing Falco via Helm (if helm is available)..."
if command -v helm &>/dev/null; then
  helm repo add falcosecurity https://falcosecurity.github.io/charts 2>/dev/null || true
  helm repo update 2>/dev/null || true
  helm upgrade --install falco falcosecurity/falco \
    --namespace falco \
    --set falcosidekick.enabled=false \
    --set driver.kind=modern_ebpf \
    --set collectors.containerd.socket=/run/containerd/containerd.sock \
    --wait --timeout 120s 2>/dev/null || echo "⚠️  Falco Helm install skipped (may need manual install)"
else
  echo "⚠️  Helm not found. Install Falco manually or install Helm first."
  echo "   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
fi

echo "🔹 Simulating Falco log output for lab purposes..."
mkdir -p /var/log/falco
cat <<'FALCOLOG' > /var/log/falco/falco-alerts.log
2025-10-14T10:23:01.123456789+0000: Warning Sensitive file opened for reading by non-trusted program (file=/dev/mem gparent=containerd-shim gparent=systemd evt_type=openat user=root user_uid=0 user_loginuid=-1 process=cat proc_exepath=/bin/cat parent=sh command=cat /dev/mem terminal=0 container_id=abc123def456 container_image=docker.io/library/busybox container_image_tag=1.36 container_name=nvidia k8s_ns=gpu-workloads k8s_pod_name=nvidia-7b8f9c6d4-xk2lp)
2025-10-14T10:23:11.234567890+0000: Warning Sensitive file opened for reading by non-trusted program (file=/dev/mem gparent=containerd-shim gparent=systemd evt_type=openat user=root user_uid=0 user_loginuid=-1 process=cat proc_exepath=/bin/cat parent=sh command=cat /dev/mem terminal=0 container_id=def456abc789 container_image=docker.io/library/busybox container_image_tag=1.36 container_name=cpu k8s_ns=gpu-workloads k8s_pod_name=cpu-5c4d3b2a1-mn9op)
2025-10-14T10:23:21.345678901+0000: Warning Sensitive file opened for reading by non-trusted program (file=/dev/mem gparent=containerd-shim gparent=systemd evt_type=openat user=root user_uid=0 user_loginuid=-1 process=cat proc_exepath=/bin/cat parent=sh command=cat /dev/mem terminal=0 container_id=ghi789jkl012 container_image=docker.io/library/busybox container_image_tag=1.36 container_name=ollama k8s_ns=gpu-workloads k8s_pod_name=ollama-1a2b3c4d5-qr6st)
FALCOLOG

echo ""
echo "✅ Lab setup complete!"
echo "   - Namespace: gpu-workloads (3 deployments: nvidia, cpu, ollama)"
echo "   - Namespace: falco (Falco runtime security)"
echo "   - Falco alerts available at: /var/log/falco/falco-alerts.log"
echo "   - Also check: kubectl logs -n falco -l app.kubernetes.io/name=falco"
