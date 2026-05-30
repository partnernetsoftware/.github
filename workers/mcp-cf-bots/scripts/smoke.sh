#!/usr/bin/env bash
# Smoke test against a deployed mcp-cf-bots worker.
set -euo pipefail

BASE_URL="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
TOKEN="${MCP_CF_BOTS_TOKEN:-${SESSION_VAULT_TOKEN:-}}"
HEALTH_JSON="/tmp/mcp-cf-bots-health.json"
ME_JSON="/tmp/mcp-cf-bots-me.json"

fail_grep() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if ! grep -q "$pattern" "$file" 2>/dev/null; then
    echo "FAIL: $label" >&2
    echo "  expected JSON to match: $pattern" >&2
    echo "  response from $file:" >&2
    sed 's/^/    /' "$file" >&2
    exit 1
  fi
}

if [[ -z "$BASE_URL" ]]; then
  echo "Set MCP_CF_BOTS_URL (worker root, no trailing slash)" >&2
  exit 1
fi

BASE_URL="${BASE_URL%/}"
echo "==> GET $BASE_URL/health"
if ! curl -fsS "$BASE_URL/health" | tee "$HEALTH_JSON"; then
  echo "FAIL: GET $BASE_URL/health (curl exit $?)" >&2
  exit 1
fi

fail_grep "$HEALTH_JSON" '"ok":true' '/health ok:true'

if grep -q '"memory":true' "$HEALTH_JSON" 2>/dev/null; then
  echo "    memory: enabled"
  fail_grep "$HEALTH_JSON" '"fts":true' 'features.fts (required when memory enabled, 0.9.0+)'
else
  echo "    memory: disabled (skip fts check)"
fi

if grep -q '"available":true' "$HEALTH_JSON" 2>/dev/null; then
  echo "    cron_last: available"
elif grep -q '"cron_last"' "$HEALTH_JSON" 2>/dev/null; then
  echo "    cron_last: no report yet (available:false)"
fi

if [[ -n "$TOKEN" ]]; then
  echo "==> GET $BASE_URL/v1/me"
  ME_CODE="$(curl -sS -o "$ME_JSON" -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "$BASE_URL/v1/me" || echo "000")"
  if [[ "$ME_CODE" == "200" ]]; then
    cat "$ME_JSON"
    fail_grep "$ME_JSON" '"role"' '/v1/me role field'
  elif [[ "$ME_CODE" == "401" && "${SMOKE_REQUIRE_ME:-0}" != "1" ]]; then
    echo "WARN: /v1/me returned 401 (token may not match worker VAULT_TOKEN secret)" >&2
    cat "$ME_JSON" 2>/dev/null | sed 's/^/    /' >&2 || true
  else
    echo "FAIL: GET $BASE_URL/v1/me (HTTP $ME_CODE)" >&2
    sed 's/^/    /' "$ME_JSON" >&2 2>/dev/null || true
    exit 1
  fi
else
  echo "==> skip /v1/me (no token)"
fi

echo "OK"
