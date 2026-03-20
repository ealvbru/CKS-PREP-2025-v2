#!/bin/bash
set -e

echo "🔹 Creating insecure kubelet config..."
mkdir -p /var/lib/kubelet
if [ -f /var/lib/kubelet/config.yaml ]; then
  cp /var/lib/kubelet/config.yaml /var/lib/kubelet/config.yaml.bak
fi

cat <<'KUBELET' > /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  anonymous:
    enabled: true
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: AlwaysAllow
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
cgroupDriver: systemd
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
containerRuntimeEndpoint: unix:///var/run/containerd/containerd.sock
cpuManagerReconcilePeriod: 0s
evictionPressureTransitionPeriod: 0s
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
logging:
  flushFrequency: 0
  options:
    json:
      infoBufferSize: "0"
  verbosity: 0
memorySwap: {}
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
rotateCertificates: true
runtimeRequestTimeout: 0s
shutdownGracePeriod: 0s
shutdownGracePeriodCriticalPods: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
KUBELET

echo "🔹 Setting insecure etcd directory permissions..."
mkdir -p /var/lib/etcd
chmod 777 /var/lib/etcd 2>/dev/null || true
chown root:root /var/lib/etcd 2>/dev/null || true

echo "🔹 Creating kube-bench report..."
cat <<'REPORT' > /root/kube-bench-report.txt
[INFO] 4 Worker Node Security Configuration
[INFO] 4.2 Kubelet
[FAIL] 4.2.1 Ensure that the --anonymous-auth argument is set to false (Automated)
       * Current setting: authentication.anonymous.enabled = true
       * File: /var/lib/kubelet/config.yaml
       * Remediation: Set authentication.anonymous.enabled to false

[FAIL] 4.2.2 Ensure that the --authorization-mode argument is not set to AlwaysAllow (Automated)
       * Current setting: authorization.mode = AlwaysAllow
       * File: /var/lib/kubelet/config.yaml
       * Remediation: Set authorization.mode to Webhook

[INFO] 2 Etcd Node Configuration
[FAIL] 2.1 Ensure that the --data-dir permissions are set to 700 or more restrictive (Automated)
       * Current permissions: 777
       * Directory: /var/lib/etcd
       * Remediation: chmod 700 /var/lib/etcd && chown etcd:etcd /var/lib/etcd

== Summary ==
3 checks FAIL
0 checks WARN
0 checks PASS
REPORT

echo ""
echo "✅ Lab setup complete!"
echo "   - kubelet config: /var/lib/kubelet/config.yaml (anonymous-auth=true, mode=AlwaysAllow)"
echo "   - etcd dir: /var/lib/etcd (permissions 777, owner root:root)"
echo "   - kube-bench report: /root/kube-bench-report.txt"
echo "   - Your task: fix all 3 issues and restart services"
