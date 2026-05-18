#!/bin/bash
# Apply branch protection on main requiring CI status checks.
set -euo pipefail

REPO="${GITHUB_REPO:-chrsappiah-cloud/WCS-GoldTest}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v gh >/dev/null 2>&1; then
  echo "Install GitHub CLI: brew install gh"
  exit 1
fi

echo "Applying branch protection to $REPO main..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${REPO}/branches/main/protection" \
  --input "${ROOT}/.github/branch-protection.json"

echo "Branch protection applied. Required checks:"
echo "  - CI Gate"
echo "  - Build"
echo "  - Unit Tests"
echo "  - UI Tests"
echo "  - Release Compile Check"
echo "  - Fastlane Test Lane"
