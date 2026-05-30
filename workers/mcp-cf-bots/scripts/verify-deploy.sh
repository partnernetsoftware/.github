#!/usr/bin/env bash
# Post-deploy connectivity + version gate (uses MCP_CF_BOTS_URL).
set -euo pipefail
cd "$(dirname "$0")/.."

BASE_URL="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
if [[ -z "$BASE_URL" ]]; then
  echo "Set MCP_CF_BOTS_URL (worker root, no trailing slash)" >&2
  exit 1
fi

EXPECTED="${MCP_EXPECT_VERSION:-}"
if [[ -z "$EXPECTED" ]]; then
  EXPECTED="$(grep MCP_SERVER_VERSION wrangler.toml | head -1 | sed -n 's/.*= *"\([^"]*\)".*/\1/p')"
fi
if [[ -z "$EXPECTED" ]]; then
  echo "FAIL: cannot read MCP_SERVER_VERSION from wrangler.toml" >&2
  exit 1
fi

echo "==> expected version: $EXPECTED"
sleep 2
./scripts/smoke.sh

HEALTH_JSON="/tmp/mcp-cf-bots-health.json"
REMOTE="$(python3 -c "import json; print(json.load(open('$HEALTH_JSON'))['version'])" 2>/dev/null || true)"
if [[ -z "$REMOTE" ]]; then
  echo "FAIL: /health missing version field" >&2
  exit 1
fi

API="$(python3 -c "import json; print(json.load(open('$HEALTH_JSON')).get('api_version',''))" 2>/dev/null || true)"
echo "==> remote version: $REMOTE api_version=${API:-?}"
if [[ -n "$API" && "$API" != "1.1" ]]; then
  echo "WARN: unexpected api_version=$API (expected 1.1)" >&2
fi
if [[ "$REMOTE" != "$EXPECTED" ]]; then
  echo "FAIL: version mismatch (remote=$REMOTE expected=$EXPECTED)" >&2
  exit 1
fi

echo "VERIFY_OK version=$REMOTE url=${BASE_URL%/}"
