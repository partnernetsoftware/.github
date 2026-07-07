#!/usr/bin/env bash
# Optional: separate MCP-Session-Id HMAC secret from admin VAULT_TOKEN.
set -euo pipefail
cd "$(dirname "$0")/.."

WORKER_NAME="${CLOUDFLARE_WORKER_NAME:-mcp-cf-bots}"
if [[ -z "${1:-}" && -z "${MCP_SESSION_SECRET:-}" ]]; then
  echo "Usage: MCP_SESSION_SECRET=... $0   OR   $0 <secret>" >&2
  exit 1
fi
SECRET="${1:-$MCP_SESSION_SECRET}"

echo "==> wrangler secret put MCP_SESSION_SECRET --name $WORKER_NAME"
printf '%s' "$SECRET" | npx wrangler secret put MCP_SESSION_SECRET --name "$WORKER_NAME"
echo "Done. Note: existing MCP-Session-Id headers become invalid until clients re-initialize."
