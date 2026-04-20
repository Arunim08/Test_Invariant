# ▶️ START HERE: Getting the 10-App Pipeline Running

## The Only 3 Commands You Need

### Command 1: Commit & Push to GitHub
```bash
cd c:\Users\ARUNIM\Documents\GitHub\Test_Invariant

git add .
git commit -m "feat: add 10-app microservices platform with multi-app CI/CD pipeline"
git push origin main
```

**🎯 What this does:**
- Pushes all 10 app source code
- Pushes K8s manifests 
- Pushes GitHub Actions workflow
- Triggers automatic build pipeline

---

### Command 2: Watch the Build (Open in Browser)
```
https://github.com/Arunim08/Test_Invariant/actions
```

**🎯 What to expect:**
- Workflow: `build-deploy-apps.yml` runs
- Matrix: 10 apps split into 2-3 batches
- Each app: ~30-60 seconds to build
- Total time: ~3-4 minutes
- Result: 10 Docker images pushed to Docker Hub

---

### Command 3: Monitor Kubernetes Deployment
```bash
# Watch pods come online in real-time
kubectl get pods -n microapps -w
```

**🎯 What to expect:**
- Status: `ContainerCreating` → `Running`
- Total pods: 20 (2 replicas × 10 apps)
- Time to complete: ~2-3 minutes after images available
- Success: All `1/1 Running`

---

## Then: Test It

### Test 1: Check All Apps Running
```bash
# Get pod count
kubectl get pods -n microapps | wc -l
# Should show: 21 (20 pods + header row)

# Get all services
kubectl get svc -n microapps
# Should show: 10 services with ClusterIP assigned
```

### Test 2: Test One App
```bash
# Port-forward to app-1
kubectl port-forward -n microapps svc/app-1 8080:80

# In another terminal, test endpoints:
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/info
```

### Test 3: Test All Apps Health
```bash
# Script to test all 10 apps
for i in {1..10}; do
  echo -n "app-$i: "
  kubectl exec -n microapps -it $(kubectl get pod -n microapps -l app=app-$i -o jsonpath='{.items[0].metadata.name}') \
    -- wget -q -O- http://localhost:8080/health 2>/dev/null | grep -o '"status":"[^"]*"'
done
```

### Test 4: View Resource Usage
```bash
# Real-time CPU & Memory
kubectl top pods -n microapps

# Expected (per app, idle):
# Go apps: 2-5m CPU, 5-10Mi RAM
# Python apps: 5-20m CPU, 20-50Mi RAM
# Node apps: 3-8m CPU, 10-15Mi RAM
# Java app: 50-100m CPU, 150-200Mi RAM
```

### Test 5: Load Testing (Scale to 5 replicas)
```bash
# Commands to run in sequence:
for i in {1..10}; do
  kubectl set replicas deployment/app-$i -n microapps --replicas=5
done

# Watch scaling
kubectl get pods -n microapps -w

# View new resource usage
watch kubectl top pods -n microapps

# Scale back down
for i in {1..10}; do
  kubectl set replicas deployment/app-$i -n microapps --replicas=2
done
```

---

## Verify Everything is Working

### Checklist ✅

- [ ] Command 1: `git push` completed
- [ ] Command 2: GitHub Actions workflow running (check Actions tab)
- [ ] Command 3: `kubectl get pods -n microapps -w` shows all Running
- [ ] Test 1: 20 pods visible
- [ ] Test 2: `curl http://localhost:8080/health` returns healthy
- [ ] Test 3: All 10 apps respond to health endpoint
- [ ] Test 4: Resource usage reasonable (< 50% of cluster capacity)
- [ ] Test 5: Scaling up to 5 replicas works without errors

**If all checked ✅ —  Your 10-app platform is live! 🎉**

---

## Pipeline Flow Visualization

