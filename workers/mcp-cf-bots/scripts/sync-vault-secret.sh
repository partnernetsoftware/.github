#!/usr/bin/env bash
# Upload VAULT_TOKEN to the same Worker MCP_CF_BOTS_URL hits (CLOUDFLARE_WORKER_NAME).
set -euo pipefail
cd "$(dirname "$0")/.."

WORKER_NAME="${CLOUDFLARE_WORKER_NAME:-mcp-cf-bots}"
if [[ -n "${1:-}" ]]; then
  TOKEN="$1"
elif [[ -n "${VAULT_TOKEN:-}" ]]; then
  TOKEN="$VAULT_TOKEN"
elif [[ -n "${MCP_CF_BOTS_ADMIN_TOKEN:-}" ]]; then
  TOKEN="$MCP_CF_BOTS_ADMIN_TOKEN"
else
  echo "Usage: VAULT_TOKEN=... $0   OR   $0 <admin-token>" >&2
  echo "Worker: $WORKER_NAME (set CLOUDFLARE_WORKER_NAME if URL is not wrangler.toml name)" >&2
  exit 1
fi

echo "==> wrangler secret put VAULT_TOKEN --name $WORKER_NAME"
printf '%s' "$TOKEN" | npx wrangler secret put VAULT_TOKEN --name "$WORKER_NAME"
echo "Done. Test: curl -H \"Authorization: Bearer \$TOKEN\" \"\${MCP_CF_BOTS_URL%/}/v1/me\""
