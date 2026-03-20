#!/bin/bash
cat <<'SOLUTION'
╔══════════════════════════════════════════════════════════════════════╗
║  Solution Notes — Question 20: etcd Encryption at Rest              ║
╚══════════════════════════════════════════════════════════════════════╝

TASK 1 — Create Encryption Configuration:

  # Generate a 32-byte base64 key
  ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

  # Create the directory
  mkdir -p /etc/kubernetes/enc

  # Create the EncryptionConfiguration
  cat > /etc/kubernetes/enc/enc.yaml <<EOF
  apiVersion: apiserver.config.k8s.io/v1
  kind: EncryptionConfiguration
  resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: ${ENCRYPTION_KEY}
    - identity: {}
  EOF

TASK 2 — Configure kube-apiserver:

  # Edit the kube-apiserver static pod manifest
  vi /etc/kubernetes/manifests/kube-apiserver.yaml

  # Add to spec.containers[0].command:
  - --encryption-provider-config=/etc/kubernetes/enc/enc.yaml

  # Add volumeMount:
  volumeMounts:
  - mountPath: /etc/kubernetes/enc
    name: enc
    readOnly: true

  # Add volume:
  volumes:
  - hostPath:
      path: /etc/kubernetes/enc
      type: DirectoryOrCreate
    name: enc

  # Wait for kube-apiserver to restart (may take 1-2 minutes)
  watch crictl ps | grep kube-apiserver

TASK 3 — Verify Encryption:

  # Create test namespace and secret
  kubectl create namespace cks-etcd
  kubectl -n cks-etcd create secret generic test-secret --from-literal=password=s3cr3t

  # Verify in etcd (should show encrypted data, not plaintext)
  ETCDCTL_API=3 etcdctl \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    get /registry/secrets/cks-etcd/test-secret | hexdump -C

  # You should see "k8s:enc:aescbc:v1:" prefix, NOT plaintext "s3cr3t"

  # To re-encrypt existing secrets after enabling encryption:
  kubectl get secrets -A -o json | kubectl replace -f -

KEY REFERENCES:
  - https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

SOLUTION
