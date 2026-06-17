# 3-Repo Split Implementation Guide

## Overview
This guide walks you through splitting the monorepo into 3 coordinated repositories that work together via CI/CD pipelines.

## Step-by-Step Implementation

### Step 1: Create Three GitHub Repositories

Create these three empty repositories on GitHub:
1. `test-invariant-apps` (or your preferred name)
2. `test-invariant-build` 
3. `test-invariant-argocd`

### Step 2: Prepare Your Local Environment

```bash
cd /path/to/workspace
# You'll split content from Test_Invariant into 3 repos
```

### Step 3: Split the Monorepo

#### Repo 1: test-invariant-apps
**Contains**: Apps with Dockerfiles + K8s manifests

```bash
# Create repo 1
mkdir repo1-apps-dockerfiles
cd repo1-apps-dockerfiles
git init
git remote add origin https://github.com/YOUR_USERNAME/test-invariant-apps.git

# Copy apps/ directory
cp -r ../Test_Invariant/apps ./

# Copy K8s manifests
mkdir K8s
cp -r ../Test_Invariant/K8s/app-* ./K8s/
cp ../Test_Invariant/K8s/kustomization.yaml ./K8s/
cp ../Test_Invariant/K8s/ingress.yaml ./K8s/
cp ../Test_Invariant/K8s/service-worker.yaml ./K8s/

# Add .github/workflows for build trigger
mkdir -p .github/workflows

# Copy the provided build-trigger.yml to .github/workflows/

# Commit and push
git add .
git commit -m "Initial: Apps and Dockerfiles"
git push -u origin main
```

#### Repo 2: test-invariant-build
**Contains**: Build files + CI/CD pipelines

```bash
cd ..
mkdir repo2-build
cd repo2-build
git init
git remote add origin https://github.com/YOUR_USERNAME/test-invariant-build.git

# Create build directory structure
mkdir -p build
cd build

# For each app, copy only build files (NOT Dockerfiles or source)
# Go apps: (empty, self-contained)
mkdir -p app-1-go-api && touch app-1-go-api/.buildkeep
mkdir -p app-2-go-worker && touch app-2-go-worker/.buildkeep
mkdir -p app-3-go-cache && touch app-3-go-cache/.buildkeep

# Python apps: copy requirements.txt and source
cp -r ../Test_Invariant/apps/app-4-py-api .
cp -r ../Test_Invariant/apps/app-5-py-service .
cp -r ../Test_Invariant/apps/app-6-py-monitor .

# Node apps: copy package.json and source
cp -r ../Test_Invariant/apps/app-7-node-web .
cp -r ../Test_Invariant/apps/app-8-node-api .
cp -r ../Test_Invariant/apps/app-9-node-worker .

# Java app: copy pom.xml and src
cp -r ../Test_Invariant/apps/app-10-java-service .

cd ..

# Add .github/workflows
mkdir -p .github/workflows

# Copy the provided build-all-apps.yml and push-images.yml to .github/workflows/

# Create docker-compose.yaml for local testing
# (See provided docker-compose.yaml)

# Commit and push
git add .
git commit -m "Initial: Build files and CI/CD"
git push -u origin main
```

#### Repo 3: test-invariant-argocd
**Contains**: ArgoCD configurations + deployment pipelines

```bash
cd ..
mkdir repo3-argocd
cd repo3-argocd
git init
git remote add origin https://github.com/YOUR_USERNAME/test-invariant-argocd.git

# Copy ArgoCD configurations
cp -r ../Test_Invariant/argocd ./

# Create applications directory
mkdir -p applications
cp ../Test_Invariant/K8s/argocd/microapps-application.yaml ./applications/

# Add .github/workflows for deployment
mkdir -p .github/workflows

# Copy the provided deploy-argocd.yml to .github/workflows/

# Create image-registry secret template
mkdir -p secrets

# Commit and push
git add .
git commit -m "Initial: ArgoCD configurations"
git push -u origin main
```

### Step 4: Configure GitHub Secrets

For each repository, add these secrets in Settings → Secrets and variables → Actions:

**All Repos:**
- `DOCKER_REGISTRY`: (e.g., `docker.io` for Docker Hub)
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub token/password
- `DOCKER_REGISTRY_PATH`: (e.g., `yourusername` for `yourusername/app-1`)

**Repo 2 (Build) - Additional:**
- `REPO_1_ACCESS_TOKEN`: Personal access token to clone Repo 1
- `REPO_3_DISPATCH_TOKEN`: Personal access token to trigger Repo 3 workflows

**Repo 3 (ArgoCD) - Additional:**
- `ARGOCD_SERVER`: Your ArgoCD server URL
- `ARGOCD_AUTH_TOKEN`: ArgoCD authentication token
- `KUBE_CONFIG`: Base64-encoded kubeconfig (if needed)

### Step 5: Update Image References

In **Repo 3**, update image references in `applications/microapps-application.yaml`:

