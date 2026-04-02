#!/bin/bash
# release.sh - Helper script to create releases with semantic versioning

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Display current version info
echo -e "${YELLOW}=== Springboot Demo Release Helper ===${NC}"
echo ""

# Get current git tags
echo "Recent versions:"
git tag -l --sort=-creatordate | head -5 || echo "No releases yet"
echo ""

# Get version input
read -p "Enter version tag (e.g., v1.0.0): " VERSION

# Validate version format
if ! [[ $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Version must be in format v1.0.0${NC}"
    exit 1
fi

# Check if tag already exists
if git rev-parse "$VERSION" >/dev/null 2>&1; then
    echo -e "${RED}Error: Tag $VERSION already exists${NC}"
    exit 1
fi

# Get release notes
read -p "Enter release notes (or press Enter to skip): " RELEASE_NOTES

# Confirm
echo ""
echo -e "${YELLOW}Ready to create release:${NC}"
echo "  Tag: $VERSION"
echo "  Release Notes: ${RELEASE_NOTES:-'(none)'}"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

# Create tag
if [ -z "$RELEASE_NOTES" ]; then
    git tag -a "$VERSION" -m "Release $VERSION"
else
    git tag -a "$VERSION" -m "Release $VERSION: $RELEASE_NOTES"
fi

# Push tag
echo -e "${YELLOW}Pushing tag to GitHub...${NC}"
git push origin "$VERSION"

echo -e "${GREEN}✓ Release $VERSION created successfully!${NC}"
echo ""
echo "GitHub Actions will now:"
echo "  1. Build Docker image"
echo "  2. Tag as: arunxim/springboot-frontend:$VERSION"
echo "  3. Push to Docker Hub"
echo "  4. Update K8s deployment"
echo "  5. Deploy to Kubernetes via ArgoCD"
echo ""
echo "Monitor progress at: https://github.com/Arunim08/Test_Invariant/actions"
