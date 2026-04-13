# Docker Hub Repository Quick Reference

## All 10 Repositories to Create

| App | Language | Repository | Type | Status |
|-----|----------|-----------|------|--------|
| app-1 | Go | `arunxim/app-1` | API | 🔴 Pending |
| app-2 | Go | `arunxim/app-2` | Worker | 🔴 Pending |
| app-3 | Go | `arunxim/app-3` | Cache | 🔴 Pending |
| app-4 | Python | `arunxim/app-4` | API | 🔴 Pending |
| app-5 | Python | `arunxim/app-5` | Service | 🔴 Pending |
| app-6 | Python | `arunxim/app-6` | Monitor | 🔴 Pending |
| app-7 | Node.js | `arunxim/app-7` | Web | 🔴 Pending |
| app-8 | Node.js | `arunxim/app-8` | API | 🔴 Pending |
| app-9 | Node.js | `arunxim/app-9` | Worker | 🔴 Pending |
| app-10 | Java | `arunxim/app-10` | Service | 🔴 Pending |

---

## Create Repositories - One-Click Links

Click each link to create the repository directly on Docker Hub:

1. **app-1** (Go API)
   - https://hub.docker.com/repository/create?namespace=arunxim&name=app-1

2. **app-2** (Go Worker)
   - https://hub.docker.com/repository/create?namespace=arunxim&name=app-2

3. **app-3** (Go Cache)
   - https://hub.docker.com/repository/create?namespace=arunxim&name=app-3

4. **app-4** (Python API)
   - https://hub.docker.com/repository/create?namespace=arunxim&name=app-4

5. **app-5** (Python Service)
   - https://hub.docker.com/repository/create?namespace=arunxim&name=app-5

6. **app-6** (Python Monitor)
   - https://hub.docker.com/repository/create?namespace=arunxim&name=app-6

7. **app-7** (Node.js Web)
   - https://hub.docker.com/repository/create?namespace=arunxim&name=app-7

8. **app-8** (Node.js API)
   - https://hub.docker.com/repository/create?namespace=arunxim&name=app-8

9. **app-9** (Node.js Worker)
   - https://hub.docker.com/repository/create?namespace=arunxim&name=app-9

10. **app-10** (Java Service)
    - https://hub.docker.com/repository/create?namespace=arunxim&name=app-10

---

## Manual Setup Steps

1. Go to [Docker Hub](https://hub.docker.com)
2. Sign in as `arunxim`
3. Click **"Create Repository"**
4. For each app:
   - **Name**: `app-1`, `app-2`, etc.
   - **Visibility**: Public (or Private if needed)
   - **Description**: Copy from table below
   - Click **Create**

### Description Templates

```
app-1: Go microservice exposed as API endpoint, handles HTTP requests with health checks
app-2: Go background worker, processes async tasks and events with metrics
app-3: Go in-memory cache service, stores and retrieves key-value data
app-4: Python microservice API, serves JSON data with multiple endpoints
app-5: Python backend service, core business logic and processing
app-6: Python monitoring service, tracks metrics and health of other apps
app-7: Node.js web frontend, serves static content and HTML UI
app-8: Node.js REST API service, provides HTTP endpoints for data operations
app-9: Node.js workflow processor, handles background job execution
app-10: Java Spring Boot microservice, REST API with enterprise features
```

---

## Docker Hub Access Token Setup

### Create Access Token (Required by GitHub Actions)

1. Go to [Docker Hub Settings](https://hub.docker.com/settings/security)
2. Click **"New Access Token"**
3. Enter **Access Token Description**: `GitHub Actions CI/CD`
4. Click **Create**
5. Copy the token (shown once, save it!)

### Add to GitHub Secrets

1. Go to GitHub Repository → Settings → Secrets and variables → Actions
2. Create **New repository secret**:
   - **Name**: `DOCKER_USERNAME`
   - **Value**: `arunxim`
3. Create **New repository secret**:
   - **Name**: `DOCKER_PASSWORD`
   - **Value**: `<paste_token_here>`

---

## Verify Repositories Created

### Check if Repositories Exist
```bash
# Check each repository
curl -s https://hub.docker.com/v2/repositories/arunxim/app-1 | jq '.id'
curl -s https://hub.docker.com/v2/repositories/arunxim/app-2 | jq '.id'
# ... etc for all 10

# Or manually visit each URL
https://hub.docker.com/r/arunxim/app-1
https://hub.docker.com/r/arunxim/app-2
# ... etc
```

---

## Image Tags That Will Be Created

### After First Build
```
❌ NO: arunxim/app-1:latest (REMOVED)
✅ YES: arunxim/app-1:commit-1f32f51 (from commit SHA)
```

### After Semantic Release
```
✅ arunxim/app-1:v1.0.0
✅ arunxim/app-2:v1.0.0
... (all 10 apps)
```

### No "Latest" Tag
- Prevents accidental deployments of untested versions
- Explicit version control for production stability
- Clearer audit trail of which version is running where

---

## Docker Images Dashboard

After repositories created, view all images:

**Docker Hub Dashboard**: https://hub.docker.com/u/arunxim

Each repository will show:
- **Tags**: All pushed versions (v1.0.0, commit-XXXXX, etc.)
- **Pulls**: Download count
- **Last Pushed**: Timestamp of last image push

---

## Current Image Status

**Location**: GitHub Actions → "Build and Deploy Multi-Apps"
**Last Build**: commit-1f32f51

Images available at:
- `arunxim/app-1:commit-1f32f51` (after setting up repo and running workflow)
- `arunxim/app-2:commit-1f32f51`
- ... (all 10 apps)

---

## Troubleshooting Repository Creation

**Problem**: Repository name already taken
```
Solution: Use different name (e.g., app-1-service instead of app-1)
Note: Must also update GitHub Actions workflow to match new names
```

**Problem**: Can't access Docker Hub account
```
Solution: 
  1. Check login at hub.docker.com
  2. Verify email is confirmed
  3. Reset password if needed
```

**Problem**: Repository exists but images not pushing
```
Solution:
  1. Check GitHub Secrets have DOCKER_USERNAME + DOCKER_PASSWORD
  2. Verify Docker access token is valid (not expired)
  3. Check GitHub Actions logs for authentication errors
```

---

## Next Steps

1. **Create 10 Docker Hub Repositories** (use one-click links above)
2. **Verify Docker Credentials** in GitHub (DOCKER_USERNAME & DOCKER_PASSWORD)
3. **Push Code** to trigger first build:
   ```bash
   git add DOCKER_HUB_SETUP.md
   git commit -m "docs: add docker hub versioning guide"
   git push origin main
   ```
4. **Monitor Workflow**: GitHub Actions → "Build and Deploy Multi-Apps"
5. **Verify Images**: Visit https://hub.docker.com/u/arunxim
6. **Check K8s Pods**: `kubectl get pods -n microapps`
7. **Confirm Versions**: Each pod should reference specific version tags (no `:latest`)

---

## Reference

- **Docker Hub**: https://hub.docker.com
- **Semantic Versioning**: https://semver.org
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Docker Build Documentation**: https://docs.docker.com/build/
