# 🚀 Multi-App Platform Quick Start

## Current Status ✅

- ✅ 10 microapps created (Go, Python, Node.js, Java)
- ✅ Kubernetes manifests deployed (K8s/apps/)
- ✅ ArgoCD Application configured
- ✅ GitHub Actions multi-app workflow ready
- ✅ Services created in `microapps` namespace

## What's Pending 🔄

Pods are in `ErrImagePull` state because images haven't been built yet.

```
Action Required:
1. Push code to GitHub main branch
2. GitHub Actions builds all 10 apps in parallel
3. Images pushed to Docker Hub (arunxim/app-1...app-10)
4. K8s manifests auto-updated with new tags
5. ArgoCD syncs → Pods pull images → Apps start running
```

---

## Get Started in 3 Steps

### Step 1: Prepare Git Repository

```bash
cd c:\Users\ARUNIM\Documents\GitHub\Test_Invariant

# Add all new files
git add .

# Commit
git commit -m "feat: add 10-app microservices platform with auto-deployment"

# Push to main
git push origin main
```

### Step 2: Watch GitHub Actions Build

Opens browser and watch the build:
```bash
https://github.com/Arunim08/Test_Invariant/actions
```

**What happens automatically:**
- Workflow: `build-deploy-apps.yml` triggers
- Detects changes in `apps/` directory
- Creates matrix with 10 apps
- Builds 4 apps in parallel (max-parallel: 4)
- Total build time: ~3-4 minutes
- Pushes images to Docker Hub
- Updates K8s manifests with new tags
- ArgoCD detects changes and syncs

### Step 3: Monitor Kubernetes Deployment

```bash
# Watch pods come online
kubectl get pods -n microapps -w

# Once all Running/1, check services
kubectl get svc -n microapps

# Test an app (port-forward)
kubectl port-forward -n microapps svc/app-1 8080:80
# Visit: http://localhost:8080

# View all apps in ArgoCD UI
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Visit: https://localhost:8080/applications
```

---

## Load Testing Your Pipeline

### Current Load Configuration
```
Deployments:    10 apps
Total Replicas: 20 pods (2 per app)
CPU Requests:   ~1.5 cores
Memory Requests: ~1.4 GB
```

### Test #1: Basic Functionality
```bash
# Test each app's health endpoint
for i in {1..10}; do
  echo "Testing app-$i..."
  kubectl port-forward -n microapps svc/app-$i 8080:80 &
  curl http://localhost:8080/health
  kill %1 2>/dev/null
  echo ""
done
```

### Test #2: Monitor Resource Usage
```bash
# Watch CPU & Memory in real-time
watch kubectl top pods -n microapps

# Expected:
# app-1:  ~2-5m CPU,   5-10Mi RAM
# app-2:  ~2-5m CPU,   5-10Mi RAM
# app-3:  ~1-3m CPU,   5-10Mi RAM
# app-4:  ~5-10m CPU,  20-30Mi RAM (Python)
# app-5:  ~5-10m CPU,  20-30Mi RAM (Python)
# app-6:  ~10-15m CPU, 30-50Mi RAM (Python + psutil)
# app-7:  ~3-8m CPU,   10-15Mi RAM (Node.js)
# ...
```

### Test #3: Increase Load (Scale to 5 replicas)
```bash
# Edit K8s/apps/kustomization.yaml
# Change scale: 2 → scale: 5

kubectl set replicas deployment/app-1 -n microapps --replicas=5
kubectl set replicas deployment/app-2 -n microapps --replicas=5
# ... repeat for all 10

# Or use this script:
for i in {1..10}; do
  kubectl set replicas deployment/app-$i -n microapps --replicas=5
done

# Monitor scaling
kubectl get pods -n microapps -w
kubectl top pods -n microapps
```

### Test #4: High-Frequency Deployments
```bash
# Simulate rapid updates to test pipeline speed
# Edit one app locally
echo "Updated" >> apps/app-1-go-api/main.go

# Commit & push
git add .
git commit -m "test: rapid deployment #1"
git push origin main

# Time from push to pod restart:
# Expected: 3-4 minutes for full pipeline
```

### Test #5: Failure Recovery
```bash
# Delete a pod (verify auto-restart)
kubectl delete pod -n microapps $(kubectl get pod -n microapps -o name | head -1)

# ArgoCD should restore it within 3 minutes (default sync interval)

# Delete entire deployment
kubectl delete deployment -n microapps app-1

# ArgoCD detects drift, resyncs, and recreates it
kubectl get events -n microapps | grep "app-1"
```

---

## Performance Baseline (Expected)

### Build Times
| Task | Time |
|------|------|
| Detect changes | ~10s |
| Build app | 30-60s (per app) |
| Parallel builds (4 max) | ~2 min total |
| Push to Docker Hub | ~30-60s |
| Update manifests | ~20s |
| Git commit & push | ~15s |
| ArgoCD sync | ~2-3 min |
| **Total: Push to Running** | **~5-7 min** |