```
┌─────────────┐
│  Developer  │ ← You push code
└──────┬──────┘
       │ git push
       ↓
┌─────────────────────┐
│  GitHub Repository  │
│  Test_Invariant     │
└──────┬──────────────┘
       │ Push event
       ↓
┌──────────────────────────────┐
│  GitHub Actions Workflow     │
│  build-deploy-apps.yml       │
│  ├─ Job 1: detect-apps       │
│  └─ Job 2: build-and-push    │
│     ├─ Detect 10 apps        │ ← Parallel, 4 at time
│     ├─ Build Docker images   │
│     ├─ Push to Docker Hub    │
│     └─ Update K8s manifests  │
└──────┬───────────────────────┘
       │ Auto-commit changes
       ↓
┌──────────────────────────────┐
│  GitHub Repository (Updated) │
│  K8s/apps/app-*.yaml         │
│  (refs new Docker tags)       │
└──────┬───────────────────────┘
       │ Webhook to ArgoCD
       ↓
┌──────────────────────────────┐
│  ArgoCD Application          │
│  microapps-platform          │
│  ├─ Detect drift             │
│  ├─ Compare desired state    │
│  └─ Sync to Kubernetes       │
└──────┬───────────────────────┘
       │ Kubernetes API
       ↓
┌──────────────────────────────┐
│  Kubernetes Cluster          │
│  microapps namespace         │
│  ├─ 10 Deployments           │
│  ├─ 20 Pods (2 each)         │
│  ├─ 10 Services              │
│  └─ Rolling updates (0/1)    │
└──────┬───────────────────────┘
       │ Health checks pass
       ↓
┌──────────────────────────────┐
│  All 10 Apps Running         │
│  Serving traffic             │
│  Synced with ArgoCD ✅       │
└──────────────────────────────┘
```

---

## Timeline: Push to Serving

| Phase | Action | Time | Status |
|-------|--------|------|--------|
| 0 | `git push origin main` | 0:00-0:05 | 🔄 Running |
| 1 | GitHub Actions starts | 0:05-0:10 | 🔄 Running |
| 2 | Detect apps & matrix setup | 0:10-0:20 | 🔄 Running |
| 3 | Build app batches (4 parallel) | 0:20-2:00 | 🔄 Running |
| 4 | Push images to Docker Hub | 2:00-2:30 | 🔄 Running |
| 5 | Update K8s manifests | 2:30-2:50 | 🔄 Running |
| 6 | Auto-commit to GitHub | 2:50-3:00 | ✅ Done |
| 7 | ArgoCD webhook triggers | 3:00-3:10 | 🔄 Running |
| 8 | ArgoCD syncs to Kubernetes | 3:10-5:00 | 🔄 Running |
| 9 | Pods pull images | 5:00-6:00 | 🔄 Running |
| 10 | Health checks pass | 6:00-6:30 | ✅ Done |
| **Total** | **Push to serving** | **6:30** | ✅ Complete |

---

## Troubleshooting Quick Fixes

### Issue: GitHub Actions not running
**Solution:**
```bash
# Manually trigger workflow
# Go to: GitHub → Actions → build-deploy-apps.yml → Run workflow → main
```

### Issue: Pods stuck in ErrImagePull
**Solution:**
```bash
# Check if images built
docker pull arunxim/app-1:commit-XXXXXXXX

# If not found, GitHub Actions workflow failed
# Check: https://github.com/Arunim08/Test_Invariant/actions → Logs
```

### Issue: Pods in CrashLoopBackOff
**Solution:**
```bash
# Check logs
kubectl logs -f deployment/app-1 -n microapps

# Common causes:
# - Port already in use
# - Missing dependencies
# - Configuration error
```

### Issue: Services have no endpoints
**Solution:**
```bash
# Check pod is running
kubectl get pods -n microapps

# Check service selector
kubectl get svc app-1 -n microapps -o jsonpath='{.spec.selector}'
```

---

## What Happens After This

Once everything is working:

1. **Push code changes** → Automatic build & deploy
2. **The pipeline is self-healing** (ArgoCD detects drift)
3. **Scale replicas** when needed (all automated)
4. **Monitor from ArgoCD UI** (see all 10 apps at once)

---

## Additional Resources

- 📖 Full Architecture: [MULTI_APP_ARCHITECTURE.md](MULTI_APP_ARCHITECTURE.md)
- 📖 Load Testing Guide: [MULTIAPP_QUICKSTART.md](MULTIAPP_QUICKSTART.md)
- 📊 Project Status: [PROJECT_STATUS.md](PROJECT_STATUS.md)
- 🔧 Automation Details: [AUTOMATION.md](AUTOMATION.md)

---

## Quick Reference: Important URLs & Endpoints

```
GitHub Actions:        https://github.com/Arunim08/Test_Invariant/actions
Docker Hub Images:     https://hub.docker.com/r/arunxim/app-1 ... app-10
ArgoCD UI:             kubectl port-forward svc/argocd-server -n argocd 8080:443
                       → https://localhost:8080

App Endpoints (after port-forward):
- Health:    curl http://localhost:8080/health
- Info:      curl http://localhost:8080/info
- Metrics:   curl http://localhost:8080/metrics (varies by app)
- Data:      curl http://localhost:8080/data    (app-4 only)
- Status:    curl http://localhost:8080/status  (varies by app)
- Stats:     curl http://localhost:8080/stats   (app-9 only)
```

---

**🚀 Ready? Run Command 1 above and watch the magic! 🎉**
