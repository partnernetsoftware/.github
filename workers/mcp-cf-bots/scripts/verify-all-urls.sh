#!/usr/bin/env bash
# Verify workers.dev + optional custom URL (MCP_CF_BOTS_URL) match wrangler version.
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="$(grep MCP_SERVER_VERSION wrangler.toml | head -1 | sed -n 's/.*= *"\([^"]*\)".*/\1/p')"
WORKER="${CLOUDFLARE_WORKER_NAME:-mcp-cf-bots}"
WORKERS_DEV="https://${WORKER}.kcc668.workers.dev"

check_url() {
  local label="$1"
  local url="$2"
  echo "==> $label: $url/health"
  local json
  json="$(curl -fsS "${url%/}/health")" || {
    echo "FAIL: unreachable $url" >&2
    return 1
  }
  local ver fts
  ver="$(python3 -c "import json,sys; d=json.loads(sys.argv[1]); print(d.get('version',''))" "$json")"
  fts="$(python3 -c "import json,sys; d=json.loads(sys.argv[1]); print((d.get('features') or {}).get('fts', False))" "$json")"
  echo "    version=$ver fts=$fts"
  if [[ "$ver" != "$VERSION" ]]; then
    echo "FAIL: $label version $ver != $VERSION" >&2
    return 1
  fi
  if [[ "$fts" != "True" ]]; then
    echo "FAIL: $label missing features.fts" >&2
    return 1
  fi
}

export MCP_EXPECT_VERSION="$VERSION"
export MCP_CF_BOTS_URL="$WORKERS_DEV"
./scripts/verify-deploy.sh

CUSTOM="${MCP_CF_BOTS_CUSTOM_URL:-${CLOUDFLARE_WORKER_DOMAIN:-}}"
if [[ -n "$CUSTOM" ]]; then
  [[ "$CUSTOM" == http* ]] || CUSTOM="https://${CUSTOM}"
  if [[ "${CUSTOM%/}" != "${WORKERS_DEV%/}" ]]; then
    export MCP_CF_BOTS_URL="$CUSTOM"
    ./scripts/verify-deploy.sh
  fi
fi

echo "ALL_URLS_OK version=$VERSION"
