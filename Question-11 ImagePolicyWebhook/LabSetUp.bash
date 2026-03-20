#!/bin/bash
set -e

echo "🔹 Creating admission configuration directory..."
mkdir -p /etc/kubernetes/admission

echo "🔹 Creating admission config (with defaultAllow: true — insecure)..."
cat <<'ADMCONFIG' > /etc/kubernetes/admission/admission-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: /etc/kubernetes/admission/kubeconfig.yaml
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: true
ADMCONFIG

echo "🔹 Creating webhook kubeconfig..."
cat <<'KUBECONFIG' > /etc/kubernetes/admission/kubeconfig.yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://image-policy-webhook.default.svc:1323/image_policy
  name: image-checker
contexts:
- context:
    cluster: image-checker
    user: api-server
  name: image-checker
current-context: image-checker
preferences: {}
users:
- name: api-server
  user:
    client-certificate: /etc/kubernetes/pki/apiserver.crt
    client-key: /etc/kubernetes/pki/apiserver.key
KUBECONFIG

echo ""
echo "✅ Lab setup complete!"
echo "   - Admission config: /etc/kubernetes/admission/admission-config.yaml"
echo "     (defaultAllow is set to true — needs to be changed to false)"
echo "   - Webhook kubeconfig: /etc/kubernetes/admission/kubeconfig.yaml"
echo "   - kube-apiserver manifest: /etc/kubernetes/manifests/kube-apiserver.yaml"
echo "   - Your task: fix defaultAllow, enable ImagePolicyWebhook, add volumes"
