# Pipeline Setup Checklist

Follow these steps to complete your automated deployment pipeline setup:

## Step 1: Docker Hub Credentials ⭐ **REQUIRED**

1. **Create Docker Hub Personal Access Token:**
   - Go to https://hub.docker.com/settings/security
   - Click **New Access Token**
   - Name it: `GitHub-Actions`
   - Select scope: **Read, Write**
   - Create and copy token (you won't see it again!)

2. **Add GitHub Secrets:**
   - Go to: https://github.com/Arunim08/Test_Invariant/settings/secrets/actions
   - Click **New repository secret**
   - Secret 1:
     - Name: `DOCKER_USERNAME`
     - Value: `arunxim` (your Docker Hub username)
   - Secret 2:
     - Name: `DOCKER_PASSWORD`
     - Value: `[paste your PAT from step 1]`

3. **Verify:**
   ```bash
   # Try logging in to Docker Hub locally
   docker login -u arunxim -p [PAT]
   # Should output: Login Succeeded
   ```

## Step 2: Git Configuration ✓ (Already Done)

Your repository is already set up with:
- ✅ `.github/workflows/build-deploy.yml` - CI/CD pipeline
- ✅ `K8s/argocd/application.yaml` - ArgoCD configuration
- ✅ `K8s/kustomization.yaml` - Kubernetes deployment manifest
- ✅ `AUTOMATION.md` - Detailed workflow documentation
- ✅ `release.sh` - Release helper script

## Step 3: Test the Pipeline 🧪

### Option A: Test with automatic build (push to main)

```bash
# Make a small change to test
echo "# Test" >> README.md

# Commit and push
git add README.md
git commit -m "test: verify pipeline"
git push origin main

# Watch the action
# https://github.com/Arunim08/Test_Invariant/actions
```

### Option B: Test with a release tag

```bash
# Create a test release
git tag -a v0.1.0 -m "Test release"
git push origin v0.1.0

# Watch the action
# https://github.com/Arunim08/Test_Invariant/actions
```

## Step 4: Monitor Deployments 📊

### Check GitHub Actions
```bash
# Open in browser
https://github.com/Arunim08/Test_Invariant/actions
```

### Check Docker Hub
```bash
# See your images pushed
https://hub.docker.com/r/arunxim/springboot-frontend/tags
```

### Check Kubernetes
```bash
# See deployment status
kubectl get deployment springboot-demo -n springboot-demo

# Get current image
kubectl get deployment springboot-demo -n springboot-demo \
  -o jsonpath='{.spec.template.spec.containers[0].image}'

# Watch rollout progress
kubectl rollout status deployment/springboot-demo -n springboot-demo

# View logs
kubectl logs -f deployment/springboot-demo -n springboot-demo -c springboot
```

### Check ArgoCD
```bash
# Port forward to ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:443 &

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Access: https://localhost:8080
# Username: admin
# Password: [from above command]
```

## Step 5: Create Your First Release 🚀

After testing the pipeline:

```bash
# Make your feature changes
# ... edit frontend/ or src/ ...

# Commit changes
git add .
git commit -m "feat: add new feature"
git push origin main

# Wait for GitHub Actions to pass

# Create release tag
./release.sh

# When prompted:
# Enter version tag: v1.0.0
# Enter release notes: Initial release
# Confirm: y

# Pipeline will:
# 1. Build Docker image
# 2. Tag as v1.0.0
# 3. Push to Docker Hub
# 4. Update deployment.yaml
# 5. ArgoCD syncs to Kubernetes
```

## Troubleshooting

### Workflow: "docker: command not found"
- You haven't set `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets
- Create them in: https://github.com/Arunim08/Test_Invariant/settings/secrets/actions

### Workflow: "Failed to authenticate to Docker Hub"
- Credentials in secrets are wrong
- Use Personal Access Token (PAT), NOT your password
- Create PAT: https://hub.docker.com/settings/security

### Workflow: "sed: can't read K8s/base/deployment.yaml"
- The workflow runs from repository root, paths are correct
- Check workflow logs for details

### Pod not updating after deployment.yaml change
- Check ArgoCD Application status
- Manual sync: `argocd app sync springboot-demo-app`
- Or click **SYNC** in ArgoCD UI

### Image not pulling from Docker Hub
- Verify image was pushed: `docker pull arunxim/springboot-frontend:v1.0.0`
- Check image visibility: https://hub.docker.com/r/arunxim/springboot-frontend
- If private, configure imagePullSecrets in K8s/base/deployment.yaml

## Complete Workflow Summary

```
Developer makes changes (frontend/src)
           ↓
git push origin main
           ↓
GitHub Actions triggers:
  ├─ Build Docker image from Dockerfile
  ├─ Tag image with commit SHA (e.g., commit-abc1234d)
  ├─ Push to Docker Hub (arunxim/springboot-frontend:commit-abc1234d)
  ├─ Update K8s/base/deployment.yaml with new image tag
  ├─ Commit & push deployment.yaml changes
           ↓
ArgoCD detects changes in K8s/:
  ├─ Compares cluster state vs repo state
  ├─ Finds new image tag in deployment.yaml
  ├─ Creates new ReplicaSet with new pod
  ├─ Performs rolling update (old pods → new pods)
  ├─ Health checks pass
           ↓
New version deployed to Kubernetes ✓
```

## Reference

- **Workflow file:** `.github/workflows/build-deploy.yml`
- **ArgoCD config:** `K8s/argocd/application.yaml`
- **Deployment config:** `K8s/base/deployment.yaml` (gets updated automatically)
- **Documentation:** `AUTOMATION.md`
- **Release script:** `release.sh`

## Need Help?

1. Read `AUTOMATION.md` for detailed workflow documentation
2. Check GitHub Actions logs: https://github.com/Arunim08/Test_Invariant/actions
3. View ArgoCD UI for deployment status
4. Check Kubernetes events: `kubectl describe deployment springboot-demo -n springboot-demo`
