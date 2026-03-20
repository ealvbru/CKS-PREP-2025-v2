#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 9: Kube-Bench CIS Fixes
# ══════════════════════════════════════════════════════════════════════

# Step 1: Fix kubelet anonymous-auth
# Edit /var/lib/kubelet/config.yaml:
#   Change: authentication.anonymous.enabled: true
#   To:     authentication.anonymous.enabled: false
sed -i 's/enabled: true/enabled: false/' /var/lib/kubelet/config.yaml

# Step 2: Fix kubelet authorization mode
# Edit /var/lib/kubelet/config.yaml:
#   Change: authorization.mode: AlwaysAllow
#   To:     authorization.mode: Webhook
sed -i 's/mode: AlwaysAllow/mode: Webhook/' /var/lib/kubelet/config.yaml

# Step 3: Restart kubelet
systemctl daemon-reload
systemctl restart kubelet

# Step 4: Fix etcd data directory permissions
chmod 700 /var/lib/etcd
chown etcd:etcd /var/lib/etcd

# Verify all fixes:
grep -A1 'anonymous:' /var/lib/kubelet/config.yaml
grep 'mode:' /var/lib/kubelet/config.yaml | head -1
stat -c '%a %U:%G' /var/lib/etcd

# ══════════════════════════════════════════════════════════════════════
EOF
