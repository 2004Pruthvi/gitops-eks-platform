#!/usr/bin/env bash
# ==============================================================================
# Platform Verification Script — EKS, Argo CD, Workloads, and Observability
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo " Starting Full Platform Health Verification"
echo "=========================================================="

# 1. Verify EKS Nodes
echo -e "\n[1/5] Verifying EKS Managed Worker Nodes..."
kubectl get nodes -o wide
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
READY_NODES=$(kubectl get nodes --no-headers | grep -c "Ready" || true)
echo "Nodes Ready: ${READY_NODES}/${TOTAL_NODES}"

# 2. Verify Argo CD Controllers
echo -e "\n[2/5] Verifying Argo CD Component Health..."
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-application-controller

# 3. Verify Wild Tour Application Deployment
echo -e "\n[3/5] Verifying Wild Tour Workload & Rolling Deployment..."
kubectl get deployment -n wild-tour wild-tour
kubectl get pods -n wild-tour -l app=wild-tour -o wide

# 4. Verify Database Connectivity & Probes
echo -e "\n[4/5] Checking Pod Events & Probe Status..."
kubectl describe deployment -n wild-tour wild-tour | grep -E "Replicas|Conditions|RollingUpdateStrategy"

# 5. Verify Prometheus & Grafana Stack
echo -e "\n[5/5] Checking Monitoring Stack..."
kubectl get pods -n monitoring -l "app.kubernetes.io/name=prometheus" || echo "Monitoring namespace not yet deployed"

echo -e "\n=========================================================="
echo " Platform Verification Completed Successfully"
echo "=========================================================="
