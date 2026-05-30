#!/usr/bin/env bash
# Print /health production_hints and optional strict exit when hints remain.
set -euo pipefail
cd "$(dirname "$0")/.."

BASE="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
if [[ -z "$BASE" ]]; then
  echo "FAIL: set MCP_CF_BOTS_URL" >&2
  exit 1
fi
BASE="${BASE%/}"

json="$(curl -fsS "$BASE/health")"
python3 -c "
import json,sys
h=json.loads(sys.argv[1])
print('version=', h.get('version'), 'api_version=', h.get('api_version'))
f=h.get('features') or {}
print('cf_api_ready=', f.get('cf_api_ready'), 'mem_encrypt=', f.get('mem_encrypt'))
hints=h.get('production_hints') or []
if hints:
    print('production_hints:')
    for x in hints:
        print('  -', x)
else:
    print('production_hints: (none)')
strict = len(sys.argv) > 2 and sys.argv[2] == 'strict'
if hints and strict:
    sys.exit(1)
" "$json" "${VERIFY_PRODUCTION_STRICT:-}"
