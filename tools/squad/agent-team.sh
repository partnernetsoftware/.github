#!/usr/bin/env bash
# Launch squad agent team in parallel tmux sessions (commander + workers + reviewer).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SQUAD="$ROOT/tools/squad/squad.sh"
TMUX="tmux -f /exec-daemon/tmux.portal.conf"
POLL="${SQUAD_POLL_SEC:-8}"

cd "$ROOT"
"$SQUAD" resume --reason "agent-team wave"
"$SQUAD" dispatch --force --include-meta --max-tasks 4 || true

start_role() {
  local name="$1"
  shift
  if $TMUX has-session -t "=$name" 2>/dev/null; then
    $TMUX kill-session -t "$name"
  fi
  $TMUX new-session -d -s "$name" -c "$ROOT" -- "${SHELL:-bash}" -l
  $TMUX send-keys -t "$name:0.0" "$*" C-m
}

# Commander: supervise while-loop (complete|failed|timeout only)
start_role "squad-commander" \
  "while true; do $SQUAD supervise --once; code=\$?; $SQUAD sync-md --targets board 2>/dev/null || true; [ \"\$code\" = 0 ] || [ \"\$code\" = 1 ] || [ \"\$code\" = 3 ] && break; sleep $POLL; done; echo COMMANDER_EXIT=\$?"

start_role "squad-engineer-a" \
  "$ROOT/tools/squad/run-role-loop.sh engineer-a 50 $POLL"

start_role "squad-engineer-b" \
  "$ROOT/tools/squad/run-role-loop.sh engineer-b 50 $POLL"

start_role "squad-reviewer" \
  "while true; do $SQUAD worker-tick reviewer --json; $SQUAD verify --quick 2>/dev/null || $SQUAD verify; $SQUAD assess; tid=\$(python3 -c \"import json; s=json.load(open('lab/nano-lisp-jit/.squad/state.json')); print(s.get('assignments',{}).get('reviewer') or '')\"); if [ -n \"\$tid\" ]; then $SQUAD claim reviewer \"\$tid\" 2>/dev/null || true; $SQUAD reflect --note \"reviewer wave\"; $SQUAD sync-md --targets board,reflection; $SQUAD done reviewer \"\$tid\" --commit \$(git rev-parse --short HEAD) 2>/dev/null || true; fi; $SQUAD supervise --once | grep -q outcome=complete && break; sleep $POLL; done"

echo "Agent team tmux sessions:"
$TMUX ls 2>/dev/null | grep squad- || true
echo "Monitor: tmux -f /exec-daemon/tmux.portal.conf attach -t squad-commander"
