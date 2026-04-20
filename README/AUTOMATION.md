# Automated Pipeline Guide

This project uses GitHub Actions + ArgoCD for Continuous Deployment. Here's how the pipeline works:

## How It Works

```
Your Changes (Frontend/Backend)
     ↓
Git Push to main
     ↓
GitHub Actions: Build & Push Docker Image
     ↓
GitHub Actions: Update deployment.yaml with new image tag
     ↓
Git Commit to main (triggers ArgoCD)
     ↓
ArgoCD: Detects changes in K8s/ directory
     ↓
Kubernetes: Rolls out new deployment
```

## Setup (One-time)

### 1. Configure Docker Hub Secrets

Add these secrets to your GitHub repository:
- Go to **Settings → Secrets and variables → Actions**
- Click **New repository secret**

Add:
- **Name:** `DOCKER_USERNAME` → Your Docker Hub username
- **Name:** `DOCKER_PASSWORD` → Your Docker Hub Personal Access Token (not password!)
  - [Create PAT](https://docs.docker.com/security/for-developers/access-tokens/) on Docker Hub

### 2. Verify ArgoCD is Configured

ArgoCD Application is already set up in `K8s/argocd/application.yaml`:
- ✅ Watches: `https://github.com/Arunim08/Test_Invariant.git` (main branch)
- ✅ Monitors: `K8s/` directory
- ✅ Auto-sync enabled: Yes

## Usage Workflows

### Scenario 1: Regular Development (Automatic)

1. **Make changes** to frontend or backend:
   ```bash
   # Edit files in frontend/ or src/
   ```

2. **Commit and push to main:**
   ```bash
   git add .
   git commit -m "feat: add new dashboard feature"
   git push origin main
   ```

3. **What happens automatically:**
   - ✅ GitHub Actions builds Docker image
   - ✅ Tags it as: `arunxim/springboot-frontend:commit-abc1234def`
   - ✅ Pushes to Docker Hub
   - ✅ Updates `K8s/base/deployment.yaml`
   - ✅ Commits back to GitHub
   - ✅ ArgoCD detects change and deploys within ~3 minutes

### Scenario 2: Release with Semantic Version

1. **Create a git tag** for official release:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. **What happens automatically:**
   - ✅ GitHub Actions builds Docker image
   - ✅ Tags it as: `arunxim/springboot-frontend:v1.0.0` AND `latest`
   - ✅ Pushes to Docker Hub
   - ✅ Updates `K8s/base/deployment.yaml` with `v1.0.0`
   - ✅ Creates GitHub Release with deployment info
   - ✅ ArgoCD deploys to cluster

### Scenario 3: Manual Trigger

If you need to manually trigger a build:

1. **Go to Actions tab** in GitHub
2. **Select "Build and Deploy" workflow**
3. **Click "Run workflow"**
4. **Optional:** Enter a custom version tag (e.g., `v1.2.3`)
5. Click **"Run workflow"**

## Verify it's Working

### Check GitHub Actions
```bash
# View workflow runs
# https://github.com/Arunim08/Test_Invariant/actions
```

### Check Docker Hub
```bash
# See your pushed images
# https://hub.docker.com/r/arunxim/springboot-frontend/tags
```

### Check ArgoCD
```bash
# Port forward to ArgoCD UI
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Access: https://localhost:8080
# Login: admin / (get password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Click on "springboot-demo-app" application
# Should show auto-sync status
```

### Check Kubernetes
```bash
# See the new deployment
kubectl rollout history deployment/springboot-demo -n springboot-demo

# Check image version
kubectl get deployment springboot-demo -n springboot-demo -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## Version Tag Formats

The pipeline uses these tags:

| Event | Image Tag | Example |
|-------|-----------|---------|
| Push to main | `commit-{SHA}` | `arunxim/springboot-frontend:commit-abc1234d` |
| Git tag v1.0.0 | `v1.0.0` + `latest` | `arunxim/springboot-frontend:v1.0.0` |
| Manual dispatch | Custom or commit SHA | `arunxim/springboot-frontend:v2.5.1` |

## How to Increment Versions

### Semantic Versioning (Recommended)
Use tags like: `v1.0.0`, `v1.0.1`, `v1.1.0`, `v2.0.0`

```bash
# After making features
git tag -a v1.1.0 -m "Add dashboard feature"
git push origin v1.1.0

# For bugfixes
git tag -a v1.0.1 -m "Fix login bug"
git push origin v1.0.1

# For major changes
git tag -a v2.0.0 -m "Redesign UI"
git push origin v2.0.0
```

## Troubleshooting

### Workflow Failed?
1. Check GitHub Actions logs: https://github.com/Arunim08/Test_Invariant/actions
2. Common issues:
   - ❌ `DOCKER_USERNAME` or `DOCKER_PASSWORD` not set → Add secrets
   - ❌ Docker Hub credentials wrong → Verify PAT, not password
   - ❌ Image already pushed → It will overwrite/latest tag

### Deployment Not Updating in Kubernetes?
1. Check ArgoCD Application status
2. Manually sync in ArgoCD UI: **SYNC** button
3. Or via CLI: `argocd app sync springboot-demo-app`

### Check what image is deployed
```bash
kubectl get deployment springboot-demo -n springboot-demo -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## File Locations

- **Workflow:** `.github/workflows/build-deploy.yml` (controls the pipeline)
- **Deployment:** `K8s/base/deployment.yaml` (watched by ArgoCD)
- **ArgoCD App:** `K8s/argocd/application.yaml` (defines what ArgoCD watches)
