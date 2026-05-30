#!/usr/bin/env bash
# Smoke test against a deployed mcp-cf-bots worker.
set -euo pipefail

BASE_URL="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
TOKEN="${MCP_CF_BOTS_TOKEN:-${SESSION_VAULT_TOKEN:-}}"

if [[ -z "$BASE_URL" ]]; then
  echo "Set MCP_CF_BOTS_URL (worker root, no trailing slash)" >&2
  exit 1
fi

BASE_URL="${BASE_URL%/}"
echo "==> GET $BASE_URL/health"
curl -fsS "$BASE_URL/health" | tee /tmp/mcp-cf-bots-health.json
grep -q '"ok":true' /tmp/mcp-cf-bots-health.json

if [[ -n "$TOKEN" ]]; then
  echo "==> GET $BASE_URL/v1/me"
  curl -fsS -H "Authorization: Bearer $TOKEN" "$BASE_URL/v1/me" | tee /tmp/mcp-cf-bots-me.json
  grep -q '"role"' /tmp/mcp-cf-bots-me.json
else
  echo "==> skip /v1/me (no token)"
fi

echo "OK"
