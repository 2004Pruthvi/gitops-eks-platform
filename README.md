# Full GitOps EKS Platform — Flagship Platform Engineering Project

An enterprise-grade, portfolio-quality GitOps platform on Amazon Web Services (AWS) using Amazon EKS, Terraform, Jenkins, Helm, Argo CD, and the kube-prometheus-stack.

---

## 🏛️ Architecture Overview

The platform implements an automated GitOps delivery workflow:

```
Infrastructure as Code (Terraform)
       ↓
CI Pipeline (Jenkins) → Unit Tests & Code Quality
       ↓
Vulnerability Scan (Trivy)
       ↓
Container Registry (Amazon ECR)
       ↓
GitOps Desired State Update (Git Commit)
       ↓
Argo CD Synchronization & Self-Healing
       ↓
Kubernetes (Amazon EKS) Rolling Deployment & Health Probes
       ↓
Observability (Prometheus, Grafana & Alertmanager)
```

---

## 📁 Repository Structure

```text
gitops-eks-platform/
├── terraform/                   # Infrastructure as Code (VPC, EKS, IAM, Security Groups)
│   ├── modules/
│   │   ├── vpc/
│   │   ├── eks/
│   │   └── iam/
│   └── environments/dev/
├── application/                 # Java 17 web application source & Maven build
│   ├── src/
│   ├── pom.xml
│   └── wildlife.sql
├── Dockerfile                   # Hardened multi-stage non-root container image
├── jenkins/                     # Jenkins CI declarative pipeline
│   └── Jenkinsfile
├── helm/                        # Helm chart for application deployment
│   └── wild-tour/
├── gitops/                      # Argo CD application definitions & environment states
├── observability/               # Monitoring rules, dashboards, Alertmanager configs
├── scripts/                     # Automation, validation, and disaster recovery scripts
└── docs/                        # Architecture diagrams, runbooks, and interview guides
```

---

## 🚀 Implementation Roadmap

- [x] **Phase 0**: Local toolchain inspection and AWS identity verification
- [x] **Phase 1**: Standalone GitOps repository setup and baseline structure
- [ ] **Phase 2**: Reusable Terraform modules & remote state (S3 + DynamoDB)
- [ ] **Phase 3**: AWS infrastructure provisioning (VPC, EKS, IAM)
- [ ] **Phase 4**: EKS cluster networking and security baseline
- [ ] **Phase 5**: Jenkins CI pipeline with unit testing & Trivy security gate
- [ ] **Phase 6**: Immutable container image publication to Amazon ECR
- [ ] **Phase 7**: Production Helm chart engineering
- [ ] **Phase 8**: Argo CD GitOps bootstrap & automated reconciliation
- [ ] **Phase 9**: Database integration & workload verification
- [ ] **Phase 10**: Observability deployment (`kube-prometheus-stack`)
- [ ] **Phase 11**: Alerting rules & controlled failure scenarios
- [ ] **Phase 12**: GitOps rollback & drift correction verification
- [ ] **Phase 13**: Measurable engineering outcomes (DORA metrics)
- [ ] **Phase 14**: Portfolio documentation & interview readiness
