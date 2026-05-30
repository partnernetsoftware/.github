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
if [[ "${SKIP_INTEGRATION:-0}" != "1" ]]; then
  echo "==> integration (Miniflare DO/FTS; SKIP_INTEGRATION=1 to skip)"
  npm run test:integration
fi

VERSION="$(grep MCP_SERVER_VERSION wrangler.toml | head -1 | sed -n 's/.*= *"\([^"]*\)".*/\1/p')"
echo "==> wrangler deploy --name $WORKER_NAME (version ${VERSION:-unknown})"
DEPLOY_LOG="$(mktemp)"
trap 'rm -f "$DEPLOY_LOG"' EXIT
npx wrangler deploy --name "$WORKER_NAME" 2>&1 | tee "$DEPLOY_LOG"
WORKERS_DEV_URL="$(grep -oE 'https://[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.workers\.dev' "$DEPLOY_LOG" | tail -1 || true)"

if [[ "$SKIP_SMOKE" != "1" ]]; then
  CUSTOM_URL="${MCP_CF_BOTS_URL:-}"
  VERIFY_URL="${MCP_CF_BOTS_VERIFY_URL:-${WORKERS_DEV_URL:-}}"
  if [[ -z "$VERIFY_URL" && -n "${CLOUDFLARE_WORKER_DOMAIN:-}" ]]; then
    VERIFY_URL="https://${CLOUDFLARE_WORKER_DOMAIN%/}"
  fi
  if [[ -z "$VERIFY_URL" ]]; then
    VERIFY_URL="$CUSTOM_URL"
  fi
  if [[ -z "$VERIFY_URL" ]]; then
    echo "==> skip verify (no workers.dev URL from deploy and no MCP_CF_BOTS_VERIFY_URL)" >&2
  else
    export MCP_CF_BOTS_URL="$VERIFY_URL"
    export MCP_EXPECT_VERSION="${VERSION:-}"
    echo "==> verify-deploy against $VERIFY_URL"
    ./scripts/verify-deploy.sh
    if [[ -n "$CUSTOM_URL" && "$CUSTOM_URL" != "$VERIFY_URL" ]]; then
      echo "==> WARN: MCP_CF_BOTS_URL ($CUSTOM_URL) differs from verified deploy URL" >&2
      echo "    custom /health:" >&2
      curl -fsS "$CUSTOM_URL/health" 2>/dev/null | sed 's/^/      /' >&2 || echo "      (unreachable)" >&2
    fi
  fi
fi

echo "Done. version: $(grep MCP_SERVER_VERSION wrangler.toml | head -1)"
