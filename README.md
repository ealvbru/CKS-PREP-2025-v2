# CKS-PREP-2025 — Certified Kubernetes Security Specialist Practice Lab

A comprehensive **22-question** practice lab for the **CKS (Certified Kubernetes Security Specialist)** exam, designed to be used in **KillerShell**, **Killercoda**, or any kubeadm-based cluster.

Includes an **automated validator** with **143 granular checks** that scores your answers with a **66% passing threshold**, identical to the real CKS exam.

---

## Quick Start

```bash
# 1. Extract and enter the project
unzip CKS-PREP-2025.zip && cd CKS-PREP-2025

# 2. Set up and read a question
bash scripts/run-question.sh "Question-1 Falco"

# 3. Solve the question in your cluster...

# 4. Validate your answer
bash scripts/validate-cks.sh 1

# 5. Validate ALL questions at once
bash scripts/validate-cks.sh
```

---

## Questions & Weights

| Q# | Topic | CKS Domain | Weight | Checks |
|----|-------|-----------|--------|--------|
| Q1 | Falco — /dev/mem Detection | Runtime Security | 8% | 6 |
| Q2 | Istio — mTLS Sidecar Injection | Minimize Microservice Vulns | 8% | 6 |
| Q3 | Ingress — TLS & HTTPS Redirect | Minimize Microservice Vulns | 8% | 8 |
| Q4 | Docker Daemon — Security Hardening | System Hardening | 8% | 6 |
| Q5 | BOM — Software Bill of Materials | Supply Chain Security | 7% | 9 |
| Q6 | Static Analysis — Dockerfile & Deploy | Supply Chain Security | 7% | 8 |
| Q7 | Secret TLS — Create & Mount | Minimize Microservice Vulns | 7% | 7 |
| Q8 | Projected Volume & SA Token | Minimize Microservice Vulns | 7% | 7 |
| Q9 | Kube-Bench — CIS Benchmark Fixes | Cluster Hardening | 7% | 6 |
| Q10 | Auditing — API Server Audit Policy | Cluster Hardening | 7% | 10 |
| Q11 | ImagePolicyWebhook — Admission | Supply Chain Security | 4% | 5 |
| Q12 | Network Policies — Ingress/Egress | Minimize Microservice Vulns | 7% | 10 |
| Q13 | PSS — Pod Security Standards | Minimize Microservice Vulns | 5% | 10 |
| Q14 | Kube-Apiserver — Anonymous Auth | Cluster Hardening | 4% | 3 |
| Q15 | Seccomp — Profile Application | System Hardening | 4% | 6 |
| Q16 | Upgrade Worker Node — v1.33.0 to v1.33.1 | Cluster Setup | 4% | 4 |
| Q17 | Falco — Real Rule Checks & Custom Rules | Runtime Security | 5% | 8 |
| Q18 | Trivy — Vulnerability Scan & SBOM | Supply Chain Security | 5% | 7 |
| Q19 | AppArmor + Seccomp — Combined Hardening | System Hardening | 5% | 7 |
| Q20 | etcd Encryption — Secrets at Rest | Cluster Hardening | 5% | 9 |
| Q21 | Supply Chain — Image Verification | Supply Chain Security | 4% | 5 |
| Q22 | Runtime Detection — Investigate & Mitigate | Runtime Security | 4% | 5 |
| | **TOTAL** | | **128%** | **143** |

> **Note:** Weights sum to more than 100% because this is a practice lab with extra coverage. The validator normalizes the score to the selected questions.

---

## CKS Exam Domain Coverage

| CKS Domain | Questions | Combined Weight |
|-----------|-----------|----------------|
| Cluster Setup | Q16 | 4% |
| Cluster Hardening | Q9, Q10, Q14, Q20 | 23% |
| System Hardening | Q4, Q15, Q19 | 17% |
| Minimize Microservice Vulnerabilities | Q2, Q3, Q7, Q8, Q12, Q13 | 42% |
| Supply Chain Security | Q5, Q6, Q11, Q18, Q21 | 27% |
| Runtime Security | Q1, Q17, Q22 | 17% |

---

## Project Structure

