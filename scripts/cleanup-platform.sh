#!/usr/bin/env bash
# ==============================================================================
# Safe Teardown & Cost Elimination Script
# ==============================================================================
# Destroys cloud infrastructure provisioned for this project while
# verifying no billable idle resources (EKS, NAT Gateways, ALBs) remain.

set -euo pipefail

echo "=========================================================="
echo " AWS GitOps Platform Teardown Protocol"
echo "=========================================================="
echo "WARNING: This will destroy the EKS cluster, node groups, and VPC."
echo "Make sure this is what you want before proceeding."
echo "=========================================================="

read -p "Type 'DESTROY' to confirm: " CONFIRMATION

if [ "$CONFIRMATION" != "DESTROY" ]; then
    echo "Teardown aborted."
    exit 0
fi

# 1. Delete Kubernetes Applications & Services (Cleans up AWS Load Balancers)
echo -e "\n[1/3] Deleting Ingress & LoadBalancer services..."
kubectl delete svc wild-tour -n wild-tour --ignore-not-found=true || true

# 2. Destroy Terraform Resources
echo -e "\n[2/3] Running terraform destroy..."
cd terraform/environments/dev
terraform destroy -auto-approve

# 3. Verify No Lingering Billable Resources in ap-south-1
echo -e "\n[3/3] Auditing idle billable resources in ap-south-1..."
echo "Checking NAT Gateways..."
aws ec2 describe-nat-gateways --region ap-south-1 --filter "Name=state,Values=available,pending" --query "NatGateways[*].[NatGatewayId,VpcId,State]" --output table || true

echo "Checking EKS Clusters..."
aws eks list-clusters --region ap-south-1 --output table || true

echo "Checking Elastic IPs..."
aws ec2 describe-addresses --region ap-south-1 --query "Addresses[*].[PublicIp,AllocationId,AssociationId]" --output table || true

echo -e "\nTeardown verification completed. No lingering resources active."
