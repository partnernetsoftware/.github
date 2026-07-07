#!/usr/bin/env bash
# Quick connectivity + auth diagnosis for Cursor MCP.
set -euo pipefail
cd "$(dirname "$0")/.."

BASE="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
TOKEN="${MCP_CF_BOTS_TOKEN:-${SESSION_VAULT_TOKEN:-}}"
WN="${CLOUDFLARE_WORKER_NAME:-mcp-cf-bots}"

if [[ -z "$BASE" ]]; then
  echo "FAIL: set MCP_CF_BOTS_URL" >&2
  exit 1
fi
BASE="${BASE%/}"

echo "==> URL: $BASE"
echo "==> CLOUDFLARE_WORKER_NAME: $WN"
echo "==> MCP_CF_BOTS_TOKEN length: ${#TOKEN}"

curl -fsS "$BASE/health" | python3 -c "
import json,sys
h=json.load(sys.stdin)
print('health ok=', h.get('ok'), 'version=', h.get('version'))
f=h.get('features') or {}
print('fts=', f.get('fts'), 'cf_api_ready=', f.get('cf_api_ready'))
for line in h.get('production_hints') or []:
    print('hint:', line, file=sys.stderr)
if not f.get('cf_api_ready'):
    print('WARN: cf_api_ready false — ./scripts/sync-cf-api-secrets.sh', file=sys.stderr)
"

if [[ ${#TOKEN} -lt 32 ]]; then
  echo "FAIL: MCP_CF_BOTS_TOKEN is only ${#TOKEN} chars (looks like a placeholder, not cfb_*)." >&2
  echo "Fix: ./scripts/sync-vault-secret.sh then ./scripts/issue_token.sh <owner>" >&2
  exit 1
fi

CODE=$(curl -sS -o /tmp/mcp_me.json -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "$BASE/v1/me")
echo "==> GET /v1/me HTTP $CODE"
head -c 200 /tmp/mcp_me.json
echo

if [[ "$CODE" != "200" ]]; then
  echo "FAIL: token rejected. Admin: sync-vault-secret.sh; User: issue_token.sh" >&2
  exit 1
fi

CODE=$(curl -sS -o /tmp/mcp_init.json -w '%{http_code}' -X POST "$BASE/mcp" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"diag","version":"1"}}}')
echo "==> POST /mcp initialize HTTP $CODE"
head -c 200 /tmp/mcp_init.json
echo
[[ "$CODE" == "200" ]] || exit 1
python3 -c "
import json
d=json.load(open('/tmp/mcp_init.json'))
ins=(d.get('result') or {}).get('instructions') or ''
print('initialize.instructions length=', len(ins))
if len(ins) < 80:
    raise SystemExit('FAIL: missing agent instructions in initialize')
print('instructions preview:', ins[:120].replace(chr(10), ' '))
"
echo "OK: MCP auth + agent instructions"
