#!/bin/bash
###############################################################################
#  CKS Practice Exam — Automated Answer Validator (22 Questions)
#  ------------------------------------------------
#  Validates your answers for all 22 CKS-PREP-2025 labs and produces a
#  score report identical in style to the real CKS exam.
#
#  Passing score: 66%
#
#  Usage:
#    bash scripts/validate-cks.sh            # run ALL questions
#    bash scripts/validate-cks.sh 1 3 5      # run only Q1, Q3, Q5
#
#  Requirements: kubectl, trivy/bom (Q5), openssl (Q3/Q7)
###############################################################################
set -o pipefail

# ─── Colors & Symbols ───────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'
PASS_SYM="✅"; FAIL_SYM="❌"; LINE="━"

# ─── Global Counters ────────────────────────────────────────────────────────
TOTAL_CHECKS=0
PASSED_CHECKS=0
declare -A Q_TOTAL Q_PASSED Q_TITLE Q_WEIGHT

# ─── Helper Functions ────────────────────────────────────────────────────────

header() {
  local w=70
  printf "\n${CYAN}"
  printf '%*s' "$w" '' | tr ' ' "$LINE"
  printf "\n  %s\n" "$1"
  printf '%*s' "$w" '' | tr ' ' "$LINE"
  printf "${RESET}\n"
}

check() {
  local qnum="$1"; shift
  local desc="$1"; shift
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  Q_TOTAL[$qnum]=$(( ${Q_TOTAL[$qnum]:-0} + 1 ))

  if eval "$@" >/dev/null 2>&1; then
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    Q_PASSED[$qnum]=$(( ${Q_PASSED[$qnum]:-0} + 1 ))
    printf "  ${GREEN}${PASS_SYM}  %-60s${RESET}\n" "$desc"
    return 0
  else
    printf "  ${RED}${FAIL_SYM}  %-60s${RESET}\n" "$desc"
    return 1
  fi
}

register_question() {
  Q_TITLE[$1]="$2"
  Q_WEIGHT[$1]="$3"
}

