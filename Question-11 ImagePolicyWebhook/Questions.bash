#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 11 — ImagePolicyWebhook Admission Controller
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   An external image validation webhook service is running and
#   accessible. The configuration files are partially set up at:
#     - /etc/kubernetes/admission/admission-config.yaml
#     - /etc/kubernetes/admission/kubeconfig.yaml
#   The ImagePolicyWebhook admission controller is NOT yet enabled.
#
# Tasks:
#   1. Review and fix the admission configuration file at
#      /etc/kubernetes/admission/admission-config.yaml
#      Ensure defaultAllow is set to false (deny images by default)
#   2. Edit /etc/kubernetes/manifests/kube-apiserver.yaml to:
#      - Add ImagePolicyWebhook to the --enable-admission-plugins flag
#      - Add the flag:
#          --admission-control-config-file=/etc/kubernetes/admission/admission-config.yaml
#      - Add the necessary volume and volumeMount for the admission
#        configuration directory
#   3. Wait for the kube-apiserver to restart successfully
#
# References:
#   - https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#imagepolicywebhook
#
# Weight: 4%
# ══════════════════════════════════════════════════════════════════════
EOF
