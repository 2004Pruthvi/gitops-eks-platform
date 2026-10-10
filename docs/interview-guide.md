# Technical Interview Guide: Platform Engineering & GitOps on EKS

This guide prepares you to speak confidently about every architectural choice in this project during technical interviews for **Platform Engineer**, **DevOps Engineer**, **Cloud Engineer**, and **SRE** roles.

---

### Q1: Why use GitOps with Argo CD instead of having Jenkins run `kubectl apply` directly?

**Candidate Answer:**
> "In traditional CI/CD, the CI server (like Jenkins) requires administrative cluster credentials to run `kubectl apply`. This creates two major problems:
> 1. **Security Risk:** The CI server becomes a single point of failure with high-privilege access.
> 2. **Cluster Drift & Visibility:** If an engineer manually edits a cluster resource or a deployment fails midway, Jenkins doesn't know the live state.
> 
> With GitOps and Argo CD, we implement a **pull-based deployment model**. Jenkins only builds, tests, scans, and pushes the immutable container image, then commits the new image tag to Git. Argo CD runs **inside** the EKS cluster, pulls the desired state from Git, reconciles differences, and automatically corrects unauthorized configuration drift. Git becomes our auditable single source of truth."

---

### Q2: How did you implement zero-downtime rolling updates with Apache Tomcat on EKS?

**Candidate Answer:**
> "Tomcat applications have a JVM startup overhead. If Kubernetes immediately routes traffic to a newly created Tomcat pod before the Servlet context initializes, users receive 502/503 errors.
> To ensure zero downtime, I configured:
> 1. **RollingUpdate Strategy:** `maxSurge: 1` (spins up a new pod first) and `maxUnavailable: 0` (guarantees existing pods are not terminated until the new pod is confirmed ready).
> 2. **Readiness Probe:** An HTTP GET check targeting `/Wild_Tour/Home.jsp` with an `initialDelaySeconds: 45` and `periodSeconds: 10`. Kubernetes will not add the pod to the Service endpoint until the JSP responds with HTTP 200.
> 3. **Liveness Probe:** Periodically checks health to restart pods if Tomcat enters a deadlocked state."

---

### Q3: Why is `kubectl rollout undo` problematic in a GitOps environment, and how do you execute rollbacks?

**Candidate Answer:**
> "If you run `kubectl rollout undo` in a GitOps setup, you are changing the live cluster state without changing Git. Because Argo CD runs with **self-healing enabled**, it will immediately detect cluster drift and overwrite your manual rollback with the bad version committed in Git within 60 seconds.
> In a GitOps platform, rollback **must be executed in Git**. We run `git revert HEAD` and push the revert commit. Argo CD detects the revert, matches the desired state to the previous known-good image tag, and safely triggers a rolling update with zero downtime."

---

### Q4: How did you handle secrets securely without committing passwords to GitHub?

**Candidate Answer:**
> "I strictly adhered to the 12-factor application methodology:
> 1. **No secrets in Git or Helm values:** Database credentials (`DB_USER`, `DB_PASSWORD`) are never placed in `values.yaml`.
> 2. **Decoupled Injection:** The deployment manifest injects credentials via `secretKeyRef` pointing to a Kubernetes Secret named `wild-tour-db-secret`.
> 3. **In Production:** We leverage AWS Secrets Manager or HashiCorp Vault integrated with the Kubernetes External Secrets Operator (ESO) or AWS IAM Roles for Service Accounts (IRSA)."

---

### Q5: How did you optimize cloud infrastructure costs on AWS?

**Candidate Answer:**
> "EKS clusters can be expensive. In my Terraform design, I applied three cost optimizations without compromising architectural integrity:
> 1. **Spot Instances:** In the managed node group, I set `capacity_type = 'SPOT'`, which delivers up to 70% cost savings for compute.
> 2. **Single NAT Gateway for Dev:** In production, high availability demands one NAT Gateway per AZ. In development, I configured a single NAT Gateway shared across private subnets, cutting the NAT hourly fee in half.
> 3. **Resource Requests & Limits:** Tailored CPU/Memory requests so worker nodes can be packed efficiently with horizontal pod autoscaling rather than over-provisioning large instance families."
