#!/usr/bin/env bash
# Orphan Vectorize GC via REST (admin Bearer).
set -euo pipefail
cd "$(dirname "$0")/.."

BASE_URL="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
TOKEN="${MCP_CF_BOTS_TOKEN:-${SESSION_VAULT_TOKEN:-}}"
OWNER="${1:-${MCP_CF_BOTS_OWNER:-cloud-agent}}"
DRY="${DRY_RUN:-0}"

if [[ -z "$BASE_URL" || -z "$TOKEN" ]]; then
  echo "Set MCP_CF_BOTS_URL and MCP_CF_BOTS_TOKEN" >&2
  exit 1
fi

BASE_URL="${BASE_URL%/}"
BODY="{\"owner\":\"$OWNER\",\"dry_run\":"
if [[ "$DRY" == "1" ]]; then
  BODY+="true"
else
  BODY+="false"
fi
BODY+="}"

echo "==> POST $BASE_URL/v1/mem/vector-gc owner=$OWNER dry_run=$DRY"
curl -fsS -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$BODY" \
  "$BASE_URL/v1/mem/vector-gc" | tee /tmp/mcp-cf-bots-vector-gc.json

echo "OK"
