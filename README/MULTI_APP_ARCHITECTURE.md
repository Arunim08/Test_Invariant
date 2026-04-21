# 🚀 Multi-App Platform Architecture

This document describes the 3-repository architecture for your microapps platform.

## Repository Structure

### **Repo 1: Applications & Deployments** (Current: Test_Invariant)
**Purpose:** Houses all app source code + K8s manifests + CI/CD workflows
**URL:** `https://github.com/Arunim08/Test_Invariant.git`

```
Test_Invariant/
├── apps/                          # 10 Microapps source code
│   ├── app-1-go-api/
│   ├── app-2-go-worker/
│   ├── app-3-go-cache/
│   ├── app-4-py-api/
│   ├── app-5-py-service/
│   ├── app-6-py-monitor/
│   ├── app-7-node-web/
│   ├── app-8-node-api/
│   ├── app-9-node-worker/
│   └── app-10-java-service/
│
├── K8s/
│   ├── apps/                      # All app K8s manifests
│   │   ├── 00-namespace.yaml
│   │   ├── app-1.yaml through app-10.yaml
│   │   └── kustomization.yaml
│   ├── base/                      # Original springboot-demo 
│   └── argocd/
│       ├── microapps-application.yaml
│       └── application.yaml        # Original springboot application
│
├── .github/
│   └── workflows/
│       ├── build-deploy.yml       # Original single-app build
│       └── build-deploy-apps.yml  # New multi-app build (MATRIX)
│
├── frontend/                       # Original React app
├── src/                            # Original Java backend
└── README.md

Key Features:
✅ 10 apps in multiple languages (Go, Python, Node.js, Java)
✅ Matrix-based GitHub Actions for parallel builds
✅ K8s Kustomization for app deployment
✅ Auto-sync enabled via ArgoCD
```

---

### **Repo 2: Deployment Manifests** (SETUP REQUIRED)
**Purpose:** Pure K8s manifests, Helm charts, deployment policies
**To Create:** `https://github.com/Arunim08/Test_Invariant-Deployments.git`

```
Test_Invariant-Deployments/
├── apps/
│   ├── app-1/
│   │   ├── base/
│   │   │   └── kustomization.yaml
│   │   └── overlays/
│   │       ├── dev/kustomization.yaml
│   │       ├── staging/kustomization.yaml
│   │       └── prod/kustomization.yaml
│   ├── app-2/ ... app-10/
│   │   └── (same structure)
│   └── shared/
│       ├── network-policies.yaml
│       └── resource-quotas.yaml
│
├── helm/
│   ├── app-chart/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   └── microapps-chart/
│       └── (aggregated chart for all apps)
│
├── policies/
│   ├── network-policies.yaml
│   ├── pod-security-policies.yaml
│   ├── pod-disruption-budgets.yaml
│   └── resource-quotas.yaml
│
└── environments/
    ├── dev/
    │   ├── namespace.yaml
    │   └── kustomization.yaml
    ├── staging/
    └── prod/

Purpose:
- Separate concerns (code vs config)
- Environment-specific overrides
- Policy management
- Helm chart templates
```

---

### **Repo 3: ArgoCD & GitOps** (SETUP REQUIRED)
**Purpose:** ArgoCD configurations, sync policies, monitoring
**To Create:** `https://github.com/Arunim08/Test_Invariant-ArgoCD.git`

```
Test_Invariant-ArgoCD/
├── applications/
│   ├── microapps-platform.yaml   # Main Application
│   ├── app-1.yaml through app-10.yaml
│   └── notifications.yaml         # ArgoCD notifications config
│
├── applicationsets/
│   ├── microapps-appset.yaml      # Dynamic app generation
│   └── multi-env-appset.yaml      # Multi-environment deployment
│
├── projects/
│   ├── default-project.yaml
│   ├── microapps-project.yaml
│   └── infra-project.yaml
│
├── secrets/
│   ├── github-credentials.yaml    # Encrypted
│   ├── docker-credentials.yaml    # Encrypted
│   └── deployment-keys.yaml       # Encrypted
│
├── sync-policies/
│   ├── auto-sync.yaml
│   ├── manual-sync.yaml
│   └── wave-based-sync.yaml
│
├── monitoring/
│   ├── prometheus-rules.yaml
│   ├── alerts.yaml
│   └── dashboards/
│       ├── app-health-dashboard.json
│       └── deployment-dashboard.json
│
└── README.md

Purpose:
- Centralized ArgoCD configuration
- Multi-app synchronization
- Policy and secret management
- Monitoring and alerts
```

---

## Workflow: Push to Deploy

```
1. Developer pushes code to Repo 1 (apps/)
                    ↓
2. GitHub Actions in Repo 1 detects changes
                    ↓
3. Matrix workflow builds 10 apps in parallel (4 at a time)
                    ↓
4. Docker images pushed to Docker Hub
                    ↓
5. K8s manifests updated (K8s/apps/)
                    ↓
6. Git commit triggers ArgoCD webhook
                    ↓
7. ArgoCD Application (microapps-platform) detects K8s/apps/ changes
                    ↓
8. ArgoCD syncs manifests to Kubernetes
                    ↓
9. Pods rolling update with new images
                    ↓
10. Health checks verify all 10 apps healthy
```

---

## Setup Instructions

