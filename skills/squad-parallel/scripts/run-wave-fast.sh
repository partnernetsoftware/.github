#!/usr/bin/env bash
# Same as run-wave.sh but documents fast-verify path (agent-team uses verify --quick).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
CATALOG="${1:?catalog}"
REASON="${2:-wave}"
exec "$ROOT/skills/squad-parallel/scripts/run-wave.sh" "$CATALOG" "$REASON"
