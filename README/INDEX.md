# 3-Repo Split Setup - Complete Documentation

## 📚 Reading Guide

Start with these files in order:

1. **QUICK_REFERENCE.md** ← Start here for overview
2. **IMPLEMENTATION_GUIDE.md** ← Detailed step-by-step instructions
3. **SECRETS_GUIDE.md** ← How to configure GitHub secrets
4. **README files in each repo folder** ← Specific to each repo

## 📁 Files in This Setup

```
REPO_SPLIT_SETUP/
│
├── 📄 INDEX.md (this file)
├── 📄 QUICK_REFERENCE.md
│   └─ Quick overview of architecture & commands
│
├── 📄 IMPLEMENTATION_GUIDE.md
│   └─ Complete step-by-step setup instructions
│
├── 📄 SECRETS_GUIDE.md
│   └─ GitHub secrets configuration & best practices
│
├── 🔧 setup-repos.sh
│   └─ Automated setup script (optional)
│
├── 📁 repo1-apps-dockerfiles/
│   ├── README.md
│   ├── .github/workflows/
│   │   └── build-trigger.yml
│   └── (Copy app files here from Test_Invariant)
│
├── 📁 repo2-build/
│   ├── README.md
│   ├── .github/workflows/
│   │   └── build-all-apps.yml
│   ├── docker-compose.yaml
│   └── (Copy build files here from Test_Invariant)
│
└── 📁 repo3-argocd/
    ├── README.md
    ├── .github/workflows/
    │   └── deploy-argocd.yml
    └── (Copy argocd files here from Test_Invariant)
```

## 🎯 What to Do First

### Option A: Automated Setup (Faster)
```bash
cd REPO_SPLIT_SETUP
bash setup-repos.sh
# Follow prompts
# Script creates all 3 repos locally
```

### Option B: Manual Setup (More Control)
1. Read: **IMPLEMENTATION_GUIDE.md** (Complete instructions)
2. Follow: Step-by-step section
3. Configure: **SECRETS_GUIDE.md**
4. Test: Push to GitHub and watch Actions

## ⚡ 30-Second Overview

**What you're doing:**
- Splitting 1 monorepo into 3 coordinated repos
- Repo 1 = Apps + Source code + Dockerfiles
- Repo 2 = Build files + CI/CD pipelines
- Repo 3 = ArgoCD configs + K8s manifests

**How it works:**
```
Push to Repo 1 
    → Triggers Repo 2 build
    → Pushes images to Docker registry
    → Triggers Repo 3 deployment
    → ArgoCD syncs to Kubernetes cluster
```

**All working exactly as before**, just split across repos!

## ✅ Quick Checklist

### Before You Start
- [ ] GitHub account ready
- [ ] Docker Hub account (or other registry)
- [ ] Kubernetes cluster running with ArgoCD
- [ ] kubectl access to your cluster

### Setup Phase
- [ ] Create 3 empty GitHub repos
- [ ] Clone/organize files using IMPLEMENTATION_GUIDE.md
- [ ] Add GitHub secrets using SECRETS_GUIDE.md
- [ ] Push all 3 repos to GitHub

### Testing Phase
- [ ] Make a test change in Repo 1
- [ ] Push to main
- [ ] Watch GitHub Actions trigger in all 3 repos
- [ ] Verify cluster pods update with new images
- [ ] Monitor: `kubectl get pods -n microapps -w`

### Production Phase
- [ ] Run full test cycle 2-3 times
- [ ] Document any customizations
- [ ] Archive old monorepo (when confident)
- [ ] Notify team of new workflow

## 🔑 Key Concepts

### Repo 1: Apps + Dockerfiles
- **What**: Source code + Dockerfiles for each app
- **Who pushes**: Developers making app changes
- **Triggers**: Repo 2 build workflow
- **Example change**: Update app-1-go-api/main.go

### Repo 2: Build Files + CI/CD
- **What**: Build configs + workflows that build & push images
- **Who pushes**: Usually CI/CD system (automatic from Repo 1)
- **Triggers**: Repo 3 deployment workflow
- **Example change**: Update app-4-py-api/requirements.txt

### Repo 3: ArgoCD + K8s Manifests
- **What**: ArgoCD configs + K8s manifests that define deployments
- **Who pushes**: CI/CD system (automatic from Repo 2)
- **Triggers**: ArgoCD auto-sync to cluster
- **Example change**: Update app-1 deployment image tag

