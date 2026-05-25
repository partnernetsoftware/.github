#!/usr/bin/env bash
# v4.5 factory slim: scoped-only factory (no v4 1200+ run_case wall).
# Usage: NANO_V45_SCOPED_ONLY=1 bash lab/nano-lisp-jit/scripts/v45-factory-slim.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
RES="$ROOT/lab/nano-lisp-jit/.build/results.txt"
CONVERGE="$ROOT/lab/nano-lisp-jit/scripts/v45-wave7-converge.sh"
cd "$ROOT"
export NANO_V45_SCOPED_ONLY=1
: >"$RES"
echo "# v45 factory slim (scoped only)" >>"$RES"
if [ -x "$CONVERGE" ]; then
  bash "$CONVERGE" 2>&1 | tee -a "$RES"
fi
if [ -f "$EV" ]; then
  grep -E '^v45\.' "$EV" >>"$RES" || true
fi
if [ -f "$ROOT/lab/nano-lisp-jit/.build/v45-scoped-results.txt" ]; then
  cat "$ROOT/lab/nano-lisp-jit/.build/v45-scoped-results.txt" >>"$RES"
fi
echo "v45.factory.slim=1" >>"$EV"
echo "v45-factory-slim=done"
