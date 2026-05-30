#!/usr/bin/env bash
# Admin: issue a per-user MCP/REST token (requires admin VAULT_TOKEN).
set -euo pipefail

OWNER="${1:-}"
LABEL="${2:-}"
if [[ -z "$OWNER" ]]; then
  echo "Usage: $0 <owner> [label]" >&2
  echo "  owner: tenant id (e.g. alice, team-acme)" >&2
  exit 1
fi

BASE="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
TOKEN="${MCP_CF_BOTS_TOKEN:-${SESSION_VAULT_TOKEN:-}}"
if [[ -z "$BASE" || -z "$TOKEN" ]]; then
  echo "Set MCP_CF_BOTS_URL and MCP_CF_BOTS_TOKEN (admin secret)" >&2
  exit 1
fi

BODY=$(python3 -c "import json,sys; print(json.dumps({'owner':sys.argv[1],'label':sys.argv[2] or None}))" "$OWNER" "$LABEL")

curl -sS -X POST "${BASE%/}/v1/admin/tokens" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$BODY" | python3 -m json.tool
