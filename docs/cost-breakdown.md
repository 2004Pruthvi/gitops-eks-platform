# AWS Infrastructure Cost Estimation and Optimization Guide (ap-south-1)

---

## 1. Estimated Monthly Cost Breakdown

The following estimates represent running this platform in AWS Asia Pacific (Mumbai) `ap-south-1`:

| Component | AWS Resource | Monthly On-Demand Cost | Cost-Optimized Dev Cost | Notes / Trade-Offs |
| :--- | :--- | :--- | :--- | :--- |
| **EKS Control Plane** | Amazon EKS Cluster | ~$73.00 ($0.10/hr) | ~$73.00 ($0.10/hr) | Fixed AWS charge whenever cluster exists. |
| **NAT Gateway** | 1x NAT Gateway + EIP | ~$32.40 ($0.045/hr) | ~$32.40 ($0.045/hr) | **Optimization**: Single NAT in dev instead of Multi-AZ NAT (saves ~$32.40/mo). |
| **Worker Nodes (2x)** | 2x `t3.medium` EC2 | ~$60.00 ($0.0416/hr each) | **~$18.00** (Spot Instances) | **Optimization**: Spot capacity type gives ~70% cost reduction. |
| **Amazon RDS** | MySQL 8.4 `db.t3.micro` | ~$18.00 | **$0.00** (Free Tier Eligible) | Stop instance during idle periods. |
| **Amazon ECR** | Container Storage | ~$0.50 | ~$0.50 | Billed at $0.10/GB per month. |
| **EBS Volumes (gp3)** | 2x 20GB root + 30GB monitoring | ~$5.60 | ~$5.60 | Billed at $0.08/GB per month. |
| **Total Estimated** | | **~$189.50 / month** | **~$129.50 / month** | |

---

## 2. Key Platform Cost Optimization Strategies

1. **Spot Instances for Worker Nodes**:
   * Configured in Terraform via `capacity_type = "SPOT"`.
   * Saves up to 70-80% on compute without altering Kubernetes workload architecture.
2. **Single NAT Gateway for Non-Production**:
   * In production, high availability requires 1 NAT Gateway per Availability Zone.
   * For non-production environments, `enable_single_nat_gateway = true` cuts NAT costs in half.
3. **EKS Worker Node Auto-Scaling**:
   * Scale worker node groups to `desired_size = 0` during maintenance windows or idle periods.
4. **Automated Teardown**:
   * Execute `scripts/cleanup-platform.sh` when tearing down test environments to eliminate idle charges.