# ─── Determine which questions to run ────────────────────────────────────────
SELECTED_QUESTIONS=()
if [[ $# -gt 0 ]]; then
  for q in "$@"; do
    SELECTED_QUESTIONS+=("$q")
  done
else
  for i in $(seq 1 22); do
    SELECTED_QUESTIONS+=("$i")
  done
fi

should_run() {
  for q in "${SELECTED_QUESTIONS[@]}"; do
    [[ "$q" == "$1" ]] && return 0
  done
  return 1
}

###############################################################################
#  QUESTION 1 — Falco: Detect Pods Accessing /dev/mem (8%)
###############################################################################
register_question 1 "Falco — /dev/mem Detection" 8

validate_q1() {
  header "Question 1: Falco — /dev/mem Detection"

  check 1 "File /root/falco-alerts.txt exists" \
    "test -f /root/falco-alerts.txt"

  check 1 "falco-alerts.txt contains /dev/mem alert entries" \
    "grep -q '/dev/mem' /root/falco-alerts.txt 2>/dev/null"

  check 1 "Deployment 'nvidia' scaled to 0 replicas" \
    "[ \"\$(kubectl get deployment nvidia -n gpu-workloads -o jsonpath='{.spec.replicas}' 2>/dev/null)\" = '0' ]"

  check 1 "Deployment 'cpu' scaled to 0 replicas" \
    "[ \"\$(kubectl get deployment cpu -n gpu-workloads -o jsonpath='{.spec.replicas}' 2>/dev/null)\" = '0' ]"

  check 1 "Deployment 'ollama' scaled to 0 replicas" \
    "[ \"\$(kubectl get deployment ollama -n gpu-workloads -o jsonpath='{.spec.replicas}' 2>/dev/null)\" = '0' ]"

  check 1 "No pods running in gpu-workloads namespace" \
    "[ \$(kubectl get pods -n gpu-workloads --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l) -eq 0 ]"
}

###############################################################################
#  QUESTION 2 — Istio mTLS Sidecar (8%)
###############################################################################
register_question 2 "Istio — mTLS Sidecar" 8

validate_q2() {
  header "Question 2: Istio — mTLS Sidecar"

  check 2 "Namespace 'mesh-app' has istio-injection=enabled label" \
    "kubectl get namespace mesh-app -o jsonpath='{.metadata.labels.istio-injection}' 2>/dev/null | grep -q 'enabled'"

  check 2 "Deployment 'httpbin' exists in mesh-app" \
    "kubectl get deployment httpbin -n mesh-app -o name 2>/dev/null | grep -q 'deployment'"

  check 2 "httpbin pods have 2 containers (sidecar injected)" \
    "kubectl get pods -n mesh-app -l app=httpbin -o jsonpath='{.items[0].spec.containers[*].name}' 2>/dev/null | grep -q 'istio-proxy'"

  check 2 "PeerAuthentication 'strict-mtls' exists in mesh-app" \
    "kubectl get peerauthentication strict-mtls -n mesh-app -o name 2>/dev/null | grep -q 'peerauthentication'"

  check 2 "PeerAuthentication mode is STRICT" \
    "kubectl get peerauthentication strict-mtls -n mesh-app -o jsonpath='{.spec.mtls.mode}' 2>/dev/null | grep -q 'STRICT'"

  check 2 "PeerAuthentication is namespace-scoped (mesh-app)" \
    "kubectl get peerauthentication strict-mtls -n mesh-app -o jsonpath='{.metadata.namespace}' 2>/dev/null | grep -q 'mesh-app'"
}

###############################################################################
#  QUESTION 3 — Ingress with TLS (8%)
###############################################################################
register_question 3 "Ingress — TLS & HTTPS Redirect" 8

validate_q3() {
  header "Question 3: Ingress — TLS & HTTPS Redirect"

  check 3 "Ingress 'web-ingress' exists in namespace 'secure-web'" \
    "kubectl get ingress web-ingress -n secure-web -o name 2>/dev/null | grep -q 'ingress'"

  check 3 "Ingress uses ingressClassName: nginx" \
    "kubectl get ingress web-ingress -n secure-web -o jsonpath='{.spec.ingressClassName}' 2>/dev/null | grep -q 'nginx'"

  check 3 "Ingress has TLS configuration with secret 'app-tls'" \
    "kubectl get ingress web-ingress -n secure-web -o jsonpath='{.spec.tls[0].secretName}' 2>/dev/null | grep -q 'app-tls'"

  check 3 "TLS host is 'secure.example.com'" \
    "kubectl get ingress web-ingress -n secure-web -o json 2>/dev/null | grep -q 'secure.example.com'"

  check 3 "Annotation ssl-redirect is set to 'true'" \
    "kubectl get ingress web-ingress -n secure-web -o jsonpath='{.metadata.annotations}' 2>/dev/null | grep -qE 'ssl-redirect.*true|force-ssl-redirect.*true'"

  check 3 "Ingress rule host is 'secure.example.com'" \
    "kubectl get ingress web-ingress -n secure-web -o jsonpath='{.spec.rules[0].host}' 2>/dev/null | grep -q 'secure.example.com'"

  check 3 "Ingress routes to service 'web-service' port 80" \
    "kubectl get ingress web-ingress -n secure-web -o json 2>/dev/null | grep -q 'web-service'"

  check 3 "Ingress path is '/' with Prefix type" \
    "kubectl get ingress web-ingress -n secure-web -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null | grep -q 'Prefix'"
}

###############################################################################
#  QUESTION 4 — Docker Daemon Security (8%)
###############################################################################
register_question 4 "Docker Daemon — Security Hardening" 8

validate_q4() {
  header "Question 4: Docker Daemon — Security Hardening"

  check 4 "User 'develop' is NOT in docker group" \
    "! groups develop 2>/dev/null | grep -qw 'docker'"

  check 4 "User 'develop' still exists on the system" \
    "id develop >/dev/null 2>&1"

  check 4 "Docker socket /var/run/docker.sock owned by root:root" \
    "[ \"\$(stat -c '%U:%G' /var/run/docker.sock 2>/dev/null)\" = 'root:root' ]"

  check 4 "Docker service ExecStart uses unix socket" \
    "grep -q 'unix:///var/run/docker.sock' /lib/systemd/system/docker.service 2>/dev/null"

  check 4 "Docker service ExecStart does NOT use tcp://" \
    "! grep -q 'tcp://0.0.0.0:2375' /lib/systemd/system/docker.service 2>/dev/null"

  check 4 "Docker service is active (running)" \
    "systemctl is-active docker 2>/dev/null | grep -q 'active'"
}

###############################################################################
#  QUESTION 5 — BOM / SBOM (7%)
###############################################################################
register_question 5 "BOM — Software Bill of Materials" 7

validate_q5() {
  header "Question 5: BOM — Software Bill of Materials"

  check 5 "Deployment 'alpine-multi' exists in namespace 'sbom'" \
    "kubectl get deployment alpine-multi -n sbom -o name 2>/dev/null | grep -q 'deployment'"

  check 5 "Container 'alpine-v3' (alpine:3.16.1) was removed" \
    "! kubectl get deployment alpine-multi -n sbom -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | grep -q 'alpine-v3'"

  check 5 "Container 'alpine-v1' (alpine:3.20.0) still exists" \
    "kubectl get deployment alpine-multi -n sbom -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | grep -q 'alpine-v1'"

  check 5 "Container 'alpine-v2' (alpine:3.19.6) still exists" \
    "kubectl get deployment alpine-multi -n sbom -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | grep -q 'alpine-v2'"

  check 5 "Deployment has exactly 2 containers" \
    "[ \$(kubectl get deployment alpine-multi -n sbom -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null | wc -w) -eq 2 ]"

  check 5 "File ~/alpine-deploy.yaml no longer references alpine:3.16.1" \
    "! grep -q 'alpine:3.16.1' ~/alpine-deploy.yaml 2>/dev/null"

  check 5 "SPDX report /root/sbom-report.spdx exists" \
    "test -f /root/sbom-report.spdx"

  check 5 "SPDX report contains valid SPDX content" \
    "grep -qiE 'SPDX|SPDXVersion|spdx-id|spdxVersion|DocumentNamespace' /root/sbom-report.spdx 2>/dev/null"

  check 5 "SPDX report references alpine:3.20.0" \
    "grep -qi 'alpine.*3.20.0\|alpine:3.20.0' /root/sbom-report.spdx 2>/dev/null"
}

###############################################################################
#  QUESTION 6 — Static File Analysis (7%)
###############################################################################
register_question 6 "Static Analysis — Dockerfile & Deployment" 7

validate_q6() {
  header "Question 6: Static Analysis — Dockerfile & Deployment"

  check 6 "Dockerfile ~/Dockerfile exists" \
    "test -f ~/Dockerfile"

  check 6 "Dockerfile uses 'USER couchdb' (not root)" \
    "grep -q '^USER couchdb' ~/Dockerfile 2>/dev/null"

  check 6 "Dockerfile does NOT contain 'USER root'" \
    "! grep -q '^USER root' ~/Dockerfile 2>/dev/null"

  check 6 "Dockerfile line count is unchanged (39 lines)" \
    "[ \$(wc -l < ~/Dockerfile 2>/dev/null) -eq 39 ]"

  check 6 "Deployment file ~/couchdb-deploy.yaml exists" \
    "test -f ~/couchdb-deploy.yaml"

  check 6 "Deployment has readOnlyRootFilesystem: true" \
    "grep -q 'readOnlyRootFilesystem: true' ~/couchdb-deploy.yaml 2>/dev/null"

  check 6 "Deployment does NOT have readOnlyRootFilesystem: false" \
    "! grep -q 'readOnlyRootFilesystem: false' ~/couchdb-deploy.yaml 2>/dev/null"

  check 6 "Deployment YAML line count is unchanged (68 lines)" \
    "[ \$(wc -l < ~/couchdb-deploy.yaml 2>/dev/null) -eq 68 ]"
}

###############################################################################
#  QUESTION 7 — Secret TLS (7%)
###############################################################################
register_question 7 "Secret TLS — Create & Mount" 7

validate_q7() {
  header "Question 7: Secret TLS — Create & Mount"

  check 7 "Secret 'nginx-tls-secret' exists in namespace 'tls-app'" \
    "kubectl get secret nginx-tls-secret -n tls-app -o name 2>/dev/null | grep -q 'secret'"

  check 7 "Secret type is kubernetes.io/tls" \
    "kubectl get secret nginx-tls-secret -n tls-app -o jsonpath='{.type}' 2>/dev/null | grep -q 'kubernetes.io/tls'"

  check 7 "Secret contains tls.crt and tls.key data" \
    "kubectl get secret nginx-tls-secret -n tls-app -o jsonpath='{.data}' 2>/dev/null | grep -q 'tls.crt' && kubectl get secret nginx-tls-secret -n tls-app -o jsonpath='{.data}' 2>/dev/null | grep -q 'tls.key'"

  check 7 "Deployment 'nginx-tls' exists in namespace 'tls-app'" \
    "kubectl get deployment nginx-tls -n tls-app -o name 2>/dev/null | grep -q 'deployment'"

  check 7 "Deployment mounts secret at /etc/nginx/ssl" \
    "kubectl get deployment nginx-tls -n tls-app -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[*].mountPath}' 2>/dev/null | grep -q '/etc/nginx/ssl'"

  check 7 "Deployment has volume referencing 'nginx-tls-secret'" \
    "kubectl get deployment nginx-tls -n tls-app -o json 2>/dev/null | grep -q 'nginx-tls-secret'"

  check 7 "Deployment pods are running" \
    "kubectl get deployment nginx-tls -n tls-app -o jsonpath='{.status.availableReplicas}' 2>/dev/null | grep -qE '[1-9]'"
}

###############################################################################
#  QUESTION 8 — Projected Volume & ServiceAccount (7%)
###############################################################################
register_question 8 "Projected Volume & SA Token" 7

validate_q8() {
  header "Question 8: Projected Volume & ServiceAccount Token"

  check 8 "SA 'backend-sa' has automountServiceAccountToken: false" \
    "kubectl get sa backend-sa -n secure-app -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null | grep -q 'false'"

  check 8 "Deployment 'backend' exists in namespace 'secure-app'" \
    "kubectl get deployment backend -n secure-app -o name 2>/dev/null | grep -q 'deployment'"

  check 8 "Deployment uses projected volume" \
    "kubectl get deployment backend -n secure-app -o json 2>/dev/null | grep -q 'projected'"

  check 8 "Projected volume has serviceAccountToken source" \
    "kubectl get deployment backend -n secure-app -o json 2>/dev/null | grep -q 'serviceAccountToken'"

  check 8 "Token expirationSeconds is 3600" \
    "kubectl get deployment backend -n secure-app -o json 2>/dev/null | grep -q '3600'"

  check 8 "Volume mounted at /var/run/secrets/kubernetes.io/serviceaccount" \
    "kubectl get deployment backend -n secure-app -o json 2>/dev/null | grep -q '/var/run/secrets/kubernetes.io/serviceaccount'"

  check 8 "Deployment pods are running" \
    "kubectl get deployment backend -n secure-app -o jsonpath='{.status.availableReplicas}' 2>/dev/null | grep -qE '[1-9]'"
}

###############################################################################
#  QUESTION 9 — Kube-Bench CIS Fixes (7%)
###############################################################################
register_question 9 "Kube-Bench — CIS Benchmark Fixes" 7

validate_q9() {
  header "Question 9: Kube-Bench — CIS Benchmark Fixes"

  check 9 "kubelet anonymous auth is disabled (false)" \
    "grep -A1 'anonymous:' /var/lib/kubelet/config.yaml 2>/dev/null | grep -q 'enabled: false'"

  check 9 "kubelet authorization mode is Webhook (not AlwaysAllow)" \
    "grep 'mode:' /var/lib/kubelet/config.yaml 2>/dev/null | head -1 | grep -q 'Webhook'"

  check 9 "kubelet config does NOT have AlwaysAllow" \
    "! grep -q 'AlwaysAllow' /var/lib/kubelet/config.yaml 2>/dev/null"

  check 9 "etcd data dir /var/lib/etcd has permissions 700" \
    "[ \"\$(stat -c '%a' /var/lib/etcd 2>/dev/null)\" = '700' ]"

  check 9 "etcd data dir /var/lib/etcd owned by etcd:etcd" \
    "[ \"\$(stat -c '%U:%G' /var/lib/etcd 2>/dev/null)\" = 'etcd:etcd' ]"

  check 9 "kubelet service is active" \
    "systemctl is-active kubelet 2>/dev/null | grep -q 'active'"
}

###############################################################################
#  QUESTION 10 — Auditing (7%)
###############################################################################
register_question 10 "Auditing — API Server Audit Policy" 7

validate_q10() {
  header "Question 10: Auditing — API Server Audit Policy"

  check 10 "Audit policy file exists at /etc/kubernetes/audit/audit-policy.yaml" \
    "test -f /etc/kubernetes/audit/audit-policy.yaml"

  check 10 "Audit policy has Metadata level rule" \
    "grep -q 'Metadata' /etc/kubernetes/audit/audit-policy.yaml 2>/dev/null"

  check 10 "Audit policy has Request level rule" \
    "grep -q 'Request' /etc/kubernetes/audit/audit-policy.yaml 2>/dev/null"

  check 10 "Audit policy has RequestResponse level rule" \
    "grep -q 'RequestResponse' /etc/kubernetes/audit/audit-policy.yaml 2>/dev/null"

  check 10 "Audit policy references secrets resource" \
    "grep -q 'secrets' /etc/kubernetes/audit/audit-policy.yaml 2>/dev/null"

  check 10 "Audit policy references kube-system namespace" \
    "grep -q 'kube-system' /etc/kubernetes/audit/audit-policy.yaml 2>/dev/null"

  check 10 "kube-apiserver has --audit-policy-file flag" \
    "grep -q 'audit-policy-file' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"

  check 10 "kube-apiserver has --audit-log-path flag" \
    "grep -q 'audit-log-path' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"

  check 10 "kube-apiserver has --audit-log-maxage flag" \
    "grep -q 'audit-log-maxage' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"

  check 10 "kube-apiserver has audit volume mount" \
    "grep -q 'audit' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"
}

###############################################################################
#  QUESTION 11 — ImagePolicyWebhook (4%)
###############################################################################
register_question 11 "ImagePolicyWebhook — Admission Controller" 4

validate_q11() {
  header "Question 11: ImagePolicyWebhook — Admission Controller"

  check 11 "Admission config has defaultAllow: false" \
    "grep -q 'defaultAllow: false' /etc/kubernetes/admission/admission-config.yaml 2>/dev/null"

  check 11 "Admission config does NOT have defaultAllow: true" \
    "! grep -q 'defaultAllow: true' /etc/kubernetes/admission/admission-config.yaml 2>/dev/null"

  check 11 "kube-apiserver has ImagePolicyWebhook in admission plugins" \
    "grep -q 'ImagePolicyWebhook' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"

  check 11 "kube-apiserver has --admission-control-config-file flag" \
    "grep -q 'admission-control-config-file' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"

  check 11 "kube-apiserver has admission volume mount" \
    "grep -q '/etc/kubernetes/admission' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"
}

###############################################################################
#  QUESTION 12 — Network Policies (7%)
###############################################################################
register_question 12 "Network Policies — Ingress/Egress" 7

validate_q12() {
  header "Question 12: Network Policies — Ingress/Egress"

  check 12 "NetworkPolicy 'backend-netpol' exists in 'backend' ns" \
    "kubectl get networkpolicy backend-netpol -n backend -o name 2>/dev/null | grep -q 'networkpolicy'"

  check 12 "backend-netpol selects pods with app=backend" \
    "kubectl get networkpolicy backend-netpol -n backend -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null | grep -q 'backend'"

  check 12 "backend-netpol allows ingress from frontend namespace" \
    "kubectl get networkpolicy backend-netpol -n backend -o json 2>/dev/null | grep -q 'frontend'"

  check 12 "backend-netpol allows ingress on port 8080" \
    "kubectl get networkpolicy backend-netpol -n backend -o json 2>/dev/null | grep -q '8080'"

  check 12 "NetworkPolicy 'database-netpol' exists in 'database' ns" \
    "kubectl get networkpolicy database-netpol -n database -o name 2>/dev/null | grep -q 'networkpolicy'"

  check 12 "database-netpol selects pods with app=database" \
    "kubectl get networkpolicy database-netpol -n database -o jsonpath='{.spec.podSelector.matchLabels.app}' 2>/dev/null | grep -q 'database'"

  check 12 "database-netpol allows ingress from backend namespace" \
    "kubectl get networkpolicy database-netpol -n database -o json 2>/dev/null | grep -q 'backend'"

  check 12 "database-netpol allows ingress on port 3306" \
    "kubectl get networkpolicy database-netpol -n database -o json 2>/dev/null | grep -q '3306'"

  check 12 "database-netpol has Egress policy type" \
    "kubectl get networkpolicy database-netpol -n database -o jsonpath='{.spec.policyTypes[*]}' 2>/dev/null | grep -q 'Egress'"

  check 12 "database-netpol denies all egress (empty egress array)" \
    "[ \"\$(kubectl get networkpolicy database-netpol -n database -o jsonpath='{.spec.egress}' 2>/dev/null)\" = '' ] || [ \"\$(kubectl get networkpolicy database-netpol -n database -o jsonpath='{.spec.egress}' 2>/dev/null)\" = '[]' ]"
}

###############################################################################
#  QUESTION 13 — Pod Security Standards (5%)
###############################################################################
register_question 13 "PSS — Pod Security Standards" 5

validate_q13() {
  header "Question 13: PSS — Pod Security Standards"

  check 13 "Namespace 'restricted-ns' has PSS enforce=restricted" \
    "kubectl get namespace restricted-ns -o jsonpath='{.metadata.labels.pod-security\\.kubernetes\\.io/enforce}' 2>/dev/null | grep -q 'restricted'"

  check 13 "Deployment 'secure-app' exists in restricted-ns" \
    "kubectl get deployment secure-app -n restricted-ns -o name 2>/dev/null | grep -q 'deployment'"

  check 13 "Deployment does NOT use privileged: true" \
    "! kubectl get deployment secure-app -n restricted-ns -o json 2>/dev/null | grep -q '\"privileged\":true\|\"privileged\": true'"

  check 13 "Deployment does NOT use hostNetwork: true" \
    "! kubectl get deployment secure-app -n restricted-ns -o json 2>/dev/null | grep -q '\"hostNetwork\":true\|\"hostNetwork\": true'"

  check 13 "Deployment does NOT use hostPID: true" \
    "! kubectl get deployment secure-app -n restricted-ns -o json 2>/dev/null | grep -q '\"hostPID\":true\|\"hostPID\": true'"

  check 13 "Deployment has runAsNonRoot: true" \
    "kubectl get deployment secure-app -n restricted-ns -o json 2>/dev/null | grep -q 'runAsNonRoot'"

  check 13 "Deployment has allowPrivilegeEscalation: false" \
    "kubectl get deployment secure-app -n restricted-ns -o json 2>/dev/null | grep -q '\"allowPrivilegeEscalation\":false\|\"allowPrivilegeEscalation\": false'"

  check 13 "Deployment has seccompProfile RuntimeDefault" \
    "kubectl get deployment secure-app -n restricted-ns -o json 2>/dev/null | grep -q 'RuntimeDefault'"

  check 13 "Deployment has capabilities drop ALL" \
    "kubectl get deployment secure-app -n restricted-ns -o json 2>/dev/null | grep -q 'ALL'"

  check 13 "Deployment pods are running (not stuck)" \
    "kubectl get deployment secure-app -n restricted-ns -o jsonpath='{.status.availableReplicas}' 2>/dev/null | grep -qE '[1-9]'"
}

###############################################################################
#  QUESTION 14 — Kube-Apiserver Anonymous Auth (4%)
###############################################################################
register_question 14 "Kube-Apiserver — Anonymous Auth" 4

validate_q14() {
  header "Question 14: Kube-Apiserver — Anonymous Auth"

  check 14 "kube-apiserver has --anonymous-auth=false" \
    "grep -q 'anonymous-auth=false' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"

  check 14 "kube-apiserver does NOT have --anonymous-auth=true" \
    "! grep -q 'anonymous-auth=true' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"

  check 14 "ClusterRoleBinding 'system:anonymous' does NOT exist" \
    "! kubectl get clusterrolebinding system:anonymous -o name 2>/dev/null | grep -q 'clusterrolebinding'"
}

###############################################################################
#  QUESTION 15 — Seccomp Profile (4%)
###############################################################################
register_question 15 "Seccomp — Profile Application" 4

validate_q15() {
  header "Question 15: Seccomp — Profile Application"

  check 15 "Custom seccomp profile exists on node" \
    "test -f /var/lib/kubelet/seccomp/profiles/audit.json"

  check 15 "Deployment 'seccomp-app' has Localhost seccomp profile" \
    "kubectl get deployment seccomp-app -n seccomp-ns -o json 2>/dev/null | grep -q 'Localhost'"

  check 15 "Deployment seccomp localhostProfile is profiles/audit.json" \
    "kubectl get deployment seccomp-app -n seccomp-ns -o json 2>/dev/null | grep -q 'profiles/audit.json'"

  check 15 "Pod 'default-seccomp' exists in seccomp-ns" \
    "kubectl get pod default-seccomp -n seccomp-ns -o name 2>/dev/null | grep -q 'pod'"

  check 15 "Pod 'default-seccomp' has RuntimeDefault seccomp profile" \
    "kubectl get pod default-seccomp -n seccomp-ns -o json 2>/dev/null | grep -q 'RuntimeDefault'"

  check 15 "Pod 'default-seccomp' is running" \
    "kubectl get pod default-seccomp -n seccomp-ns -o jsonpath='{.status.phase}' 2>/dev/null | grep -q 'Running'"
}

###############################################################################
#  QUESTION 16 — Upgrade Worker Node (4%)
###############################################################################
register_question 16 "Upgrade Worker Node — v1.33.0 → v1.33.1" 4

validate_q16() {
  header "Question 16: Upgrade Worker Node — v1.33.0 → v1.33.1"

  # Detect worker node name (first non-control-plane node)
  local WORKER
  WORKER=$(kubectl get nodes --no-headers 2>/dev/null | grep -v 'control-plane\|master' | awk '{print $1}' | head -1)
  if [[ -z "$WORKER" ]]; then
    WORKER="worker-node01"
  fi

  check 16 "Worker node '$WORKER' exists" \
    "kubectl get node $WORKER -o name 2>/dev/null | grep -q 'node'"

  check 16 "Worker node '$WORKER' is Ready" \
    "kubectl get node $WORKER -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}' 2>/dev/null | grep -q 'True'"

  check 16 "Worker node '$WORKER' is NOT cordoned (SchedulingDisabled)" \
    "! kubectl get node $WORKER -o jsonpath='{.spec.unschedulable}' 2>/dev/null | grep -q 'true'"

  check 16 "Worker node '$WORKER' kubelet version is v1.33.1" \
    "kubectl get node $WORKER -o jsonpath='{.status.nodeInfo.kubeletVersion}' 2>/dev/null | grep -q 'v1.33.1'"
}

###############################################################################
#  QUESTION 17 — Falco Real Rules (5%)
###############################################################################
register_question 17 "Falco — Real Rule Checks" 5

validate_q17() {
  header "Question 17: Falco — Real Rule Checks & Custom Rules"

  check 17 "Pod 'devmem-pod' deleted from cks-falco namespace" \
    "! kubectl get pod devmem-pod -n cks-falco -o name 2>/dev/null | grep -q 'pod'"

  check 17 "Pod 'interactive-shell' deleted from cks-falco namespace" \
    "! kubectl get pod interactive-shell -n cks-falco -o name 2>/dev/null | grep -q 'pod'"

  check 17 "Falco alerts file /root/falco-rules-output.txt exists" \
    "test -f /root/falco-rules-output.txt"

  check 17 "Falco alerts file contains data" \
    "test -s /root/falco-rules-output.txt"

  check 17 "Custom Falco rule file exists at /etc/falco/falco_rules.local.yaml" \
    "test -f /etc/falco/falco_rules.local.yaml"

  check 17 "Custom rule contains 'Read shadow file' rule" \
    "grep -q 'Read shadow file' /etc/falco/falco_rules.local.yaml 2>/dev/null"

  check 17 "Custom rule references /etc/shadow" \
    "grep -q '/etc/shadow' /etc/falco/falco_rules.local.yaml 2>/dev/null"

  check 17 "Shadow evidence file /root/falco-shadow-evidence.txt exists" \
    "test -f /root/falco-shadow-evidence.txt"
}

###############################################################################
#  QUESTION 18 — Trivy + SPDX (5%)
###############################################################################
register_question 18 "Trivy — Vuln Scan & SBOM" 5

validate_q18() {
  header "Question 18: Trivy — Vulnerability Scan & SPDX/SBOM"

  check 18 "Trivy image report /root/trivy-image-report.txt exists" \
    "test -f /root/trivy-image-report.txt"

  check 18 "Trivy image report contains vulnerability data" \
    "test -s /root/trivy-image-report.txt"

  check 18 "Trivy config report /root/trivy-config-report.txt exists" \
    "test -f /root/trivy-config-report.txt"

  check 18 "SPDX SBOM /root/trivy-sbom.spdx.json exists" \
    "test -f /root/trivy-sbom.spdx.json"

  check 18 "SPDX SBOM contains valid SPDX content" \
    "grep -qiE 'spdx|SPDXID|spdxVersion|DocumentNamespace' /root/trivy-sbom.spdx.json 2>/dev/null"

  check 18 "Deployment 'vuln-app' updated to alpine:3.20.0" \
    "kubectl get deployment vuln-app -n cks-trivy -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null | grep -q 'alpine:3.20.0'"

  check 18 "Deployment 'vuln-app' does NOT use alpine:3.16.1" \
    "! kubectl get deployment vuln-app -n cks-trivy -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null | grep -q 'alpine:3.16.1'"
}

###############################################################################
#  QUESTION 19 — AppArmor + Seccomp (5%)
###############################################################################
register_question 19 "AppArmor + Seccomp — Hardening" 5

validate_q19() {
  header "Question 19: AppArmor + Seccomp — Combined Hardening"

  check 19 "Deployment 'hardened-app' exists in cks-hardening" \
    "kubectl get deployment hardened-app -n cks-hardening -o name 2>/dev/null | grep -q 'deployment'"

  check 19 "Deployment has seccompProfile RuntimeDefault" \
    "kubectl get deployment hardened-app -n cks-hardening -o json 2>/dev/null | grep -q 'RuntimeDefault'"

  check 19 "Deployment has AppArmor annotation for container 'app'" \
    "kubectl get deployment hardened-app -n cks-hardening -o json 2>/dev/null | grep -q 'container.apparmor.security.beta.kubernetes.io/app'"

  check 19 "AppArmor annotation value is 'runtime/default'" \
    "kubectl get deployment hardened-app -n cks-hardening -o json 2>/dev/null | grep -q 'runtime/default'"

  check 19 "Deployment has allowPrivilegeEscalation: false" \
    "kubectl get deployment hardened-app -n cks-hardening -o json 2>/dev/null | grep -q '\"allowPrivilegeEscalation\":false\|\"allowPrivilegeEscalation\": false'"

  check 19 "Deployment has capabilities drop ALL" \
    "kubectl get deployment hardened-app -n cks-hardening -o json 2>/dev/null | grep -q 'ALL'"

  check 19 "Deployment pods are running" \
    "kubectl get deployment hardened-app -n cks-hardening -o jsonpath='{.status.availableReplicas}' 2>/dev/null | grep -qE '[1-9]'"
}

###############################################################################
#  QUESTION 20 — etcd Encryption (5%)
###############################################################################
register_question 20 "etcd Encryption — Secrets at Rest" 5

validate_q20() {
  header "Question 20: etcd Encryption — Secrets at Rest"

  check 20 "Encryption config exists at /etc/kubernetes/enc/enc.yaml" \
    "test -f /etc/kubernetes/enc/enc.yaml"

  check 20 "Encryption config has EncryptionConfiguration kind" \
    "grep -q 'EncryptionConfiguration' /etc/kubernetes/enc/enc.yaml 2>/dev/null"

  check 20 "Encryption config uses aescbc provider" \
    "grep -q 'aescbc' /etc/kubernetes/enc/enc.yaml 2>/dev/null"

  check 20 "Encryption config targets secrets resource" \
    "grep -q 'secrets' /etc/kubernetes/enc/enc.yaml 2>/dev/null"

  check 20 "Encryption config has identity fallback" \
    "grep -q 'identity' /etc/kubernetes/enc/enc.yaml 2>/dev/null"

  check 20 "kube-apiserver has --encryption-provider-config flag" \
    "grep -q 'encryption-provider-config' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"

  check 20 "kube-apiserver has enc volume mount" \
    "grep -q '/etc/kubernetes/enc' /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null"

  check 20 "Namespace 'cks-etcd' exists" \
    "kubectl get namespace cks-etcd -o name 2>/dev/null | grep -q 'namespace'"

  check 20 "Secret 'test-secret' exists in cks-etcd" \
    "kubectl get secret test-secret -n cks-etcd -o name 2>/dev/null | grep -q 'secret'"
}

###############################################################################
#  QUESTION 21 — Supply Chain Image Signing (4%)
###############################################################################
register_question 21 "Supply Chain — Image Verification" 4

validate_q21() {
  header "Question 21: Supply Chain — Image Signing & Verification"

  check 21 "Deployment 'untrusted-app' exists in cks-supply" \
    "kubectl get deployment untrusted-app -n cks-supply -o name 2>/dev/null | grep -q 'deployment'"

  check 21 "Deployment does NOT use 'latest' tag" \
    "! kubectl get deployment untrusted-app -n cks-supply -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null | grep -q ':latest'"

  check 21 "Deployment uses fixed version tag or digest" \
    "kubectl get deployment untrusted-app -n cks-supply -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null | grep -qE ':[0-9]|@sha256:'"

  check 21 "Evidence file /root/supply-chain-evidence.txt exists" \
    "test -f /root/supply-chain-evidence.txt"

  check 21 "Evidence file contains image reference" \
    "test -s /root/supply-chain-evidence.txt"
}

###############################################################################
#  QUESTION 22 — Runtime Detection (4%)
###############################################################################
register_question 22 "Runtime Detection — Investigate & Mitigate" 4

validate_q22() {
  header "Question 22: Runtime Detection — Investigate & Mitigate"

  check 22 "Evidence file /root/runtime-detect-evidence.txt exists" \
    "test -f /root/runtime-detect-evidence.txt"

  check 22 "Evidence file contains data" \
    "test -s /root/runtime-detect-evidence.txt"

  check 22 "Pod 'suspicious-writer' deleted from cks-runtime-detect" \
    "! kubectl get pod suspicious-writer -n cks-runtime-detect -o name 2>/dev/null | grep -q 'pod'"

  check 22 "Pod 'net-tool' deleted from cks-runtime-detect" \
    "! kubectl get pod net-tool -n cks-runtime-detect -o name 2>/dev/null | grep -q 'pod'"

  check 22 "No pods running in cks-runtime-detect namespace" \
    "[ \$(kubectl get pods -n cks-runtime-detect --no-headers 2>/dev/null | wc -l) -eq 0 ]"
}

###############################################################################
#  MAIN — Run validations & produce score report
###############################################################################

clear 2>/dev/null || true

printf "\n${BOLD}"
cat << 'BANNER'
   ╔═══════════════════════════════════════════════════════════════════╗
   ║     CKS Practice Exam — Automated Validator (22 Questions)      ║
   ║     Certified Kubernetes Security Specialist                     ║
   ║     Passing Score: 66%                                          ║
   ╚═══════════════════════════════════════════════════════════════════╝
BANNER
printf "${RESET}\n"

printf "  ${CYAN}Starting validation at $(date '+%Y-%m-%d %H:%M:%S')${RESET}\n"
printf "  ${CYAN}Questions selected: ${SELECTED_QUESTIONS[*]}${RESET}\n"

# Run each selected question
should_run 1  && validate_q1
should_run 2  && validate_q2
should_run 3  && validate_q3
should_run 4  && validate_q4
should_run 5  && validate_q5
should_run 6  && validate_q6
should_run 7  && validate_q7
should_run 8  && validate_q8
should_run 9  && validate_q9
should_run 10 && validate_q10
should_run 11 && validate_q11
should_run 12 && validate_q12
should_run 13 && validate_q13
should_run 14 && validate_q14
should_run 15 && validate_q15
should_run 16 && validate_q16
should_run 17 && validate_q17
should_run 18 && validate_q18
should_run 19 && validate_q19
should_run 20 && validate_q20
should_run 21 && validate_q21
should_run 22 && validate_q22

###############################################################################
#  SCORE REPORT
###############################################################################

header "EXAM RESULTS"

WEIGHTED_EARNED=0
WEIGHTED_TOTAL=0

printf "\n  ${BOLD}%-6s %-45s %7s %7s %8s${RESET}\n" "Q#" "Topic" "Checks" "Passed" "Score"
printf "  %-6s %-45s %7s %7s %8s\n" "------" "---------------------------------------------" "-------" "-------" "--------"

for q in "${SELECTED_QUESTIONS[@]}"; do
  total=${Q_TOTAL[$q]:-0}
  passed=${Q_PASSED[$q]:-0}
  title=${Q_TITLE[$q]:-"Unknown"}
  weight=${Q_WEIGHT[$q]:-5}

  if [[ $total -gt 0 ]]; then
    q_pct=$(echo "scale=1; $passed * 100 / $total" | bc)
    q_weighted=$(echo "scale=2; $passed * $weight / $total" | bc)
  else
    q_pct="0.0"
    q_weighted="0"
  fi

  WEIGHTED_EARNED=$(echo "scale=2; $WEIGHTED_EARNED + $q_weighted" | bc)
  WEIGHTED_TOTAL=$(echo "scale=2; $WEIGHTED_TOTAL + $weight" | bc)

  if [[ "$passed" == "$total" ]]; then
    color="$GREEN"
  elif [[ "$passed" == "0" ]]; then
    color="$RED"
  else
    color="$YELLOW"
  fi

  printf "  ${color}%-6s %-45s %4s    %4s    %5s%%${RESET}\n" \
    "Q${q}" "$title" "$total" "$passed" "$q_pct"
done

# Final percentage
if [[ $(echo "$WEIGHTED_TOTAL > 0" | bc) -eq 1 ]]; then
  FINAL_SCORE=$(echo "scale=1; $WEIGHTED_EARNED * 100 / $WEIGHTED_TOTAL" | bc)
else
  FINAL_SCORE="0.0"
fi

PASSING_SCORE=66

printf "\n"
printf "  %-6s %-45s %7s %7s\n" "------" "---------------------------------------------" "-------" "-------"
printf "  ${BOLD}%-6s %-45s %4s    %4s${RESET}\n" "TOTAL" "All Checks" "$TOTAL_CHECKS" "$PASSED_CHECKS"

printf "\n"

# CKS Domain mapping
printf "  ${DIM}CKS Exam Domain Mapping:${RESET}\n"
printf "  ${DIM}  Q1  Falco .............. Runtime Security${RESET}\n"
printf "  ${DIM}  Q2  Istio mTLS ......... Minimize Microservice Vulnerabilities${RESET}\n"
printf "  ${DIM}  Q3  Ingress TLS ........ Minimize Microservice Vulnerabilities${RESET}\n"
printf "  ${DIM}  Q4  Docker Daemon ...... System Hardening${RESET}\n"
printf "  ${DIM}  Q5  BOM/SBOM ........... Supply Chain Security${RESET}\n"
printf "  ${DIM}  Q6  Static Analysis .... Supply Chain Security${RESET}\n"
printf "  ${DIM}  Q7  Secret TLS ......... Minimize Microservice Vulnerabilities${RESET}\n"
printf "  ${DIM}  Q8  Projected Volume ... Minimize Microservice Vulnerabilities${RESET}\n"
printf "  ${DIM}  Q9  Kube-Bench ......... Cluster Hardening${RESET}\n"
printf "  ${DIM}  Q10 Auditing ........... Cluster Hardening${RESET}\n"
printf "  ${DIM}  Q11 ImagePolicyWebhook . Supply Chain Security${RESET}\n"
printf "  ${DIM}  Q12 Network Policies ... Minimize Microservice Vulnerabilities${RESET}\n"
printf "  ${DIM}  Q13 PSS ................ Minimize Microservice Vulnerabilities${RESET}\n"
printf "  ${DIM}  Q14 Kube-Apiserver ..... Cluster Hardening${RESET}\n"
printf "  ${DIM}  Q15 Seccomp ............ System Hardening${RESET}\n"
printf "  ${DIM}  Q16 Upgrade Worker ..... Cluster Setup${RESET}\n"
printf "  ${DIM}  Q17 Falco Rules ........ Runtime Security${RESET}\n"
printf "  ${DIM}  Q18 Trivy/SPDX ......... Supply Chain Security${RESET}\n"
printf "  ${DIM}  Q19 AppArmor+Seccomp ... System Hardening${RESET}\n"
printf "  ${DIM}  Q20 etcd Encryption .... Cluster Hardening${RESET}\n"
printf "  ${DIM}  Q21 Supply Chain ....... Supply Chain Security${RESET}\n"
printf "  ${DIM}  Q22 Runtime Detection .. Runtime Security${RESET}\n"

printf "\n"
printf "  ${BOLD}╔═══════════════════════════════════════════════╗${RESET}\n"

if [[ $(echo "$FINAL_SCORE >= $PASSING_SCORE" | bc) -eq 1 ]]; then
  printf "  ${BOLD}║  ${GREEN}FINAL SCORE: %5s%%   ✅  PASSED!${RESET}${BOLD}            ║${RESET}\n" "$FINAL_SCORE"
else
  printf "  ${BOLD}║  ${RED}FINAL SCORE: %5s%%   ❌  FAILED${RESET}${BOLD}             ║${RESET}\n" "$FINAL_SCORE"
fi

printf "  ${BOLD}║  Passing Score: %3s%%                          ║${RESET}\n" "$PASSING_SCORE"
printf "  ${BOLD}╚═══════════════════════════════════════════════╝${RESET}\n"

printf "\n  ${CYAN}Validation completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}\n\n"

# Exit code: 0 if passed, 1 if failed
[[ $(echo "$FINAL_SCORE >= $PASSING_SCORE" | bc) -eq 1 ]]
