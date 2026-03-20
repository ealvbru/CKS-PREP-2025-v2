#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 11: ImagePolicyWebhook
# ══════════════════════════════════════════════════════════════════════

# Step 1: Fix defaultAllow to false
sed -i 's/defaultAllow: true/defaultAllow: false/' /etc/kubernetes/admission/admission-config.yaml
# Verify:
grep defaultAllow /etc/kubernetes/admission/admission-config.yaml

# Step 2: Edit kube-apiserver manifest
# In /etc/kubernetes/manifests/kube-apiserver.yaml:

# a) Add ImagePolicyWebhook to admission plugins:
#    Change: --enable-admission-plugins=NodeRestriction
#    To:     --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook

# b) Add admission control config flag:
#    - --admission-control-config-file=/etc/kubernetes/admission/admission-config.yaml

# c) Add volumeMount:
#    - mountPath: /etc/kubernetes/admission
#      name: admission-config
#      readOnly: true

# d) Add volume:
#    - hostPath:
#        path: /etc/kubernetes/admission
#        type: DirectoryOrCreate
#      name: admission-config

# Step 3: Wait for apiserver to restart
# watch crictl ps | grep apiserver

# ══════════════════════════════════════════════════════════════════════
EOF
