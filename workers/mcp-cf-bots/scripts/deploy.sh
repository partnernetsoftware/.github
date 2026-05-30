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
ROUTES_FILE="$(mktemp)"
DEPLOY_LOG="$(mktemp)"
trap 'rm -f "$DEPLOY_LOG" "$ROUTES_FILE"' EXIT
./scripts/wrangler-routes-snippet.sh "${CLOUDFLARE_WORKER_DOMAIN:-}" >"$ROUTES_FILE"
DEPLOY_ARGS=(deploy --name "$WORKER_NAME")
if [[ -s "$ROUTES_FILE" ]]; then
  echo "==> custom domain route from CLOUDFLARE_WORKER_DOMAIN"
  DEPLOY_ARGS+=(-c wrangler.toml -c "$ROUTES_FILE")
else
  DEPLOY_ARGS+=(-c wrangler.toml)
fi
if [[ -n "${CLOUDFLARE_WORKER_DOMAIN:-}" ]]; then
  HOST="${CLOUDFLARE_WORKER_DOMAIN#https://}"
  HOST="${HOST#http://}"
  HOST="${HOST%%/*}"
  DEPLOY_ARGS+=(--var "MCP_PUBLIC_HOST:${HOST}")
fi
echo "==> wrangler ${DEPLOY_ARGS[*]} (version ${VERSION:-unknown})"
npx wrangler "${DEPLOY_ARGS[@]}" 2>&1 | tee "$DEPLOY_LOG"
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
    export MCP_EXPECT_VERSION="${VERSION:-}"
    export MCP_CF_BOTS_CUSTOM_URL="${CUSTOM_URL:-}"
    echo "==> verify-all-urls (workers.dev + custom if set)"
    MCP_CF_BOTS_URL="$VERIFY_URL" ./scripts/verify-all-urls.sh
  fi
fi

echo "Done. version: $(grep MCP_SERVER_VERSION wrangler.toml | head -1)"
