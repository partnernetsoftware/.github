#!/usr/bin/env bash
# Migrate pre-0.8 MemoryDO blob → MemorySqliteDO (admin Bearer).
set -euo pipefail
cd "$(dirname "$0")/.."

BASE_URL="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
TOKEN="${MCP_CF_BOTS_TOKEN:-${SESSION_VAULT_TOKEN:-}}"
OWNER="${1:-${MCP_CF_BOTS_OWNER:-cloud-agent}}"
FORCE="${FORCE:-0}"

if [[ -z "$BASE_URL" || -z "$TOKEN" ]]; then
  echo "Set MCP_CF_BOTS_URL and MCP_CF_BOTS_TOKEN" >&2
  exit 1
fi

BASE_URL="${BASE_URL%/}"
BODY="{\"owner\":\"$OWNER\",\"force\":"
[[ "$FORCE" == "1" ]] && BODY+="true" || BODY+="false"
BODY+="}"

echo "==> POST $BASE_URL/v1/mem/migrate-legacy owner=$OWNER force=$FORCE"
curl -fsS -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$BODY" \
  "$BASE_URL/v1/mem/migrate-legacy"
echo
echo "OK"