```yaml
# Before:
image: docker.io/yourusername/app-1:latest

# After (with tag):
image: docker.io/yourusername/app-1:${{ github.sha }}
```

### Step 6: Test the Pipeline

1. **Push to Repo 1** (test an app change):
   ```bash
   cd repo1-apps-dockerfiles
   # Make a change
   git commit -am "Update app"
   git push origin main
   ```

2. **This triggers:** Repo 1 notifies Repo 2 via workflow dispatch
   
3. **Repo 2 starts build:**
   - Clones Repo 1
   - Builds Docker images
   - Pushes to registry
   - Dispatches Repo 3 workflow

4. **Repo 3 deploys:**
   - Updates image tags
   - Pushes changes
   - ArgoCD auto-syncs

5. **Monitor deployment:**
   ```bash
   kubectl get pods -n microapps -w
   kubectl rollout status deployment/app-1 -n microapps
   ```

## Workflow Diagrams

### Development Flow
```
Developer commits to Repo 1 (app code)
         ↓
GitHub Action in Repo 1 (optional - verify syntax)
         ↓
Repo 1 notifies Repo 2 via workflow_dispatch
         ↓
Repo 2 GitHub Action starts
  - Clones Repo 1
  - Builds all Docker images (matrix parallel)
  - Pushes to Docker registry
         ↓
Repo 2 notifies Repo 3 via workflow_dispatch
         ↓
Repo 3 GitHub Action starts
  - Updates image tags in K8s manifests
  - Commits & pushes changes
         ↓
ArgoCD detects changes in Repo 3
         ↓
ArgoCD syncs to cluster
         ↓
Cluster running with new images
```

### Emergency Rollback
```
Revert commit in Repo 2
         ↓
Repo 2 rebuilds previous images
         ↓
Repo 3 updates manifests
         ↓
ArgoCD auto-syncs to previous version
```

## Key Files in Each Repo

### Repo 1 (.github/workflows/build-trigger.yml)
- Triggered on: Changes to any app or Dockerfile
- Does: Validates Dockerfile syntax, optionally builds locally
- Then: Calls Repo 2 workflow

### Repo 2 (.github/workflows/build-all-apps.yml)
- Triggered on: Repository dispatch or push to main
- Does: Builds all Docker images in parallel
- Stores: Images in Docker registry

### Repo 2 (.github/workflows/push-images.yml)
- Triggered on: Successful build
- Does: Pushes built images to registry
- Then: Dispatches Repo 3 workflow

### Repo 3 (.github/workflows/deploy-argocd.yml)
- Triggered on: Repository dispatch from Repo 2
- Does: Updates image tags in manifests
- Then: Commits & pushes to trigger ArgoCD sync

## Common Tasks

### Add a New App
1. Create `apps/app-11-*` in Repo 1
2. Add build files to `build/app-11-*` in Repo 2
3. Add K8s manifest `K8s/app-11/deployment.yaml` in Repo 1
4. Add ArgoCD reference in Repo 3 (auto-picked by kustomization)

### Update Dependencies (Python, Node)
1. Update `requirements.txt` or `package.json` in Repo 2
2. Push to Repo 2 → Triggers build pipeline

### Emergency: Manual Deploy
```bash
# If pipelines fail, manually push images:
docker build -f apps/app-1-go-api/Dockerfile -t yourusername/app-1:manual .
docker push yourusername/app-1:manual

# Update manifest in Repo 3
# Commit & push to trigger ArgoCD sync
```

### Local Testing
```bash
# In Repo 2
docker-compose up

# Or in Repo 1
docker build -f apps/app-1-go-api/Dockerfile -t app-1:test .
docker run -p 8080:8080 app-1:test
```

## Monitoring

### Watch builds:
```bash
# In Repo 2
# Go to Actions tab in GitHub
```

### Watch deployments:
```bash
# In Repo 3  
# Go to Actions tab in GitHub
```

### Check cluster:
```bash
kubectl get pods -n microapps -w
kubectl logs -n microapps -f deployment/app-1
```

## Troubleshooting

### Build fails in Repo 2
1. Check GitHub Actions logs
2. Verify Repo 1 is public or access token is correct
3. Check Docker registry credentials

### Deployment fails in Repo 3
1. Check ArgoCD logs: `kubectl logs -n argocd deployment/argocd-server`
2. Verify image tags are correct in manifests
3. Check ArgoCD Application status: `argocd app get microapps`

### Repo 2 can't clone Repo 1
1. Generate GitHub Personal Access Token (PAT) with `repo` scope
2. Add as `REPO_1_ACCESS_TOKEN` secret in Repo 2
3. Update build-all-apps.yml to use token if needed

## Next Steps

1. ✅ Create the three GitHub repositories
2. ✅ Split content using the scripts above
3. ✅ Configure GitHub secrets
4. ✅ Test the pipeline with a small change
5. ✅ Monitor for 24 hours
6. ✅ Archive/delete the old monorepo once confident

---

**Need help?** Check the provided workflow files in each repo folder.
