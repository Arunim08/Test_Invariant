# GitHub Secrets Configuration Guide

## Overview

This guide explains what secrets to add to each repository for the CI/CD pipeline to work correctly.

## Secret Types

### 1. GitHub Personal Access Token (PAT)
Used to trigger workflows across repos and clone private repos.

**How to create:**
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Name: `CI-MultiRepo`
4. Scopes:
   - ✓ `repo` (full control of private repositories)
   - ✓ `workflow` (update GitHub Action workflows)
5. Click "Generate token"
6. **Copy immediately** - you won't see it again

### 2. Docker Registry Credentials
Needed to push images to Docker Hub or other registries.

**For Docker Hub:**
1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name: `github-actions`
4. Permissions: Read & Write
5. Copy the token

**For Azure Container Registry (ACR):**
1. In your ACR resource
2. Settings → Access keys
3. Enable Admin user
4. Copy username and password

### 3. ArgoCD Token
Needed to trigger deployments via ArgoCD API.

**How to create:**
```bash
# Connect to your cluster
kubectl get pods -n argocd

# Create token (if ArgoCD is running)
argocd account generate-token --account admin

# Or get existing token from ArgoCD secret
kubectl get secret -n argocd argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

---

## Secrets by Repository

### Repo 1: test-invariant-apps

**Secrets to add:**

| Secret Name | Value | Notes |
|---|---|---|
| `REPO_2_DISPATCH_TOKEN` | GitHub PAT | Token to trigger Repo 2 workflows |
| `REPO_2_NAME` | `yourusername/test-invariant-build` or `orgname/test-invariant-build` | Full repo path for dispatch calls |

**How to add:**
1. Go to: `https://github.com/YOUR_USERNAME/test-invariant-apps/settings/secrets/actions`
2. Click "New repository secret"
3. Name: `REPO_2_DISPATCH_TOKEN`
4. Value: Paste your GitHub PAT
5. Click "Add secret"
6. Repeat for `REPO_2_NAME`

---

### Repo 2: test-invariant-build

**Secrets to add:**

| Secret Name | Value | Notes |
|---|---|---|
| `DOCKER_REGISTRY` | `docker.io` | Docker Hub; or `yourregistry.azurecr.io` for ACR |
| `DOCKER_USERNAME` | Your Docker username | For docker.io or ACR admin user |
| `DOCKER_PASSWORD` | Docker access token | From Docker Hub or ACR |
| `DOCKER_REGISTRY_PATH` | Your Docker username | Path prefix: `yourusername/app-1` |
| `REPO_1_ACCESS_TOKEN` | GitHub PAT | **Optional** - only if Repo 1 is private |
| `REPO_1_NAME` | `yourusername/test-invariant-apps` | Full repo path |
| `REPO_3_DISPATCH_TOKEN` | GitHub PAT | Token to trigger Repo 3 workflows |
| `REPO_3_NAME` | `yourusername/test-invariant-argocd` | Full repo path for dispatch calls |

**Example for Docker Hub:**
- DOCKER_REGISTRY: `docker.io`
- DOCKER_USERNAME: `yourdockernusername`
- DOCKER_PASSWORD: `dckr_pat_XXXXXXXXXXXXXXXXXXXX`
- DOCKER_REGISTRY_PATH: `yourdockernusername`

**Example for Azure ACR:**
- DOCKER_REGISTRY: `myregistry.azurecr.io`
- DOCKER_USERNAME: `myregistry`
- DOCKER_PASSWORD: `<ACR password>`
- DOCKER_REGISTRY_PATH: `myregistry`

**How to add:**
1. Go to: `https://github.com/YOUR_USERNAME/test-invariant-build/settings/secrets/actions`
2. Click "New repository secret" for each one
3. Add all secrets from table above

---

### Repo 3: test-invariant-argocd

**Secrets to add:**

