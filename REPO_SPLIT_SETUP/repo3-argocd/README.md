# Repo 3: ArgoCD Configurations

## What Goes Here

This repo contains:
- `argocd/` - Complete ArgoCD installation and configurations
- `applications/` - ArgoCD Application manifests that define what to deploy
- `.github/workflows/` - Deployment pipeline (updates image tags, syncs with ArgoCD)

## Directory Structure

```
test-invariant-argocd/
├── argocd/
│   ├── application-controller/
│   ├── applicationset-controller/
│   ├── configmaps/
│   ├── crds/
│   ├── redis/
│   ├── repo-server/
│   ├── server/
│   ├── namespace-install.yaml
│   └── kustomization.yaml
├── applications/
│   ├── microapps-application.yaml
│   ├── kustomization.yaml
│   └── overlays/
│       └── production/
│           └── kustomization.yaml
├── k8s-manifests/
│   ├── app-1-deployment.yaml
│   ├── app-2-deployment.yaml
│   ├── ... (K8s manifests for all apps)
│   └── kustomization.yaml
├── secrets/
│   ├── docker-registry-secret-template.yaml
│   └── (other secrets templates)
├── .github/
│   └── workflows/
│       └── deploy-argocd.yml
└── README.md
```

## Key Points

- **Source of Truth** - Everything here is deployed via ArgoCD
- **GitOps** - Changes are auto-synced to cluster
- **Image Tags** - Updated by Repo 2's pipeline (via workflow dispatch)
- **Kustomization** - Uses kustomize for flexible overlays
- **ArgoCD Installation** - If not already in cluster, this provides full setup

## How It Connects

Repo 2 triggers this via `workflow_dispatch` with payload:
```json
{
  "registry": "docker.io",
  "registry_path": "yourusername",
  "image_tag": "abc123def456"
}
```

This repo's workflow:
1. Updates image tags in K8s manifests
2. Commits changes to this repo
3. ArgoCD detects the commit
4. ArgoCD auto-syncs to cluster
5. Cluster runs with new images

## Workflow Details

### deploy-argocd.yml
- Triggered by: Repository dispatch from Repo 2
- Payload: Image registry info, image tag (commit SHA)
- Steps:
  1. Read image tag from payload
  2. Update all K8s manifest image references
  3. Commit & push changes
  4. ArgoCD detects and auto-syncs (if configured)

## K8s Manifests

Each app needs a manifest in `k8s-manifests/`:

```yaml
# Example: app-1-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-1
  namespace: microapps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app-1
  template:
    metadata:
      labels:
        app: app-1
    spec:
      containers:
      - name: app-1
        image: docker.io/yourusername/app-1:REPLACE_IMAGE_TAG
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
```

The workflow replaces `REPLACE_IMAGE_TAG` with the actual commit SHA or git tag.

## Files to Create

- `.github/workflows/deploy-argocd.yml` - See provided file
- Update `applications/microapps-application.yaml` with image tags

## Environment Variables / Secrets Required

Add to GitHub Secrets in this repo:
- `ARGOCD_SERVER`: ArgoCD server URL (e.g., `argocd.example.com`)
- `ARGOCD_AUTH_TOKEN`: ArgoCD API token (create via `argocd account generate-token`)
- `GITHUB_EMAIL`: Git user email (for commits)
- `GITHUB_USERNAME`: Git user name (for commits)
- `GITHUB_TOKEN`: Already available (secrets.GITHUB_TOKEN)

## Commands

```bash
# Push to GitHub
git remote add origin https://github.com/YOUR_USERNAME/test-invariant-argocd
git add .
git commit -m "Initial commit: ArgoCD configs"
git push -u origin main

# Create ArgoCD API token
argocd account generate-token --account admin

# Add secret to repo
argocd app sync microapps  # Manual sync (if auto-sync disabled)
```

## Monitoring Deployments

```bash
# Watch ArgoCD
argocd app get microapps
argocd app wait microapps

# Watch cluster
kubectl get pods -n microapps -w
kubectl rollout status deployment/app-1 -n microapps

# View ArgoCD UI
# Go to: https://argocd.example.com
# Login with ArgoCD credentials
```

## Rollback Procedure

If deployment fails:
1. Check ArgoCD Application status
2. Manually revert last commit in this repo
3. ArgoCD will auto-sync to previous state

```bash
# From Git history
git revert HEAD
git push origin main
# ArgoCD syncs to previous version
```

## Adding New Apps

1. In **Repo 1**: Add `apps/app-11-*`
2. In **Repo 2**: Add `build/app-11-*` with build files
3. In **Repo 3**: Create `k8s-manifests/app-11-deployment.yaml`
4. Update `applications/microapps-application.yaml` to reference new app
5. Push to main → ArgoCD auto-syncs

---

**Note**: This is the final piece of the pipeline. Keep image tags in sync with Repo 2's builds!
