# Repo 1: Apps + Dockerfiles

## What Goes Here

This repo contains:
- `apps/` - All 10 applications with source code + Dockerfiles
- `K8s/` - Kubernetes manifests for each app
- `.github/workflows/` - Workflows to notify Repo 2 of changes

## Directory Structure

```
test-invariant-apps/
├── apps/
│   ├── app-1-go-api/
│   │   ├── Dockerfile
│   │   └── main.go
│   ├── app-2-go-worker/
│   ├── app-3-go-cache/
│   ├── app-4-py-api/
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   └── requirements.txt
│   ├── app-5-py-service/
│   ├── app-6-py-monitor/
│   ├── app-7-node-web/
│   │   ├── Dockerfile
│   │   ├── server.js
│   │   └── package.json
│   ├── app-8-node-api/
│   ├── app-9-node-worker/
│   └── app-10-java-service/
│       ├── Dockerfile
│       ├── pom.xml
│       └── src/
├── K8s/
│   ├── app-1/
│   │   └── deployment.yaml
│   ├── app-2/
│   ├── ... (through app-10)
│   ├── kustomization.yaml
│   └── ingress.yaml
├── .github/
│   └── workflows/
│       └── build-trigger.yml
└── README.md
```

## Key Points

- **Keep Dockerfiles here** - They reference source code in the same directory
- **K8s manifests** - Deployment specs (without images) for reference
- **Build files stay here too** - requirements.txt, package.json, pom.xml, src/ - so Dockerfiles can COPY them during build
- **CI/CD**: Minimal workflow that triggers Repo 2 when app code changes

## How It Connects

→ When app code or Dockerfile changes  
→ GitHub Action triggers → Repo 2 via workflow_dispatch  
→ Repo 2 clones this repo, builds images

## Files to Create

- `.github/workflows/build-trigger.yml` - See provided file

## Commands

```bash
# Local testing
docker build -f apps/app-1-go-api/Dockerfile -t app-1:test .
docker run -p 8080:8080 app-1:test

# Pushing to GitHub
git remote add origin https://github.com/YOUR_USERNAME/test-invariant-apps
git add .
git commit -m "Initial commit: apps and dockerfiles"
git push -u origin main
```
