# 🚀 Automated Pipeline Deployment Guide

Your complete CI/CD pipeline is now ready! Here's what's been set up:

## What You Have

✅ **GitHub Actions Workflow** (`.github/workflows/build-deploy.yml`)
- Automatically builds Docker images on push to main
- Pushes images to Docker Hub with semantic versioning
- Updates Kubernetes deployment manifests
- Works with git tags for releases

✅ **ArgoCD Integration** (already configured)
- Auto-syncs deployments from your GitHub repo
- Applies changes to Kubernetes automatically
- Has retry logic for reliability

✅ **Kubernetes Configuration** (already deployed)
- Deployment configured and running
- ConfigMap management working
- Service and health probes in place

## ONE-TIME SETUP (5 minutes)

### 1️⃣ Create Docker Hub Personal Access Token

Go to: https://hub.docker.com/settings/security

```
1. Click "New Access Token"
2. Name: GitHub-Actions
3. Scope: Read, Write
4. Copy the token (save it!)
```

### 2️⃣ Add GitHub Secrets

Go to: https://github.com/Arunim08/Test_Invariant/settings/secrets/actions

**Secret 1:**
- Name: `DOCKER_USERNAME`
- Value: `arunxim`

**Secret 2:**
- Name: `DOCKER_PASSWORD`
- Value: `[paste token from step 1]`

### 3️⃣ Verify Git Push Worked

The pipeline files were just committed. Check:

```bash
# In VS Code terminal
cd c:\Users\ARUNIM\Documents\GitHub\Test_Invariant

# Verify files are in repo
git log --oneline -5

# You should see:
# ad844b9 feat: add automated CI/CD pipeline with GitHub Actions and ArgoCD
```

## HOW TO USE

### For Regular Development

```bash
# 1. Make changes to frontend or backend
# Edit files in frontend/ or src/

# 2. Commit and push
git add .
git commit -m "feat: add new feature"
git push origin main

# ✨ Magic happens:
# - GitHub Actions builds image
# - Pushes to Docker Hub
# - Updates deployment manifest
# - ArgoCD deploys to Kubernetes
```

**Check progress:**
- GitHub Actions: https://github.com/Arunim08/Test_Invariant/actions
- Docker Hub: https://hub.docker.com/r/arunxim/springboot-frontend

### For Releases

```bash
# 1. Make your changes and push to main as usual

# 2. Create a release
cd c:\Users\ARUNIM\Documents\GitHub\Test_Invariant
./release.sh

# Follow prompts:
# Enter version tag: v1.0.0
# Enter release notes: Initial stable release
# Confirm: y

# ✨ This creates a tagged release:
# - Image tagged as arunxim/springboot-frontend:v1.0.0
# - Also tagged as latest
# - GitHub Release created
# - ArgoCD deploys v1.0.0 to cluster
```

## VERIFY IT'S WORKING

### Check Kubernetes
```bash
# See running pods
kubectl get pod -n springboot-demo

# Check deployment image
kubectl get deployment springboot-demo -n springboot-demo \
  -o jsonpath='{.spec.template.spec.containers[0].image}'

# Watch logs
kubectl logs -f deployment/springboot-demo -n springboot-demo -c springboot
```

### Check ArgoCD
```bash
# Port forward to UI
kubectl port-forward -n argocd svc/argocd-server 8080:443 &

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo  # newline

# Visit: https://localhost:8080
# Login: admin / [password from above]

# Look for "springboot-demo-app" application
# Should show "Synced" status
```

## PIPELINE FLOW

```
Your Code → GitHub Push
       ↓
GitHub Actions (automated)
├─ Build Docker image
├─ Push to Docker Hub
├─ Update K8s deployment
├─ Commit to main
       ↓
ArgoCD (automated)
├─ Detect changes in K8s/
├─ Compare with cluster
├─ Apply new deployment
       ↓
Kubernetes (automated)
├─ Pull new image
├─ Create new pods
├─ Health checks pass
├─ Ready to serve ✓
```

## IMAGE TAG EXAMPLES

| Scenario | Image Tag | Use Case |
|----------|-----------|----------|
| Push to main | `commit-abc1234d` | Development |
| Create tag v1.0.0 | `v1.0.0` + `latest` | Production Release |
| Manual dispatch | Custom tag | Hotfix/One-off |

## IMPORTANT FILES

| File | Purpose |
|------|---------|
| `.github/workflows/build-deploy.yml` | CI/CD pipeline automation |
| `K8s/base/deployment.yaml` | Gets updated with new image tags |
| `K8s/argocd/application.yaml` | ArgoCD configuration |
| `SETUP.md` | Detailed setup instructions |
| `AUTOMATION.md` | Detailed workflow documentation |
| `release.sh` | Helper script for releases |

## NEXT STEPS

1. **Complete One-Time Setup** (above)
2. **Test the pipeline** (make a small commit)
3. **Create a release** (use `./release.sh` or `git tag`)
4. **Monitor** via GitHub Actions, Docker Hub, ArgoCD

## TROUBLESHOOTING

### Workflow shows error "docker: command not found"
- ❌ Missing Docker Hub credentials
- ✅ Add `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets
- ✅ Use Personal Access Token, NOT password

### Image not pushing to Docker Hub
- ❌ Docker Hub is private or credentials wrong
- ✅ Verify credentials work: `docker login -u arunxim`
- ✅ Check token scope includes "Write"

### Pod not updating after push
- ❌ ArgoCD not syncing
- ✅ Manual sync: Go to ArgoCD UI → Click "SYNC"
- ✅ Or run: `kubectl apply -k K8s/`

### Deployment stuck in `CreateContainerConfigError`
- ❌ Image pull failed or ConfigMap missing
- ✅ Check image exists: `docker pull arunxim/springboot-frontend:TAG`
- ✅ Check ConfigMap: `kubectl get configmap -n springboot-demo`

## MONITORING COMMANDS

```bash
# Watch live logs
kubectl logs -f deployment/springboot-demo -n springboot-demo -c springboot

# Check rollout status
kubectl rollout status deployment/springboot-demo -n springboot-demo

# See all versions deployed
kubectl rollout history deployment/springboot-demo -n springboot-demo

# Check recent events
kubectl describe deployment springboot-demo -n springboot-demo | tail -20

# See pod status
kubectl get pod -n springboot-demo -o wide

# Check resource usage
kubectl top pod -n springboot-demo

# Access pod shell (if needed for debugging)
kubectl exec -it deployment/springboot-demo -n springboot-demo -c springboot -- /bin/bash
```

## QUESTIONS?

- Read `SETUP.md` for detailed instructions
- Read `AUTOMATION.md` for workflow details
- Check workflow logs: https://github.com/Arunim08/Test_Invariant/actions
- Check ArgoCD logs: https://localhost:8080 (after port-forward)

---

**Ready to test?** 🎯

The simplest test:
```bash
cd c:\Users\ARUNIM\Documents\GitHub\Test_Invariant

# Add Docker Hub secrets to GitHub first (above)

# Then make a tiny change and push
echo "# Test pipeline" >> README.md
git add README.md
git commit -m "test: pipeline verification"
git push origin main

# Watch the action: https://github.com/Arunim08/Test_Invariant/actions
```

Good luck! 🚀
