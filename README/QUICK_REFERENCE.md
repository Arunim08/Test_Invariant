# Quick Reference: 3-Repo Architecture

## At a Glance

```
Repo 1 (Apps)           Repo 2 (Build)           Repo 3 (ArgoCD)
├─ apps/               ├─ build/                ├─ argocd/
├─ K8s/                ├─ CI/CD Workflows       ├─ applications/
└─ Source code         └─ docker-compose.yaml   └─ K8s manifests

    push ─────→ triggers ─────→ triggers ─────→ auto-syncs
    code       build & push     update tags      to cluster
```

## What Each Repo Contains

| Repo | Contents | Purpose | Trigger |
|---|---|---|---|
| **Repo 1** | Apps + Dockerfiles + K8s refs | Source of truth for app code | Push to main |
| **Repo 2** | Build files + CI/CD + compose | Builds images & pushes | Dispatch from Repo 1 |
| **Repo 3** | ArgoCD configs + manifests | Deploys to cluster | Dispatch from Repo 2 |

## File Locations

### In Workspace
```
REPO_SPLIT_SETUP/
├── IMPLEMENTATION_GUIDE.md         ← Start here!
├── SECRETS_GUIDE.md                ← Configure secrets
├── setup-repos.sh                  ← Automated setup (optional)
├── repo1-apps-dockerfiles/
│   ├── .github/workflows/
│   │   └── build-trigger.yml       ← Triggers Repo 2
│   └── README.md
├── repo2-build/
│   ├── .github/workflows/
│   │   └── build-all-apps.yml      ← Builds & pushes
│   ├── docker-compose.yaml         ← Local testing
│   └── README.md
└── repo3-argocd/
    ├── .github/workflows/
    │   └── deploy-argocd.yml       ← Updates manifests
    └── README.md
```

## CI/CD Flow

### 1. Developer pushes to Repo 1
```
Developer:
  git push origin main (in Repo 1)
    ↓
GitHub Action: build-trigger.yml
  - Validates Dockerfiles
  - Notifies Repo 2 via workflow_dispatch
```

### 2. Repo 2 builds and pushes images
```
GitHub Action: build-all-apps.yml
  - Clones Repo 1
  - Builds all 10 Docker images (parallel)
  - Uploads image artifacts
    ↓
GitHub Action: push-images.yml (automatic)
  - Loads image artifacts
  - Pushes to Docker registry (docker.io/yourusername)
  - Tags: latest, git-sha
  - Notifies Repo 3 via workflow_dispatch
```

### 3. Repo 3 updates manifests and syncs
```
GitHub Action: deploy-argocd.yml
  - Receives image tag from Repo 2
  - Updates K8s manifests with new image tags
  - Commits & pushes changes
    ↓
ArgoCD detects commit
  - Syncs manifests to cluster
  - Pods roll out with new images
    ↓
kubectl get pods -n microapps
  All apps now running with new versions!
```

## Key Commands

### Local Testing (in Repo 2)
```bash
# Test single app
docker build -f ../repo1/apps/app-1-go-api/Dockerfile -t app-1 .
docker run -p 8080:8080 app-1

# Test all apps
docker-compose up
docker-compose down

# Test from Repo 1
docker build -f apps/app-4-py-api/Dockerfile -t app-4 ./apps/app-4-py-api
docker run -p 8080:8080 app-4
```

### Push to GitHub
```bash
# Repo 1
cd repo1-apps-dockerfiles
git push origin main

# Repo 2
cd ../repo2-build
git push origin main

# Repo 3
cd ../repo3-argocd
git push origin main
```

### Monitor Deployments
```bash
# Watch GitHub Actions
# Go to each repo → Actions → Select workflow

# Watch cluster (requires kubectl access)
kubectl get pods -n microapps -w
kubectl logs -n microapps -f deployment/app-1
kubectl describe pod <pod-name> -n microapps
```

## When to Use Each Repo

### Push code changes
- **Use Repo 1** - App source code, Dockerfiles
- Example: `apps/app-1-go-api/main.go`

### Update dependencies
- **Use Repo 2** - Build files
- Example: `build/app-4-py-api/requirements.txt`

### Change deployment config
- **Use Repo 3** - K8s manifests, ArgoCD configs
- Example: `k8s-manifests/app-1-deployment.yaml`

## Workflow Names for GitHub Actions

| Repo | Workflow | Triggered By |
|---|---|---|
| Repo 1 | `build-trigger.yml` | Push to main |
| Repo 2 | `build-all-apps.yml` | Dispatch from Repo 1 |
| Repo 2 | `push-images.yml` | build-all-apps success |
| Repo 3 | `deploy-argocd.yml` | Dispatch from Repo 2 |

## Image Naming Convention

All images follow this pattern:
```
{REGISTRY}/{REGISTRY_PATH}/{APP_NAME}:{TAG}

Example:
docker.io/yourusername/app-1:abc123def456
docker.io/yourusername/app-4:latest
```

## Secrets Required

### Repo 1
- `REPO_2_DISPATCH_TOKEN` - GitHub PAT
- `REPO_2_NAME` - yourusername/test-invariant-build

### Repo 2
- `DOCKER_*` - Docker registry credentials (8 secrets)
- `REPO_1_*` - Repo 1 access (2 secrets)
- `REPO_3_*` - Repo 3 dispatch (2 secrets)

### Repo 3
- `ARGOCD_*` - ArgoCD auth (2 secrets, optional)
- `GITHUB_*` - Git user info (2 secrets)

See `SECRETS_GUIDE.md` for complete details.

## Rollback Procedure

If deployment has issues:

```bash
# Option 1: Revert Repo 3 manifest commit
cd repo3-argocd
git revert HEAD
git push origin main
# ArgoCD auto-syncs to previous version

# Option 2: Manual ArgoCD revert
argocd app rollback microapps
```

## Adding New App

1. **In Repo 1**: Create `apps/app-11-*` with source + Dockerfile
2. **In Repo 2**: Create `build/app-11-*` with build files
3. **In Repo 3**: 
   - Create `k8s-manifests/app-11-deployment.yaml`
   - Update `applications/microapps-application.yaml`
4. **Push all repos** → Pipeline handles the rest

## Health Checks

```bash
# Check if image pushed correctly
docker pull yourusername/app-1:latest

# Check if pod is running
kubectl get pods -n microapps | grep app-1

# Check if app is healthy
kubectl exec -it <pod-name> -n microapps -- curl localhost:8080/health

# Check ArgoCD status
argocd app get microapps
```

## Common Issues & Fixes

| Issue | Check |
|---|---|
| Build fails | Check Repo 2 Actions logs, verify Docker secrets |
| Images don't push | Verify DOCKER_REGISTRY, DOCKER_USERNAME, DOCKER_PASSWORD |
| Repo 1 can't be cloned | Verify REPO_1_ACCESS_TOKEN if Repo 1 is private |
| Deployment doesn't happen | Check Repo 3 Actions logs, verify manifests were updated |
| Pods stay in Pending | Check cluster resources: `kubectl describe node` |

## Next Steps

1. ✅ Create 3 GitHub repos
2. ✅ Copy repo files using setup guide
3. ✅ Configure GitHub secrets (SECRETS_GUIDE.md)
4. ✅ Push all repos to GitHub
5. ✅ Make a test change in Repo 1
6. ✅ Watch Actions across all 3 repos
7. ✅ Verify pods update in cluster

---

**More details in IMPLEMENTATION_GUIDE.md**
