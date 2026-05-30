#!/usr/bin/env bash
# Full deploy pipeline: install → typecheck → test → wrangler deploy → smoke.
# Set SKIP_SMOKE=1 to skip post-deploy smoke (./scripts/smoke.sh).
set -euo pipefail
cd "$(dirname "$0")/.."

WORKER_NAME="${CLOUDFLARE_WORKER_NAME:-mcp-cf-bots}"
SKIP_SMOKE="${SKIP_SMOKE:-0}"

echo "==> npm ci"
npm ci

echo "==> typecheck + test"
npm run typecheck
npm test

VERSION="$(grep MCP_SERVER_VERSION wrangler.toml | head -1 | sed -n 's/.*= *"\([^"]*\)".*/\1/p')"
echo "==> wrangler deploy --name $WORKER_NAME (version ${VERSION:-unknown})"
npx wrangler deploy --name "$WORKER_NAME"

if [[ "$SKIP_SMOKE" != "1" ]]; then
  if [[ -z "${MCP_CF_BOTS_URL:-}" ]]; then
    echo "==> skip smoke (set MCP_CF_BOTS_URL to run ./scripts/smoke.sh)"
  else
    echo "==> smoke"
    ./scripts/smoke.sh
  fi
fi

echo "Done. version: $(grep MCP_SERVER_VERSION wrangler.toml | head -1)"