## 🚀 Common Tasks

### Make an App Code Change
```bash
# In Repo 1
git clone https://github.com/YOU/test-invariant-apps
cd test-invariant-apps
# Edit apps/app-1-go-api/main.go
git commit -am "Update app-1"
git push origin main
# Pipeline auto-runs! No need to do anything else
```

### Update Dependencies
```bash
# In Repo 2
git clone https://github.com/YOU/test-invariant-build
cd test-invariant-build
# Edit build/app-4-py-api/requirements.txt
git commit -am "Update Python deps"
git push origin main
# Pipeline auto-runs!
```

### Change Kubernetes Config
```bash
# In Repo 3
git clone https://github.com/YOU/test-invariant-argocd
cd test-invariant-argocd
# Edit k8s-manifests/app-1-deployment.yaml
git commit -am "Update replica count"
git push origin main
# ArgoCD auto-syncs!
```

### Rollback if Something Breaks
```bash
# In Repo 3
git revert HEAD
git push origin main
# ArgoCD rolls back to previous version automatically
```

## 🐛 Troubleshooting Quick Links

See **SECRETS_GUIDE.md** for troubleshooting:
- ❌ Docker push fails
- ❌ Repo can't be cloned
- ❌ ArgoCD doesn't auto-sync
- ❌ Pods stuck in Pending

See **IMPLEMENTATION_GUIDE.md** for:
- ❌ Build fails
- ❌ Deployment fails
- ❌ Images don't update

## 📞 Support

For each issue, check:
1. GitHub Actions logs (in each repo)
2. Kubernetes logs: `kubectl logs -n microapps <pod-name>`
3. ArgoCD status: `argocd app get microapps`
4. Troubleshooting section in relevant guide

## 📊 Workflow Diagram

```
┌─────────────────┐
│  Repo 1: Apps   │
│   Source Code   │
│  + Dockerfiles  │
└────────┬────────┘
         │ push to main
         ├─────→ build-trigger.yml
         │
         └─────────────────────────┐
                                   ↓
                    ┌──────────────────────────┐
                    │   Repo 2: Build CI/CD    │
                    │   build-all-apps.yml     │
                    │  1. Clone Repo 1         │
                    │  2. Build images (x10)   │
                    │  3. Push to registry     │
                    │  4. Dispatch Repo 3      │
                    └──────────┬───────────────┘
                               │
                               ↓
                    ┌──────────────────────────┐
                    │  Repo 3: ArgoCD + K8s    │
                    │  deploy-argocd.yml       │
                    │  1. Update image tags    │
                    │  2. Commit changes       │
                    │  3. Push to GitHub       │
                    └──────────┬───────────────┘
                               │
                               ↓
                    ┌──────────────────────────┐
                    │  ArgoCD Auto-Sync        │
                    │  Kubernetes Cluster      │
                    │  Rolling update with     │
                    │  new images              │
                    └──────────────────────────┘
```

## 📖 Documentation Files

| File | Purpose | Read Time |
|---|---|---|
| QUICK_REFERENCE.md | Overview & quick commands | 5 min |
| IMPLEMENTATION_GUIDE.md | Complete setup instructions | 20 min |
| SECRETS_GUIDE.md | Secrets configuration & troubleshooting | 15 min |
| repo1-apps-dockerfiles/README.md | Repo 1 details | 5 min |
| repo2-build/README.md | Repo 2 details & local testing | 10 min |
| repo3-argocd/README.md | Repo 3 details & rollback | 10 min |

## 🎓 Learning Path

**Beginner** (Just want it to work):
1. QUICK_REFERENCE.md
2. IMPLEMENTATION_GUIDE.md (skip deep sections)
3. SECRETS_GUIDE.md
4. Follow step-by-step instructions

**Intermediate** (Want to understand):
1. All files above
2. Read each repo's README.md
3. Study the workflow .yml files
4. Practice with test changes

**Advanced** (Want to customize):
1. All documentation
2. Modify .yml workflows for your needs
3. Add additional checks/notifications
4. Integrate with other systems

---

**Start here:** Read QUICK_REFERENCE.md for overview, then jump to IMPLEMENTATION_GUIDE.md!

**Questions?** Check SECRETS_GUIDE.md troubleshooting section first.