```
CKS-PREP-2025/
├── README.md
├── scripts/
│   ├── run-question.sh                    # Setup + display question
│   └── validate-cks.sh                    # Automated validator (66% pass)
├── Question-1 Falco/
│   ├── LabSetUp.bash
│   ├── Questions.bash
│   └── SolutionNotes.bash
├── Question-2 Istio-mTLS/
├── Question-3 Ingress-TLS/
├── Question-4 Docker-Daemon-Secure/
├── Question-5 BOM-SBOM/
├── Question-6 Static-Analysis/
├── Question-7 Secret-TLS/
├── Question-8 Projected-Volume-SA/
├── Question-9 Kube-Bench/
├── Question-10 Auditing/
├── Question-11 ImagePolicyWebhook/
├── Question-12 Network-Policies/
├── Question-13 PSS/
├── Question-14 Kube-Apiserver/
├── Question-15 Seccomp-Profile/
├── Question-16 Upgrade-Worker-Node/
├── Question-17 Falco-Rules/
├── Question-18 Trivy-SPDX/
├── Question-19 AppArmor-Seccomp/
├── Question-20 Etcd-Encryption/
├── Question-21 Supply-Chain/
└── Question-22 Runtime-Detection/
```

Each question directory contains three files:

- **LabSetUp.bash** — Run first. Creates the initial cluster state (namespaces, deployments, files, configs). Some questions intentionally create insecure or broken configurations that you must fix.
- **Questions.bash** — Displays the exam scenario and tasks. Read carefully before solving.
- **SolutionNotes.bash** — Reference solution. Only consult after attempting the question.

---

## Validator Usage

### Run all 22 questions
```bash
bash scripts/validate-cks.sh
```

### Run specific questions
```bash
bash scripts/validate-cks.sh 1 3 5 12 17
```

### Output format
The validator produces:
- Per-check pass/fail with colored output
- Per-question score breakdown table
- Weighted final score percentage
- PASS/FAIL verdict at 66% threshold
- Exit code 0 (pass) or 1 (fail)

---

## Recommended Workflow

1. **Pick a question** — Start with topics you find challenging
2. **Run the setup** — `bash scripts/run-question.sh "Question-X Topic"`
3. **Read the question** — Understand the scenario and all requirements
4. **Solve it** — Use only `kubectl`, vim, and the Kubernetes docs (like the real exam)
5. **Validate** — `bash scripts/validate-cks.sh X`
6. **Review** — Check `SolutionNotes.bash` if you got stuck
7. **Repeat** — Move to the next question

### Suggested Time Blocks

| Block | Time | Questions |
|-------|------|-----------|
| Block 1 | 20 min | Q1 (Falco), Q3 (Ingress TLS), Q7 (Secret TLS), Q8 (Projected Volume) |
| Block 2 | 25 min | Q13 (PSS), Q15 (Seccomp), Q12 (Network Policies), Q6 (Static Analysis) |
| Block 3 | 30 min | Q14 (Kube-Apiserver), Q10 (Auditing), Q11 (ImagePolicyWebhook), Q9 (Kube-Bench) |
| Block 4 | 15 min | Q4 (Docker Daemon), Q16 (Upgrade Worker) |
| Block 5 | 30 min | Q17 (Falco Rules), Q18 (Trivy), Q19 (AppArmor), Q20 (etcd), Q21 (Supply Chain), Q22 (Runtime) |

---

## Prerequisites

| Tool | Required For |
|------|-------------|
| `kubectl` | All questions |
| `helm` | Q2 (Istio install) |
| `istioctl` | Q2 (Istio sidecar) |
| `falco` | Q1, Q17, Q22 (runtime detection) |
| `trivy` | Q5, Q18 (SBOM/vulnerability scan) |
| `syft` | Q5, Q18 (SBOM generation, alternative) |
| `openssl` | Q3, Q7 (TLS certificates) |
| `docker` | Q4 (Docker daemon) |
| `kube-bench` | Q9 (CIS benchmark) |
| `kubeadm` | Q16 (node upgrade) |
| `etcdctl` | Q20 (etcd encryption verification) |
| `cosign` | Q21 (image signing, optional) |

---

## References

- [Falco Rules](https://falco.org/docs/reference/rules/examples/)
- [Istio mTLS Migration](https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/)
- [Istio Sidecar Injection](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)
- [Ingress-NGINX TLS](https://kubernetes.github.io/ingress-nginx/user-guide/tls/)
- [Ingress-NGINX Annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/)
- [Trivy SBOM](https://trivy.dev/docs/latest/supply-chain/sbom/)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Projected Volumes](https://kubernetes.io/docs/concepts/storage/projected-volumes/)
- [Kubernetes Auditing](https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/)
- [ImagePolicyWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#imagepolicywebhook)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Seccomp Profiles](https://kubernetes.io/docs/tutorials/security/seccomp/)
- [AppArmor Profiles](https://kubernetes.io/docs/tutorials/security/apparmor/)
- [Kubeadm Upgrade](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
- [Encrypt Data at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)
- [Container Images](https://kubernetes.io/docs/concepts/containers/images/)
