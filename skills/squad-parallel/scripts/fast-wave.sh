#!/usr/bin/env bash
# Parallel-friendly wave kickoff: resume + dispatch only (no agent-team).
# Usage: fast-wave.sh <catalog-path-from-repo-root> <reason>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
CATALOG="${1:?catalog path, e.g. lab/nano-lisp-jit/squad/catalog-v4.yaml}"
REASON="${2:-wave}"
SQUAD="$ROOT/tools/squad/squad.sh"
cd "$ROOT"
echo "squad-parallel: fast-wave resume=$REASON (implement touch_paths, then run.sh once)"
"$SQUAD" --catalog "$CATALOG" resume --reason "$REASON"
"$SQUAD" --catalog "$CATALOG" dispatch --force --include-meta
"$SQUAD" --catalog "$CATALOG" assess || true
echo "Next: parallel A/B per v4/PARALLEL.md → bash lab/nano-lisp-jit/run.sh → done → assess"
