# Architecture and System Design Documentation

---

## 1. Executive Summary

The **GitOps EKS Platform** is an enterprise-grade cloud-native infrastructure and application delivery platform built on Amazon Web Services (AWS) using Amazon Elastic Kubernetes Service (EKS).

The platform enforces strict separation of concerns across infrastructure management, continuous integration, declarative GitOps continuous delivery, and full-stack observability.

---

## 2. End-to-End Delivery Flow

```
1. Developer pushes code to GitHub ('main' branch)
   │
   ▼
2. GitHub Webhook triggers Jenkins CI Pipeline
   │
   ├─► Maven compiles Java 17 source & runs automated JUnit tests
   ├─► Hardened multi-stage Docker image built under non-root UID 999
   ├─► Trivy scans container image for vulnerabilities (HIGH/CRITICAL)
   └─► Image tagged with immutable Git SHA (e.g., 'fbf279d-42') & pushed to Amazon ECR
   │
   ▼
3. Jenkins updates Helm values in GitOps Repository ('tag: fbf279d-42') [skip ci]
   │
   ▼
4. Argo CD detects GitOps commit via automated polling/webhook
   │
   ├─► Renders Helm chart templates into declarative Kubernetes manifests
   ├─► Compares cluster state (Live) against Git repository state (Target)
   └─► Reconciles drift & executes rolling update on Amazon EKS
   │
   ▼
5. Kubernetes conducts Zero-Downtime Rolling Update
   │
   ├─► Launches new Pod with readiness probe checks ('/Wild_Tour/Home.jsp')
   ├─► Passes health checks -> shifts traffic -> terminates old Pods
   └─► Connects securely to Amazon RDS MySQL on private database subnets
   │
   ▼
6. Observability Stack (kube-prometheus-stack)
   │
   ├─► Prometheus scrapes cluster metrics, pod restarts, and resource usage
   ├─► Grafana visualizes real-time platform health dashboards
   └─► Alertmanager fires actionable alerts to Slack/Email on anomalies
```

---

## 3. Separation of Responsibilities

| Component | Responsibility | What It Must NEVER Do |
| :--- | :--- | :--- |
| **Terraform (IaC)** | Provisions and manages foundational cloud infrastructure (VPC, EKS, IAM, Security Groups). | Must **never** continuously deploy application releases or manage container image rollouts. |
| **Jenkins (CI)** | Code compilation, unit tests, code quality, container builds, Trivy CVE scanning, ECR publication, and GitOps manifest updates. | Must **never** execute `kubectl apply` or `helm upgrade` directly against the cluster. |
| **GitOps Repo** | Single source of truth for desired state (Helm values, replica counts, probes). | Must **never** contain plain-text passwords or secret credentials. |
| **Argo CD (CD)** | Continuously reconciles live cluster state with the GitOps desired state. | Does not build images; strictly continuous delivery and self-healing. |
| **Kubernetes (EKS)** | Orchestrates container execution, rolling updates, auto-healing, and networking. | Does not store infrastructure definitions outside of declarative manifests. |

---

## 4. Network and Security Architecture

1. **VPC Topology (ap-south-1)**:
   * **Public Subnets**: Ingress load balancers and NAT Gateways.
   * **Private Subnets**: EKS managed worker nodes; no public IPv4 addresses assigned.
   * **Database Subnets**: Dedicated subnets for Amazon RDS MySQL; strictly isolated.
2. **Container Security**:
   * Multi-stage build running under system user `tomcat:tomcat` (UID 999).
   * Kubernetes securityContext: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`.
3. **Database Isolation**:
   * Amazon RDS `publicly_accessible = false`.
   * Security group allows port 3306 ingress **only** from worker node security group.
