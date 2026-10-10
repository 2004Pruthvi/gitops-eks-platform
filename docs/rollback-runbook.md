# SRE Operational Runbook: GitOps Rollback & Drift Remediation

---

## 🎯 The Core GitOps Principle: Why `kubectl rollout undo` Fails

In traditional DevOps, an engineer might run:
```bash
# DO NOT RUN THIS IN A GITOPS ENVIRONMENT
kubectl rollout undo deployment/wild-tour -n wild-tour
```

### Why this causes an outage loop in GitOps:
1. `kubectl rollout undo` changes the live state in the EKS cluster.
2. Argo CD continuously monitors both Git (the desired state) and the cluster (the live state).
3. Argo CD detects that the cluster state has **drifted** away from what is committed in Git!
4. If **Self-Healing** is enabled (standard in production), Argo CD will immediately **overwrite** your rollback and force the cluster back to the bad version committed in Git within seconds!

> **Golden Rule of GitOps**: The single source of truth is Git. To roll back an application, **you must roll back Git**.

---

## 🛠️ Step-by-Step Rollback Procedure

### Step 1: Identify the Failing Release
Check Argo CD sync status or pod events:
```bash
kubectl get pods -n wild-tour
# Look for ImagePullBackOff, CrashLoopBackOff, or failed Readiness probes
```

### Step 2: Locate the Bad Release Commit
Inspect recent Git history:
```bash
git log -n 5 --oneline
```
Example output:
```text
a1b2c3d chore(gitops): release image tag broken-v2 [skip ci]  <-- Bad Commit
fbf279d feat(release): release image tag v1.0.0 [skip ci]     <-- Known-Good Commit
```

### Step 3: Execute the Git Revert
Revert the bad commit:
```bash
# Revert the latest commit
git revert HEAD --no-edit

# Push the revert to origin main
git push origin main
```

### Step 4: Verify Argo CD Synchronization
1. Argo CD immediately detects the new commit containing the previous known-good tag.
2. Argo CD performs a rolling update back to the stable image.
3. Verify cluster health:
```bash
kubectl rollout status deployment/wild-tour -n wild-tour
kubectl get pods -n wild-tour
```

---

## 🔄 Self-Healing & Drift Correction Demonstration

To demonstrate GitOps self-healing in an interview or demo:
1. Manually tamper with the cluster:
   ```bash
   kubectl scale deployment wild-tour -n wild-tour --replicas=10
   ```
2. Watch Argo CD: Within 60 seconds (or immediately on manual sync), Argo CD flags the deployment as `OutOfSync`, marks the drift, and automatically scales the replicas back to `2` to match `values-dev.yaml`.
