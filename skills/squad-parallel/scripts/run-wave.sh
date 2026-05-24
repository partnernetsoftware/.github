#!/usr/bin/env bash
# Start a squad wave: resume, dispatch, agent-team (four tmux run-loops).
# Usage: run-wave.sh <catalog-path-from-repo-root> <reason>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
CATALOG="${1:?catalog path, e.g. lab/nano-lisp-jit/squad/catalog-v4.yaml}"
REASON="${2:-wave}"
SQUAD="$ROOT/tools/squad/squad.sh"
cd "$ROOT"
echo "squad-parallel: resume reason=$REASON catalog=$CATALOG"
"$SQUAD" --catalog "$CATALOG" resume --reason "$REASON"
"$SQUAD" --catalog "$CATALOG" dispatch --force --include-meta
echo "squad-parallel: starting agent-team (tmux: squad-commander, squad-engineer-a, ...)"
"$SQUAD" --catalog "$CATALOG" agent-team --auto-exec --auto-done --max-iter 40 --poll-interval 4
echo "squad-parallel: agent-team launched; poll with scripts/poll-tasks.sh"
