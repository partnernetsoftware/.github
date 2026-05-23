#!/usr/bin/env bash
# Worker/meta role while-loop — exit on complete|failed|timeout signal or max iterations.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SQUAD="$ROOT/tools/squad/squad.sh"
ROLE="${1:?role id}"
MAX_ITER="${2:-40}"
POLL_SEC="${3:-5}"

cd "$ROOT"

json_field() {
  python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('$1',''))" 2>/dev/null || echo ""
}

echo "[$ROLE] run-role-loop start max_iter=$MAX_ITER"
for ((i = 1; i <= MAX_ITER; i++)); do
  tick="$("$SQUAD" worker-tick "$ROLE" --json 2>/dev/null)" || {
    echo "[$ROLE] worker-tick failed"
    sleep "$POLL_SEC"
    continue
  }
  action="$(printf '%s' "$tick" | json_field action)"
  task_id="$(printf '%s' "$tick" | json_field task_id)"
  echo "[$ROLE] iter=$i action=$action task=${task_id:-—}"

  case "$action" in
    halt)
      echo "[$ROLE] halt"
      exit 1
      ;;
    idle|wait_dispatch)
      sleep "$POLL_SEC"
      ;;
    claim)
      tid="$task_id"
      if [ -z "$tid" ]; then
        tid="$(printf '%s' "$tick" | python3 -c "import json,sys; d=json.load(sys.stdin); p=d.get('pending') or []; print(p[0] if p else '')")"
      fi
      if [ -n "$tid" ]; then
        "$SQUAD" claim "$ROLE" "$tid" || true
        echo "[$ROLE] claimed $tid — implement work then: squad verify && squad done $ROLE $tid --commit \$(git rev-parse --short HEAD)"
      fi
      sleep "$POLL_SEC"
      ;;
    work|timeout)
      echo "[$ROLE] needs implementation (verify + done or fail)"
      sleep "$POLL_SEC"
      ;;
    *)
      sleep "$POLL_SEC"
      ;;
  esac

  sup="$("$SQUAD" supervise --once 2>&1 | tail -1)" || true
  if printf '%s' "$sup" | grep -q 'outcome=complete'; then
    "$SQUAD" signal "$ROLE" complete --reason "signoff complete"
    echo "[$ROLE] squad complete"
    exit 0
  fi
  if printf '%s' "$sup" | grep -q 'outcome=failed'; then
    echo "[$ROLE] squad failed"
    exit 1
  fi
done
echo "[$ROLE] max iterations"
exit 2
