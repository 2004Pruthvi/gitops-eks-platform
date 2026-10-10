#!/usr/bin/env bash
# ==============================================================================
# SRE Runbook Script: Injected Failure & GitOps Automated Rollback
# ==============================================================================
# This script simulates a bad release, observes readiness failure / drift,
# and executes a true GitOps rollback via 'git revert'.

set -euo pipefail

VALUES_FILE="helm/wild-tour/values-dev.yaml"
CURRENT_TAG=$(grep -E 'tag:' "$VALUES_FILE" | awk '{print $2}' | tr -d '"')

echo "=========================================================="
echo " Scenario 1: Simulating Failed Release (Invalid Image Tag)"
echo " Current Known-Good Tag: ${CURRENT_TAG}"
echo "=========================================================="

# 1. Inject Bad Image Tag
BAD_TAG="non-existent-broken-image-tag-999"
echo "Injecting failing image tag: ${BAD_TAG} into ${VALUES_FILE}..."
sed -i.bak -E "s/tag: .*/tag: \"${BAD_TAG}\"/" "$VALUES_FILE"
rm -f "${VALUES_FILE}.bak"

git add "$VALUES_FILE"
git commit -m "feat(release): inject broken release tag ${BAD_TAG} for test [skip ci]"
git push origin main

echo "Pushed failing release to GitOps repository."
echo "Argo CD will synchronize the state."
echo "Kubernetes Rolling Update will detect ImagePullBackOff / CrashLoopBackOff."
echo "Notice: Because maxUnavailable=0, the previous known-good pods remain healthy!"

echo -e "\n=========================================================="
echo " Scenario 2: GitOps Rollback (Revert to Known-Good State)"
echo "=========================================================="
read -p "Press ENTER to execute GitOps rollback via 'git revert'..."

# 2. Execute Rollback via Git Revert
git revert HEAD --no-edit
git push origin main

echo "Revert commit pushed to GitHub!"
echo "Argo CD automatically detects the revert and redeploys known-good tag: ${CURRENT_TAG}"
echo "Workload restored with zero downtime."
