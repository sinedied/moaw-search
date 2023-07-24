#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source .prod.env
cd ..

# Get current commit SHA
commit_sha="$(git rev-parse HEAD)"

# Allow silent installation of Azure CLI extensions
az config set extension.use_dynamic_install=yes_without_prompt

echo "Logging into Docker..."
echo "$REGISTRY_PASSWORD" | docker login \
  --username "$REGISTRY_USERNAME" \
  --password-stdin \
  "$REGISTRY_NAME.azurecr.io"

# echo "Deploying search-api..."
docker image tag search-api "$REGISTRY_NAME.azurecr.io/search-api:$commit_sha"
docker image push "$REGISTRY_SERVER/search-api:$commit_sha"

az containerapp update \
  --name "${CONTAINER_APP_NAMES[0]}" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --image "$REGISTRY_SERVER/search-api:$commit_sha" \
  --set-env-vars \
    MS_LOGGING_APP_LEVEL="DEBUG" \
    MS_LOGGING_SYS_LEVEL="WARN" \
    MS_ROOT_PATH="" \
    MS_QD_HOST="${CONTAINER_APP_HOSTNAMES[1]}" \
    MS_QD_PORT="80" \
    MS_REDIS_HOST="${REDIS_HOSTNAME}" \
    MS_ACS_API_BASE="${CONTENT_SAFETY_ENDPOINT}" \
    MS_ACS_API_TOKEN="${CONTENT_SAFETY_API_KEY}" \
    MS_OAI_ADA_DEPLOY_ID="${OPENAI_MODEL_NAMES[0]}" \
    MS_OAI_GPT_DEPLOY_ID="${OPENAI_MODEL_NAMES[1]}" \
    OPENAI_API_BASE="${OPENAI_ENDPOINT}" \
    OPENAI_API_TOKEN="${OPENAI_API_KEY}" \
    REDIS_KEY="${REDIS_KEY}" \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying website..."
cd packages/search-ui
npx swa deploy \
  --app-name "${STATIC_WEB_APP_NAMES[0]}" \
  --deployment-token "${STATIC_WEB_APP_DEPLOYMENT_TOKENS[0]}" \
  --env "production" \
  --verbose
