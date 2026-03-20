#!/bin/bash
cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════╗
║  CKS Practice Lab — Question 20                                     ║
║  Topic: etcd Encryption — Secrets at Rest                           ║
║  Domain: Cluster Hardening                                          ║
║  Weight: 5%                                                         ║
╚══════════════════════════════════════════════════════════════════════╝

CONTEXT:
  The cluster is running but Secrets are NOT encrypted at rest in etcd.
  You must enable encryption using aescbc provider.

  Kubernetes docs:
    https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

TASK 1 — Create Encryption Configuration:
  - Generate a 32-byte base64-encoded encryption key
  - Create the EncryptionConfiguration file at:
    /etc/kubernetes/enc/enc.yaml
  - Use provider "aescbc" with key name "key1"
  - The resource to encrypt is "secrets"
  - Include "identity: {}" as fallback provider

TASK 2 — Configure kube-apiserver:
  - Add the flag --encryption-provider-config=/etc/kubernetes/enc/enc.yaml
    to the kube-apiserver static pod manifest
  - Add the necessary volume and volumeMount for /etc/kubernetes/enc
  - Wait for kube-apiserver to restart

TASK 3 — Verify Encryption:
  - Create a namespace "cks-etcd"
  - Create a secret "test-secret" in namespace "cks-etcd" with:
    --from-literal=password=s3cr3t
  - Verify the secret is encrypted in etcd using etcdctl
  - The raw data should show "k8s:enc:aescbc:v1:" prefix, not plaintext

EOF
