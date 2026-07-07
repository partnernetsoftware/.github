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
# Admin Bearer must match Worker VAULT_TOKEN secret (see scripts/sync-vault-secret.sh).
TOKEN="${MCP_CF_BOTS_ADMIN_TOKEN:-${VAULT_TOKEN:-${MCP_CF_BOTS_TOKEN:-${SESSION_VAULT_TOKEN:-}}}}"
if [[ -z "$BASE" || -z "$TOKEN" ]]; then
  echo "Set MCP_CF_BOTS_URL and admin token (VAULT_TOKEN or MCP_CF_BOTS_ADMIN_TOKEN)" >&2
  echo "If /v1/me returns 401, run: ./scripts/sync-vault-secret.sh" >&2
  exit 1
fi
if [[ ${#TOKEN} -lt 32 ]]; then
  echo "WARN: token looks too short (${#TOKEN} chars) — not a valid admin/cfb token?" >&2
fi

BODY=$(python3 -c "import json,sys; print(json.dumps({'owner':sys.argv[1],'label':sys.argv[2] or None}))" "$OWNER" "$LABEL")

curl -sS -X POST "${BASE%/}/v1/admin/tokens" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$BODY" | python3 -m json.tool
