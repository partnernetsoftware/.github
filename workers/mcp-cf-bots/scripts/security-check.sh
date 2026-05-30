#!/usr/bin/env bash
# Static hygiene + security checks (no deploy). Exit non-zero on failures.
set -euo pipefail
cd "$(dirname "$0")/.."
FAIL=0

check() {
  if ! eval "$2"; then
    echo "FAIL: $1" >&2
    FAIL=1
  else
    echo "OK: $1"
  fi
}

check "cron not under handleMemRest only" \
  '! grep -q "v1/admin/mem/cron" src/mem-rest.ts'

check "cron in admin-api" \
  'grep -q "v1/admin/mem/cron" src/admin-api.ts'

check "mem_put rate limited" \
  'grep -q "checkMemRateLimit.*mem_put" src/mem-tools.ts'

check "mem_delete rate limited" \
  'grep -q "checkMemRateLimit.*mem_delete" src/mem-tools.ts'

check "safeEqual for vault bearer" \
  'grep -q safeEqual src/auth.ts'

check "ownerFromHttpRequest shared" \
  'grep -q ownerFromHttpRequest src/owner-scope.ts'

check "MEMORY_LEGACY binding removed" \
  '! grep -q MEMORY_LEGACY wrangler.toml'

check "MemoryDO class deleted (v5 migration)" \
  'grep -q deleted_classes wrangler.toml && grep -q MemoryDO wrangler.toml'

check "migrate-legacy returns 410 only" \
  'grep -q "migrate-legacy removed" src/mem-rest.ts'

exit "$FAIL"