| Secret Name | Value | Notes |
|---|---|---|
| `ARGOCD_SERVER` | `argocd.example.com` | **Optional** - ArgoCD hostname (without https://) |
| `ARGOCD_AUTH_TOKEN` | ArgoCD API token | **Optional** - For auto-sync; if blank, manual sync needed |
| `GITHUB_EMAIL` | `ci@example.com` | Git user email for commits |
| `GITHUB_USERNAME` | `github-actions` | Git user name for commits |

**How to get ArgoCD token:**
```bash
# Option 1: Generate new token
argocd account generate-token --account admin

# Option 2: Get existing admin secret
kubectl get secret -n argocd argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

**How to add:**
1. Go to: `https://github.com/YOUR_USERNAME/test-invariant-argocd/settings/secrets/actions`
2. Click "New repository secret" for each one
3. Add secrets from table above

---

## Complete Secrets Checklist

### Repo 1
- [ ] `REPO_2_DISPATCH_TOKEN` = GitHub PAT
- [ ] `REPO_2_NAME` = yourusername/test-invariant-build

### Repo 2
- [ ] `DOCKER_REGISTRY` = docker.io (or your registry)
- [ ] `DOCKER_USERNAME` = your docker username
- [ ] `DOCKER_PASSWORD` = your docker token
- [ ] `DOCKER_REGISTRY_PATH` = your docker username
- [ ] `REPO_1_ACCESS_TOKEN` = GitHub PAT (only if private)
- [ ] `REPO_1_NAME` = yourusername/test-invariant-apps
- [ ] `REPO_3_DISPATCH_TOKEN` = GitHub PAT
- [ ] `REPO_3_NAME` = yourusername/test-invariant-argocd

### Repo 3
- [ ] `ARGOCD_SERVER` = argocd.example.com (optional)
- [ ] `ARGOCD_AUTH_TOKEN` = ArgoCD token (optional)
- [ ] `GITHUB_EMAIL` = ci@example.com
- [ ] `GITHUB_USERNAME` = github-actions

---

## Security Best Practices

1. **Use Personal Access Tokens (PAT), not personal passwords**
   - Tokens are more secure and scoped
   - Can be rotated independently

2. **Minimize PAT permissions**
   - Use `repo` scope for GitHub repos
   - Avoid `admin` scopes

3. **Rotate tokens regularly**
   - Generate new token
   - Update secret
   - Delete old token

4. **Never commit secrets**
   - Use `.gitignore` to exclude secret files
   - GitHub will warn if secrets are pushed

5. **Monitor secret usage**
   - GitHub Actions logs show which secrets are used
   - Check for unexpected access

---

## Testing Secrets

After configuring secrets, test each one:

### Test Repo 2 Docker secrets
```bash
# In Repo 2 Actions
# Manually trigger: build-all-apps
# Check: Docker login succeeds
# Check: Images push to registry
```

### Test cross-repo dispatch
```bash
# In Repo 1
# Make a small change
# Push to main
# Check: Repo 2 workflow triggers automatically
```

### Test ArgoCD
```bash
# In Repo 3
# Make a change to a manifest
# Push to main
# Check: kubectl get pods -n microapps shows updates
```

---

## Troubleshooting

### "Authentication failed" in Docker push
- Verify DOCKER_PASSWORD is correct
- Verify DOCKER_USERNAME matches DOCKER_PASSWORD
- For Docker Hub, use access token, not password

### "Permission denied" for cross-repo dispatch
- Verify REPO_2_DISPATCH_TOKEN has `workflow` scope
- Verify token is not expired

### "Failed to clone Repo 1"
- If Repo 1 is private, add REPO_1_ACCESS_TOKEN
- Verify token has `repo` scope
- Verify token is not expired

### ArgoCD doesn't auto-sync
- Verify ARGOCD_AUTH_TOKEN is correct
- Verify ARGOCD_SERVER is reachable
- Check ArgoCD Application auto-sync setting
- Manually run: `argocd app sync microapps`

---

## When to Rotate Secrets

Rotate secrets regularly for security:

1. **GitHub PATs**: Every 90 days
2. **Docker tokens**: Every 6 months
3. **After team changes**: Immediately
4. **If compromised**: Immediately

### How to rotate

1. Create new token/secret
2. Update GitHub secret
3. Delete old token
4. Test pipeline

---

## Support

If secrets aren't working:
1. Verify secret value is correct (no extra spaces)
2. Verify workflow file references correct secret name
3. Check GitHub Actions logs for error messages
4. Try re-creating the secret (sometimes helps)
