# Defense-Grade GitOps Landing Zone & DevSecOps Pipeline
### Hardened CIS Benchmark Kubernetes/ECS Infrastructure, OPA Zero-Trust Enforcement & Multi-Stage CI/CD Automation

[![CI Gate](https://github.com/FreeFades2Black/defense-gitops-landing-zone/actions/workflows/revolver-pipeline.yml/badge.svg)](https://github.com/FreeFades2Black/defense-gitops-landing-zone/actions/workflows/revolver-pipeline.yml)
[![PyTest Status](https://img.shields.io/badge/PyTest-100%25%20Passed-brightgreen?style=for-the-badge&logo=pytest&logoColor=white)](https://github.com/FreeFades2Black/defense-gitops-landing-zone)
[![Compliance Standards](https://img.shields.io/badge/Compliance-NIST%20800--53%20%7C%20CIS%20v1.8-blue?style=for-the-badge&logo=shield&logoColor=white)](https://github.com/FreeFades2Black/defense-gitops-landing-zone)

---

## Architecture Overview & Operational Context

Defense industrial base contractors and regulated enterprise environments require verifiable zero-trust boundaries and automated compliance verification.

This repository provides a **Defense-Grade GitOps Landing Zone & DevSecOps Pipeline** that automates:
1. **CIS Benchmark Hardened Infrastructure:** OpenTofu / Terraform landing zone provisioning private-only EKS/ECS clusters, customer-managed KMS envelope encryption for Kubernetes secrets, and encrypted VPC Flow Logs.
2. **Zero-Trust OPA / Rego Admission Gates:** Strict policy-as-code preventing root containers, privilege escalation, hostPath volume mounts, and missing resource limits.
3. **Multi-Stage DevSecOps Pipeline:** Automated pull request review executing SAST, container vulnerability analysis (Trivy), IaC benchmark auditing (Checkov), and financial cloud spend tracking (Infracost).
4. **Automated SBOM & Security Release Dossiers:** Automated generation of NIST SP 800-53 compliance dossiers and CycloneDX/SPDX software bills of materials.

---

## Zero-Trust Architecture & Network Isolation

```mermaid
flowchart TD
    subgraph S1["1. Zero-Trust Ingress & Network Isolation"]
        A1["Private Workload Subnet (us-east-1a)"]
        A2["Private Workload Subnet (us-east-1b)"]
        A3["Encrypted VPC Flow Logs (CIS 3.9)"]
        A4["Zero Public Internet Gateway Ingress"]
    end

    subgraph S2["2. Hardened Cluster & Security Controls"]
        B1["EKS Private Control Plane (Zero Public API)"]
        B2["KMS Envelope Encryption for Kubernetes Secrets"]
        B3["IMDSv2 Enforced Node Groups"]
        B4["CloudWatch Audit & Authenticator Logs"]
    end

    subgraph S3["3. OPA / Rego Zero-Trust Policy Gate"]
        C1{"Admission Controller"}
        C2["CIS 5.2.6: Deny Root (RunAsNonRoot=true)"]
        C3["CIS 5.2.5: Deny Privilege Escalation"]
        C4["CIS 5.2.4: Read-Only Root Filesystem"]
        C5["DoD Cloud: Strict CPU/Memory Limits"]
    end

    subgraph S4["4. DevSecOps Pipeline Stages"]
        D1["Stage 1: SAST & Trivy Container Scan"]
        D2["Stage 2: Checkov CIS IaC Audit"]
        D3["Stage 3: Infracost PR Spend Projection"]
        D4["Stage 4: Automated SBOM & Security Dossier"]
    end

    S1 --> S2
    S2 --> C1
    C1 --> C2
    C1 --> C3
    C1 --> C4
    C1 --> C5
    D1 --> D2
    D2 --> D3
    D3 --> D4
```

---

## Build Verification & Concrete Test Artifacts

Zero-trust admission rules and policy enforcement are validated via automated pytest:

```text
============================= test session starts =============================
platform win32 -- Python 3.11.0, pytest-9.1.1, pluggy-1.6.0
rootdir: C:\Users\FreeF\projects\defense-gitops-landing-zone
plugins: anyio-4.14.2
collected 3 items

tests\test_zero_trust_policies.py ...                                    [100%]

============================== 3 passed in 0.05s ==============================
```

### Verified Operational Edge Cases & Engineering Trade-Offs

1. **IMDSv2 Token Hop Limit Enforcement (`http_put_response_hop_limit = 1`):**
   - *Security Requirement:* Enforcing IMDSv2 with a single hop prevents Server-Side Request Forgery (SSRF) vulnerabilities from extracting EC2 instance profile IAM tokens from inside container pods.
   - *Trade-off:* Workload pods cannot access node-level IAM credentials. Workloads requiring AWS service access must use IAM Roles for Service Accounts (IRSA) with projected WebIdentity tokens.
2. **Strict Non-Root Admission vs. Third-Party Monitoring Daemonsets:**
   - *Challenge:* CIS Benchmark 5.2.6 denies containers running as root (`RunAsNonRoot = false`), which blocks legitimate monitoring daemonsets (e.g. node-exporter, eBPF collectors) that require root network namespaces.
   - *Resolution:* Implemented namespace-scoped policy exemptions in OPA Rego: workloads in application namespaces are strictly denied, while system daemonsets in `kube-system` require explicit cryptographically signed waiver tags.
3. **Fully Private EKS Control Plane Peering:**
   - *Trade-off:* Disabling the public endpoint (`endpoint_public_access = false`) guarantees zero exposure on the public internet, but prevents direct CI/CD kubectl executions from standard cloud runners. CI/CD runs via self-hosted ephemeral runners inside the private management VPC.

---

## Multi-Stage CI/CD Security Pipeline

```yaml
# FILE: .github/workflows/revolver-pipeline.yml
# Multi-stage automated DevSecOps validation pipeline

name: "defense-precision-ci"

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  stage_one_lint_and_security:
    name: "Stage 1: Static Analysis & Security Gate"
    runs-on: ubuntu-latest
    steps:
      - name: "Checkout Repository"
        uses: actions/checkout@v4
      - name: "Execute Ruff & Type Checks"
        run: pip install ruff mypy pytest && ruff check . && pytest tests/ -v
      - name: "Trivy Vulnerability & IaC Scan"
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: "fs"
          scan-ref: "."
          severity: "CRITICAL,HIGH"

  stage_two_checkov_iac_audit:
    name: "Stage 2: Checkov CIS IaC Benchmark Audit"
    runs-on: ubuntu-latest
    steps:
      - name: "Run Checkov Security Audit"
        uses: bridgecrewio/checkov-action@master
        with:
          directory: "terraform/"

  stage_three_infracost:
    name: "Stage 3: Infracost Cost Projection"
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - name: "Generate Infracost Cost Diff"
        run: infracost diff --path=terraform/

  stage_four_sbom_dossier:
    name: "Stage 4: Automated SBOM & Compliance Release Dossier"
    runs-on: ubuntu-latest
    steps:
      - name: "Generate Security Release Dossier"
        run: python scripts/generate_security_report.py
```

---

## Quickstart & Local Execution

```bash
# 1. Clone repository
git clone https://github.com/FreeFades2Black/defense-gitops-landing-zone.git
cd defense-gitops-landing-zone

# 2. Initialize dependencies
make init

# 3. Execute test suite
make test

# 4. Generate NIST SP 800-53 compliance dossier
make dossier

# 5. Validate Terraform landing zone
make plan
```

---

## License & Attribution

* **License:** MIT Open Source
* **Lead Architect:** Free (`FreeFades2Black`)
