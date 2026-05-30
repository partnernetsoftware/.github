#!/usr/bin/env bash
# Poll wave task statuses until all done or timeout.
# Usage: poll-tasks.sh <catalog-path-from-repo-root> <wave-prefix> [max_seconds]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
CATALOG="${1:?catalog path, e.g. lab/nano-lisp-jit/squad/catalog-v4.yaml}"
PREFIX="${2:?task id prefix, e.g. wave14}"
MAX="${3:-300}"
DB="$(python3 - "$ROOT" "$CATALOG" <<'PY'
import sys
from pathlib import Path
sys.path.insert(0, str(Path(sys.argv[1]) / "tools/squad"))
from engine.context import SquadContext
ctx = SquadContext(project_root=Path(sys.argv[1]), catalog=Path(sys.argv[2]))
print(ctx.db_path)
PY
)"
end=$((SECONDS + MAX))
while [ "$SECONDS" -lt "$end" ]; do
  pending=$(sqlite3 "$DB" "SELECT COUNT(*) FROM tasks WHERE task_id LIKE '${PREFIX}%' AND status NOT IN ('done','failed','timeout');")
  echo "pending=$pending ($(date -u +%H:%M:%S))"
  if [ "$pending" = "0" ]; then
    echo "all terminal"
    exit 0
  fi
  sleep 10
done
echo "timeout after ${MAX}s"
exit 1
