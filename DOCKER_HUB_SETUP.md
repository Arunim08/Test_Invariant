# Docker Hub Repository Setup & Image Versioning

This guide explains how to set up Docker Hub repositories for the 10 microapps with proper semantic versioning and no "latest" tags.

## Quick Start: Create Repositories

### Manual Creation (UI Method)
1. Visit [Docker Hub](https://hub.docker.com)
2. Sign in with your account (`arunxim`)
3. Click **"Create Repository"** button
4. For each app (app-1 through app-10), create:
   - **Repository name**: `app-1`, `app-2`, ... `app-10`
   - **Visibility**: Public (or Private if needed)
   - **Description**: Brief app description (e.g., "Go API microservice", "Python monitoring service", etc.)
   - Click **Create**

### Example Repositories to Create:
```
arunxim/app-1        → Go API
arunxim/app-2        → Go Worker
arunxim/app-3        → Go Cache
arunxim/app-4        → Python API
arunxim/app-5        → Python Service
arunxim/app-6        → Python Monitor
arunxim/app-7        → Node.js Web
arunxim/app-8        → Node.js API
arunxim/app-9        → Node.js Worker
arunxim/app-10       → Java Spring Boot Service
```

---

## Versioning Strategy

### No "Latest" Tag
- **Why**: Multiple versions running simultaneously in production
- **Benefit**: Explicit control over which version each service uses
- **Default**: Use commit SHA for development, semantic versions for releases

### Supported Version Formats

#### 1. **Commit-based (Default, Automatic)**
```
commit-a1b2c3d4
```
- Auto-generated on every push
- Each commit produces a unique image version
- Used for: Development, testing, continuous deployment
- Format: `commit-{SHORT_SHA}` (first 8 characters)

#### 2. **Semantic Versioning (Manual, Release)**
```
v1.0.0
v1.1.0
v2.0.0-alpha
v1.2.3-beta1
```
- Created via GitHub workflow dispatch or git tags
- Used for: Production releases, milestone versions
- Format: Follow [semver.org](https://semver.org) convention

#### 3. **Version-only Format (Production)**
```
1.0.0
1.1.0
2.0.0
```
- Recommended for K8s deployments
- Explicit, clean versioning
- Used for: Multi-replica deployments needing consistency

---

## How Versioning Works

### Automatic Version Detection

The GitHub Actions workflow determines version priority:

```
1. Manual Input (Highest Priority)
   └─ Via workflow_dispatch with version input
   └─ Example: Manually trigger with version "v1.2.3"

2. Git Tag
   └─ git tag v1.0.0 && git push --tags
   └─ Auto-builds all apps with version "v1.0.0"

3. Commit SHA (Default)
   └─ Automatic on every git push
   └─ Format: commit-{GITHUB_SHA:8}
   └─ Example: commit-a1b2c3d4
```

### Current Images

As of last deployment:
```
✓ arunxim/app-1:commit-1f32f51
✓ arunxim/app-2:commit-1f32f51
✓ arunxim/app-3:commit-1f32f51
✓ arunxim/app-4:commit-1f32f51
✓ arunxim/app-5:commit-1f32f51
✓ arunxim/app-6:commit-1f32f51
✓ arunxim/app-7:commit-1f32f51
✓ arunxim/app-8:commit-1f32f51
✓ arunxim/app-9:commit-1f32f51
✓ arunxim/app-10:commit-1f32f51
```

---

## Publishing Versions

### Option 1: Development Release (Automatic)
**Trigger**: Normal `git push` to main branch
```bash
git add .
git commit -m "chore: update app configurations"
git push origin main
# Automatically builds with: commit-{LATEST_SHA}
```

### Option 2: Manual Version via Workflow Dispatch
**Trigger**: GitHub Actions UI manual run
1. Go to GitHub → Actions → "Build and Deploy Multi-Apps"
2. Click "Run workflow" dropdown
3. Enter version: `v1.0.0` (or `1.0.0`)
4. Click "Run workflow"

All 10 apps build with that version:
```
✓ arunxim/app-1:v1.0.0
✓ arunxim/app-2:v1.0.0
... (all 10 apps)
```

### Option 3: Release Version via Git Tag
**Trigger**: Create and push git tag
```bash
# Create tag at current commit
git tag v1.0.0

# Push tag to GitHub (triggers workflow)
git push origin v1.0.0

# Or push all tags
git push origin --tags
```

Result:
- Creates GitHub Release
- Builds all 10 apps with version `v1.0.0`
- Release notes auto-populated with all 10 app images

---

## K8s Manifest Updates

### Manual Version Control

K8s manifests in `K8s/apps/` automatically updated by workflow when images change.

**Example manifest (K8s/apps/app-1.yaml):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-1
spec:
  template:
    spec:
      containers:
      - name: app-1
        image: arunxim/app-1:commit-1f32f51  # Auto-updated by workflow
```

### Manual Update (If Needed)

Update specific app version:
```bash
# Edit manifest directly
kubectl set image deployment/app-1 \
  -n microapps \
  app-1=arunxim/app-1:v1.0.0

# Or edit YAML file and apply
kubectl apply -f K8s/apps/app-1.yaml
```

---

## Versioning Examples

### Scenario 1: Daily Development
```
Days 1-5:
  commit-a1b2c3d4  → Development build
  commit-d5e6f7a8  → Bug fix
  commit-b9c0d1e2  → Feature update
  commit-f3a4b5c6  → Polish
  commit-c7d8e9f0  → Release candidate

Workflow: Push code → Auto-build → Auto-deploy via ArgoCD
```

### Scenario 2: Release Version
```
git tag v1.0.0
↓
Workflow triggers
↓
Releases:
  ✓ arunxim/app-1:v1.0.0
  ✓ arunxim/app-2:v1.0.0
  ... (10 total)
```

### Scenario 3: Production Rollback
```
Current deployment: app-1:v1.1.0
Issue detected
↓
Rollback:
  kubectl set image deployment/app-1 \
    -n microapps \
    app-1=arunxim/app-1:v1.0.0

OR update manifest:
  image: arunxim/app-1:v1.0.0
  ↓
  kubectl apply -f K8s/apps/app-1.yaml
  ↓
  ArgoCD auto-syncs to v1.0.0
```

---

## Version History & Cleanup

### View All Versions
```bash
# List tags via Docker Hub API
curl -s https://registry.hub.docker.com/v2/repositories/arunxim/app-1/tags \
  | jq '.results[].name' | head -20

# Or via Docker CLI (if logged in)
docker pull arunxim/app-1:commit-a1b2c3d4
docker images | grep app-1
```

### Keep Old Versions (Recommended)
```
✓ app-1:v1.0.0        (First release)
✓ app-1:v1.0.1        (Patch)
✓ app-1:v1.1.0        (Minor)
✓ app-1:commit-xxx    (Latest dev builds)
```

### Delete Old Versions (If Space Limited)
Via Docker Hub UI:
1. Repository → app-1 → Tags
2. Select old commits
3. Click Delete

---

## Workflow File Reference

**File**: `.github/workflows/build-deploy-apps.yml`

### Version Determination Logic
```bash
if [ workflow_dispatch AND version input provided ]; then
  VERSION = input_version
elif [ git tag exists ]; then
  VERSION = tag_name
else
  VERSION = "commit-${GITHUB_SHA::8}"
fi
```

### Images Tagged As
```
ONLY: arunxim/{app-name}:{VERSION}
NOT: arunxim/{app-name}:latest
```

### Auto-Update K8s Manifests
```
After successful build:
  K8s/apps/{app-name}.yaml
  └─ image: arunxim/{app-name}:{VERSION}
  └─ git commit with message
  └─ git push (triggers ArgoCD sync)
```

---

## Setup Checklist

- [ ] **Step 1**: Create 10 Docker Hub repositories (app-1 through app-10)
- [ ] **Step 2**: Verify Docker credentials in GitHub Secrets:
  - [ ] `DOCKER_USERNAME` = your Docker Hub username
  - [ ] `DOCKER_PASSWORD` = Docker Hub access token (or password)
- [ ] **Step 3**: Verify workflow file uses proper versioning:
  - [ ] Run workflow to confirm version strategy
  - [ ] Check no "latest" tags in images
- [ ] **Step 4**: Test version rollout:
  - [ ] Push code (auto-generates commit-XXXXX)
  - [ ] Manually run workflow with version v1.0.0
  - [ ] Verify all 10 app images tagged correctly
- [ ] **Step 5**: Keep versioning docs updated (this file)

---

## Troubleshooting

### Problem: Images Not Pushing to Docker Hub
```
Solution:
  1. Check DOCKER_USERNAME and DOCKER_PASSWORD secrets
  2. Verify Docker Hub credentials are valid
  3. Check repository exists: docker pull arunxim/app-1
```

### Problem: Version Not Applied to K8s
```
Solution:
  1. Check manifest file exists: K8s/apps/app-{N}.yaml
  2. Verify image line format: image: arunxim/app-{N}:VERSION
  3. Check ArgoCD is syncing (may need manual refresh)
```

### Problem: Can't Find Old Versions
```
Solution:
  1. Query Docker Hub: docker pull arunxim/app-1:commit-XXXXX
  2. Or check tags on Docker Hub UI
  3. Or query registry API:
     curl https://registry.hub.docker.com/v2/.../tags
```

---

## Clean Workflow Example

```bash
# Daily development work
git add .
git commit -m "feat: update app-1 logic"
git push origin main
# Automatically triggers build → creates commit-a1b2c3d4 → ArgoCD syncs

# When ready for release
git tag v1.0.0
git push origin v1.0.0
# Builds all 10 apps with v1.0.0 → Creates Release on GitHub

# To rollback or switch versions
kubectl set image deployment/app-1 \
  -n microapps \
  app-1=arunxim/app-1:v1.0.0
```

---

## Reference

- **Docker Hub Account**: https://hub.docker.com/u/arunxim
- **GitHub Repo**: https://github.com/Arunim08/Test_Invariant
- **Workflow**: `.github/workflows/build-deploy-apps.yml`
- **K8s Manifests**: `K8s/apps/`
- **Semantic Versioning**: https://semver.org