### Resource Usage (Per App)
| App Type | CPU (Request) | CPU (Actual) | Memory (Request) | Memory (Actual) |
|----------|---------------|--------------|------------------|-----------------|
| Go APIs | 100m | 2-5m | 64Mi | 5-8Mi |
| Go Worker | 100m | 2-5m | 64Mi | 5-8Mi |
| Go Cache | 100m | 1-3m | 64Mi | 5-8Mi |
| Python API | 100m | 5-15m | 96Mi | 20-30Mi |
| Python Service | 100m | 5-15m | 96Mi | 20-30Mi |
| Python Monitor | 150m | 10-20m | 128Mi | 30-50Mi |
| Node.js Web | 100m | 3-8m | 64Mi | 10-15Mi |
| Node.js API | 100m | 3-8m | 64Mi | 10-15Mi |
| Node.js Worker | 100m | 3-8m | 64Mi | 10-15Mi |
| Java Service | 200m | 50-100m | 256Mi | 150-200Mi |

### Total at 2 Replicas
- **CPU Request:** 1.55 cores
- **CPU Actual:** ~0.2-0.5 cores (idle)
- **Memory Request:** 1.4 GB
- **Memory Actual:** ~0.4-0.6 GB

### Scaling Recommendations
| Scenario | Replicas | Total CPU | Total Memory | Node Type |
|----------|----------|-----------|--------------|-----------|
| Development | 2 | 1.55 cores | 1.4 GB | t3.medium (~$30/mo) |
| Load Test | 5 | 3.9 cores | 3.5 GB | t3.large (~$60/mo) |
| Production | 3 | 2.3 cores | 2.1 GB | t3.large (~$60/mo) |
| Max Stress | 10 | 7.8 cores | 7.0 GB | t3.2xlarge (~$250/mo) |

---

## GitHub Actions Pipeline Breakdown

### Workflow: `build-deploy-apps.yml`

```yaml
detect-apps (1 job)
  ├─ Matrix: 10 apps
  └─ Output: 10 app configs

build-and-push (10 jobs in parallel, 4 at a time)
  ├─ Checkout code
  ├─ Determine version
  ├─ Check changes (skip if not changed)
  ├─ Build Docker image
  ├─ Push to Docker Hub
  ├─ Update K8s manifest
  ├─ Commit & push changes
  └─ Parallel Max: 4 (tune in .yml)

create-release (on tag)
  └─ Create GitHub Release with details

Total Time per Push: 5-7 minutes
```

---

## Next: Create Repo 2 & Repo 3

Once apps are running, set up the 2 additional repos:

### Repo 2: Deployment Manifests
```bash
# Create new repo on GitHub
# Clone, organize K8s configs by environment

mkdir -p deployment-repo/{apps,helm,policies,environments}
cp K8s/apps/app-*.yaml deployment-repo/apps/
# Push to github.com/Arunim08/Test_Invariant-Deployments
```

### Repo 3: ArgoCD Config
```bash
# Create new repo on GitHub
# Centralize all ArgoCD Applications, AppSets, Projects

mkdir -p argocd-repo/{applications,applicationsets,projects,monitoring}
cp K8s/argocd/*.yaml argocd-repo/applications/
# Push to github.com/Arunim08/Test_Invariant-ArgoCD
```

---

## Troubleshooting

### Issue: Pods stuck in ErrImagePull
```bash
# Check if images exist
docker pull arunxim/app-1:latest

# If missing: GitHub Actions might not have run
# Check: https://github.com/Arunim08/Test_Invariant/actions

# Force rebuild
git push --force origin main
# Or manually trigger:
# GitHub UI → Actions → build-deploy-apps.yml → Run workflow
```

### Issue: ArgoCD not syncing
```bash
# Check application status
kubectl describe application microapps -n argocd

# View sync details
kubectl get application microapps -n argocd -o yaml | grep -A 10 "syncPolicy"

# Manual sync
argocd app sync microapps

# Or via kubectl
kubectl patch application microapps -n argocd \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/sync":"true"}}}' \
  --type merge
```

### Issue: High CPU usage
```bash
# Check resource requests vs actual
kubectl top pods -n microapps
kubectl describe pods -n microapps | grep -A 3 "Requests\|Limits"

# Reduce resource requests if running on small nodes
# Edit K8s/apps/app-{X}.yaml and reduce CPU/Memory
```

---

## Commands Cheat Sheet

```bash
# Watch deployment progress
kubectl get pods -n microapps -w

# Get service IPs
kubectl get svc -n microapps

# Test app endpoint
kubectl port-forward svc/app-1 -n microapps 8080:80
curl http://localhost:8080/health

# View logs
kubectl logs -f deployment/app-1 -n microapps --tail=50

# Check ArgoCD status
kubectl get application -n argocd
kubectl describe application microapps -n argocd

# Force ArgoCD sync
argocd app sync microapps

# Scale manually
kubectl scale deployment app-1 --replicas=5 -n microapps

# View resource usage
kubectl top pods -n microapps
kubectl top nodes

# Get detailed pod info
kubectl get pods -n microapps -o wide
```

---

## What to Do Now

1. **Commit & Push:** `git push origin main` (triggers build)
2. **Watch Build:** Check GitHub Actions (3-4 min)
3. **Monitor Pods:** `kubectl get pods -n microapps -w`
4. **Test Apps:** `kubectl port-forward svc/app-1 8080:80`
5. **Run Load Tests:** Follow test examples above
6. **Scale Load:** Increase replicas to stress-test

**Enjoy your 10-app platform! 🎉**
