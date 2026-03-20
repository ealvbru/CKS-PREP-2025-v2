#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 1: Falco /dev/mem
# ══════════════════════════════════════════════════════════════════════

# Step 1: Check Falco logs for /dev/mem alerts
kubectl logs -n falco -l app.kubernetes.io/name=falco | grep /dev/mem
# OR use the simulated log file:
cat /var/log/falco/falco-alerts.log | grep /dev/mem

# Step 2: Save the alerts to the required file
kubectl logs -n falco -l app.kubernetes.io/name=falco | grep /dev/mem > /root/falco-alerts.txt
# OR:
grep /dev/mem /var/log/falco/falco-alerts.log > /root/falco-alerts.txt

# Step 3: Scale down all three offending deployments to 0 replicas
kubectl scale deployment nvidia cpu ollama -n gpu-workloads --replicas=0

# Step 4: Verify no pods remain
kubectl get pods -n gpu-workloads
# Should show "No resources found"

# ══════════════════════════════════════════════════════════════════════
EOF
