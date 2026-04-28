# Repo 2: Build Files + CI/CD

## What Goes Here

This repo contains:
- `build/` - All build files for apps (requirements.txt, package.json, pom.xml, src/)
- `.github/workflows/` - CI/CD pipelines that build and push Docker images
- `docker-compose.yaml` - Local development setup

## Directory Structure

```
test-invariant-build/
├── build/
│   ├── app-1-go-api/
│   │   └── (minimal - Go is self-contained)
│   ├── app-4-py-api/
│   │   ├── requirements.txt
│   │   ├── app.py
│   │   └── __pycache__/
│   ├── app-7-node-web/
│   │   ├── package.json
│   │   ├── package-lock.json
│   │   └── server.js
│   ├── app-10-java-service/
│   │   ├── pom.xml
│   │   ├── src/
│   │   └── target/
│   └── ... (build files for all 10 apps)
├── .github/
│   └── workflows/
│       ├── build-all-apps.yml
│       └── push-images.yml
├── docker-compose.yaml
├── Makefile (optional, for local builds)
└── README.md
```

## Key Points

- **Build files only** - requirements.txt, package.json, pom.xml, src/ directories
- **Dockerfiles NOT here** - They stay in Repo 1 (apps/)
- **Orchestrates builds** - This repo's CI/CD clones Repo 1, combines source + build files, builds images
- **Pushes to registry** - Docker Hub, ACR, ECR, or your registry
- **Triggers Repo 3** - After images are pushed

## How It Connects

Repo 1 triggers this via `workflow_dispatch` →  
This repo's workflow:
1. Clones Repo 1 (apps + Dockerfiles)
2. Combines with build/ files from this repo
3. Builds all Docker images (in parallel)
4. Pushes to registry
5. Triggers Repo 3 via `workflow_dispatch` with image tags

## Build Workflow Details

### build-all-apps.yml
- Matrix job: Builds up to 4 apps in parallel
- For each app: Clones Repo 1, uses Dockerfile, builds image
- Outputs: Image names and tags (saved for next job)

### push-images.yml
- After build succeeds
- Pushes all images to Docker registry
- Tags with: `git-sha` and `latest`
- Notifies Repo 3 with image tags

## Files to Create

- `.github/workflows/build-all-apps.yml` - See provided file
- `.github/workflows/push-images.yml` - See provided file
- `docker-compose.yaml` - See provided file

## Local Development

```bash
# Build a single app locally
docker build -f ../repo1-apps-dockerfiles/apps/app-1-go-api/Dockerfile \
  -t myusername/app-1:dev .

# Using docker-compose (if configured)
docker-compose up

# Run all apps
docker-compose up app-1 app-2 app-3 app-4 ...
```

## Environment Variables / Secrets Required

Add to GitHub Secrets in this repo:
- `DOCKER_REGISTRY`: e.g., `docker.io`
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Docker Hub token
- `DOCKER_REGISTRY_PATH`: e.g., `yourusername` (for `yourusername/app-1`)
- `REPO_1_ACCESS_TOKEN`: GitHub PAT to clone Repo 1 (if private)
- `REPO_3_DISPATCH_TOKEN`: GitHub PAT to trigger Repo 3 workflows
- `REPO_3_NAME`: e.g., `yourorg/test-invariant-argocd`

## Commands

```bash
# Push to GitHub
git remote add origin https://github.com/YOUR_USERNAME/test-invariant-build
git add .
git commit -m "Initial commit: build files and CI/CD"
git push -u origin main

# Manually trigger build (if needed)
# Go to Actions > build-all-apps > Run workflow > Run workflow
```

## Monitoring Builds

1. Go to GitHub Actions tab
2. Click on `build-all-apps` workflow
3. View logs for each app build
4. Check `push-images` workflow for registry push status

## Troubleshooting

If build fails:
1. Check logs in GitHub Actions
2. Verify Repo 1 is accessible
3. Check if DOCKER_REGISTRY secrets are correct
4. Manually test locally: `docker build -f apps/app-1/Dockerfile .`
