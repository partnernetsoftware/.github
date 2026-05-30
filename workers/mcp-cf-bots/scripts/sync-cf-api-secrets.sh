#!/usr/bin/env bash
# Upload CF_ACCOUNT_ID + CF_API_TOKEN for Vectorize list/GC and status-page analytics.
set -euo pipefail
cd "$(dirname "$0")/.."

WORKER_NAME="${CLOUDFLARE_WORKER_NAME:-mcp-cf-bots}"

if [[ -z "${CF_ACCOUNT_ID:-}" || -z "${CF_API_TOKEN:-}" ]]; then
  echo "Set CF_ACCOUNT_ID and CF_API_TOKEN (Analytics Read + Vectorize Read/Edit as needed)" >&2
  exit 1
fi

echo "==> wrangler secret put CF_ACCOUNT_ID --name $WORKER_NAME"
printf '%s' "$CF_ACCOUNT_ID" | npx wrangler secret put CF_ACCOUNT_ID --name "$WORKER_NAME"
echo "==> wrangler secret put CF_API_TOKEN --name $WORKER_NAME"
printf '%s' "$CF_API_TOKEN" | npx wrangler secret put CF_API_TOKEN --name "$WORKER_NAME"
echo "Done. Check: curl -s \"\${MCP_CF_BOTS_URL%/}/health\" | jq .features.cf_api_ready"
