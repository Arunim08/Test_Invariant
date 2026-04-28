#!/bin/bash
# setup-repos.sh - Automated 3-repo split setup script

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Multi-Repo Split Setup Script ===${NC}\n"

# Configuration
read -p "Enter your GitHub username: " GITHUB_USER
read -p "Enter your GitHub organization (or skip for personal repos): " GITHUB_ORG
read -p "Enter Docker registry (docker.io for Docker Hub): " DOCKER_REGISTRY
read -p "Enter Docker registry path (usually your Docker username): " DOCKER_REGISTRY_PATH
read -sp "Enter Docker registry password/token: " DOCKER_PASSWORD
echo ""

# Determine GitHub base URL
if [ -z "$GITHUB_ORG" ]; then
  GITHUB_BASE="https://github.com/${GITHUB_USER}"
else
  GITHUB_BASE="https://github.com/${GITHUB_ORG}"
fi

echo -e "\n${BLUE}Configuration:${NC}"
echo "GitHub Base: $GITHUB_BASE"
echo "Docker Registry: $DOCKER_REGISTRY"
echo "Docker Path: $DOCKER_REGISTRY_PATH"

# Create working directory
WORK_DIR=$(pwd)/3-repo-split-$(date +%s)
mkdir -p "$WORK_DIR"
echo -e "\n${GREEN}✓${NC} Working directory: $WORK_DIR\n"

# Function to setup a repo
setup_repo() {
  local repo_name=$1
  local repo_type=$2
  local template_dir=$3
  
  echo -e "${BLUE}Setting up: $repo_name${NC}"
  
  mkdir -p "$WORK_DIR/$repo_name"
  cd "$WORK_DIR/$repo_name"
  
  # Initialize git
  git init
  git config user.email "ci@example.com"
  git config user.name "CI Setup"
  
  # Copy template files
  cp -r "$template_dir"/* .
  
  # Add remote
  git remote add origin "${GITHUB_BASE}/${repo_name}.git"
  
  # Initial commit
  git add .
  git commit -m "Initial commit: $repo_type"
  
  echo -e "${GREEN}✓${NC} $repo_name ready at $WORK_DIR/$repo_name"
  echo ""
}

# Setup Repo 1 (Apps + Dockerfiles)
setup_repo "test-invariant-apps" "Apps and Dockerfiles" \
  "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/repo1-apps-dockerfiles"

# Setup Repo 2 (Build)
setup_repo "test-invariant-build" "Build Files and CI/CD" \
  "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/repo2-build"

# Setup Repo 3 (ArgoCD)
setup_repo "test-invariant-argocd" "ArgoCD Configs" \
  "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/repo3-argocd"

# Create secrets configuration script
cat > "$WORK_DIR/configure-secrets.sh" << 'EOF'
#!/bin/bash
# Configure GitHub secrets for all three repos

GITHUB_USER=${1:-}
GITHUB_ORG=${2:-}

if [ -z "$GITHUB_USER" ]; then
  read -p "Enter GitHub username: " GITHUB_USER
fi

if [ -z "$GITHUB_ORG" ]; then
  read -p "Enter GitHub org (leave blank for personal): " GITHUB_ORG
fi

BASE_URL="https://github.com/${GITHUB_ORG:-$GITHUB_USER}"

# For Repo 1
echo "Configuring secrets for Repo 1 (Apps)..."
echo "Manual: Go to ${BASE_URL}/test-invariant-apps/settings/secrets/actions"
echo "Add secrets:"
echo "  - REPO_2_DISPATCH_TOKEN: (GitHub PAT with repo access)"
echo "  - REPO_2_NAME: ${GITHUB_ORG:-$GITHUB_USER}/test-invariant-build"
echo ""

# For Repo 2
echo "Configuring secrets for Repo 2 (Build)..."
echo "Manual: Go to ${BASE_URL}/test-invariant-build/settings/secrets/actions"
echo "Add secrets:"
echo "  - DOCKER_REGISTRY: (e.g., docker.io)"
echo "  - DOCKER_USERNAME: (Your Docker username)"
echo "  - DOCKER_PASSWORD: (Docker token)"
echo "  - DOCKER_REGISTRY_PATH: (Your Docker username)"
echo "  - REPO_1_ACCESS_TOKEN: (GitHub PAT, leave blank if repo is public)"
echo "  - REPO_1_NAME: ${GITHUB_ORG:-$GITHUB_USER}/test-invariant-apps"
echo "  - REPO_3_DISPATCH_TOKEN: (GitHub PAT with repo access)"
echo "  - REPO_3_NAME: ${GITHUB_ORG:-$GITHUB_USER}/test-invariant-argocd"
echo ""

# For Repo 3
echo "Configuring secrets for Repo 3 (ArgoCD)..."
echo "Manual: Go to ${BASE_URL}/test-invariant-argocd/settings/secrets/actions"
echo "Add secrets:"
echo "  - ARGOCD_SERVER: (Your ArgoCD server, e.g., argocd.example.com)"
echo "  - ARGOCD_AUTH_TOKEN: (ArgoCD API token)"
echo "  - GITHUB_EMAIL: (Git user email)"
echo "  - GITHUB_USERNAME: (Git user name)"
EOF

chmod +x "$WORK_DIR/configure-secrets.sh"

echo -e "\n${YELLOW}=== NEXT STEPS ===${NC}\n"
echo "1. Create the three repositories on GitHub:"
echo "   • test-invariant-apps"
echo "   • test-invariant-build"
echo "   • test-invariant-argocd"
echo ""
echo "2. Configure GitHub secrets:"
echo "   • Run: bash $WORK_DIR/configure-secrets.sh"
echo "   • Or manually add secrets to each repo:"
echo "     - Go to repo > Settings > Secrets and variables > Actions"
echo "     - Add all required secrets (see guide)"
echo ""
echo "3. Push repos to GitHub:"
echo "   cd $WORK_DIR/test-invariant-apps && git push -u origin main"
echo "   cd $WORK_DIR/test-invariant-build && git push -u origin main"
echo "   cd $WORK_DIR/test-invariant-argocd && git push -u origin main"
echo ""
echo "4. Test the pipeline:"
echo "   • Make a change in Repo 1"
echo "   • Push to main"
echo "   • Watch GitHub Actions in all 3 repos"
echo ""
echo -e "${GREEN}✓${NC} Setup complete!"
