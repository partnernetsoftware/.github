#!/usr/bin/env bash
# Verify /health reports cf_api_ready and cron_vector_gc when CF API secrets are configured.
set -euo pipefail
cd "$(dirname "$0")/.."

BASE="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
if [[ -z "$BASE" ]]; then
  echo "FAIL: set MCP_CF_BOTS_URL" >&2
  exit 1
fi
BASE="${BASE%/}"

json="$(curl -fsS "$BASE/health")"
ready="$(python3 -c "import json,sys; f=json.loads(sys.argv[1]).get('features') or {}; print(f.get('cf_api_ready', False))" "$json")"
gc="$(python3 -c "import json,sys; f=json.loads(sys.argv[1]).get('features') or {}; print(f.get('cron_vector_gc', False))" "$json")"
echo "cf_api_ready=$ready cron_vector_gc=$gc"

if [[ "$ready" != "True" ]]; then
  echo "WARN: cf_api_ready false — run ./scripts/sync-cf-api-secrets.sh" >&2
  exit 1
fi
echo "OK: CF API secrets active on Worker"