### Phase 1: Current Repo (Already Done ✅)

**Repo 1 - Test_Invariant**
- ✅ 10 apps created in `/apps/`
- ✅ K8s manifests created in `/K8s/apps/`
- ✅ GitHub Actions workflow: `build-deploy-apps.yml`
- ✅ ArgoCD Application: `microapps-application.yaml`

**Next:** Create Repo 2 and Repo 3

### Phase 2: Create Repo 2 (Deployment Manifests)

```bash
# Create new GitHub repo
# Clone from Repo 1
git clone https://github.com/Arunim08/Test_Invariant.git Test_Invariant-Deployments

# Move K8s manifests
cd Test_Invariant-Deployments
mkdir -p apps/{app-1..app-10}/{base,overlays/{dev,staging,prod}}
cp K8s/apps/app-*.yaml apps/

# Push to Repo 2
git remote set-url origin https://github.com/Arunim08/Test_Invariant-Deployments.git
git push -u origin main
```

### Phase 3: Create Repo 3 (ArgoCD)

```bash
# Create new GitHub repo manually
git clone https://github.com/Arunim08/Test_Invariant-ArgoCD.git

# Copy ArgoCD configs
mkdir -p applications projects monitoring
cp ../Test_Invariant/K8s/argocd/*.yaml applications/

# Push to Repo 3
git push -u origin main
```

---

## Enabling Multi-Repo Setup

### Step 1: Update Repo 1 Workflows

Currently workflows reference local `K8s/apps/`. 

**Option A: Keep in Repo 1** (Simpler)
- Manifests stay in Repo 1
- Github Actions updates manifests directly
- ArgoCD watches Repo 1

**Option B: Use Repo 2** (Better separation)
- Add step in GitHub Actions to push to Repo 2
- ArgoCD watches Repo 2
- Requires personal access token

### Step 2: Connect Repo 3 to ArgoCD

```bash
# SSH to ArgoCD server
kubectl exec -it -n argocd argocd-repo-server-XXXX bash

# Add Repo 3 as ArgoCD repository
argocd repo add https://github.com/Arunim08/Test_Invariant-ArgoCD.git \
  --username Arunim08 \
  --password <PAT>
```

### Step 3: Deploy ApplicationSet

The ApplicationSet automatically creates Applications from manifests in Repo 3:

```bash
kubectl apply -f Test_Invariant-ArgoCD/applicationsets/microapps-appset.yaml
```

---

## Load Testing Configuration

### Current Setup (Load)
```
Total Pods:           2 replicas × 10 apps = 20 pods
Resource Requests:    ~1.5 CPU, ~1.4 GB RAM
Maximum Pods:         40 (with 3+ replicas per app)
Parallel Builds:      4 apps (GitHub Actions matrix)
```

### To Increase Load:

**Scale up replicas:**
```yaml
# K8s/apps/kustomization.yaml
replicas:
  - name: app-*
    count: 5  # Instead of 2
```

**Add stress apps:**
```bash
# Create CPU/Memory intensive versions
apps/app-11-stress-cpu/
apps/app-12-stress-memory/
```

**Parallel builds:**
```yaml
# .github/workflows/build-deploy-apps.yml
max-parallel: 8  # Increase from 4
```

---

## Monitoring & Observability

### Application Health Dashboard
Monitor all 10 apps from one place:
```bash
# Port forward ArgoCD UI
kubectl port-forward svc/argocd-server 8080:443 -n argocd

# Open: https://localhost:8080
# View: Projects → microapps → Applications
```

### Kubernetes Metrics
```bash
# Watch all pods in microapps namespace
kubectl get pods -n microapps -w

# CPU/Memory usage
kubectl top pods -n microapps

# Pod events
kubectl get events -n microapps --sort-by='.lastTimestamp'
```

---

## Cost Optimization

| Resource | Current | Load Test | Production |
|----------|---------|-----------|------------|
| Replicas/app | 2 | 3-5 | 2-3 |
| Total Pods | 20 | 30-50 | 20-30 |
| CPU Request | 1.5 | 2.5-4 | 2-3 |
| Memory Request | 1.4 GB | 2-3 GB | 1.5-2 GB |
| Node Type | t3.medium | t3.large | t3.xlarge |
| Est. Cost/month | ~$40 | ~$80-120 | ~$60-90 |

---

## Troubleshooting

### All apps failing to sync?
```bash
# Check ArgoCD logs
kubectl logs -f -n argocd deployment/argocd-application-controller

# Check application status
kubectl describe application microapps -n argocd
```

### Images not pulling?
```bash
# Verify Docker Hub credentials
kubectl get secret -n microapps

# Check image availability
docker pull arunxim/app-1:latest
```

### Pod CrashLoopBackOff?
```bash
# Check pod logs
kubectl logs -n microapps -l app=app-1 --tail=50

# Describe pod
kubectl describe pod -n microapps -l app=app-1
```

---

## Next Steps

1. ✅ **Phase 1 Complete:** All apps and manifests created
2. ⏳ **Phase 2:** Create Repo 2 (Deployment manifests)
3. ⏳ **Phase 3:** Create Repo 3 (ArgoCD configs)
4. ⏳ **Phase 4:** Deploy to Kubernetes and wire up ArgoCD
5. ⏳ **Phase 5:** Run load tests and monitor performance
