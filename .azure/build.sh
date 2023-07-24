#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source .prod.env
cd ..

# Get current commit SHA
commit_sha="$(git rev-parse HEAD)"

# Install dependencies
npm ci

# Build all Docker images
export VERSION="${commit_sha}"
npm run docker:build --if-present --workspaces -- --platform linux/amd64

# Build the website
export VITE_API_URL="https://${CONTAINER_APP_HOSTNAMES[0]}"
npm run build --workspace=search-ui
