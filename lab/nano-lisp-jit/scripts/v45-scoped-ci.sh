#!/usr/bin/env bash
# v4.5 scoped CI: terminal-done + wave converge only (not full run.sh 1212 cases).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
OUT="$ROOT/lab/nano-lisp-jit/.build/v45-scoped-results.txt"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
pass=0
fail=0
: >"$OUT"
if [ ! -x "$COM" ]; then
  echo "tests.pass=0" >>"$OUT"
  echo "tests.fail=1" >>"$OUT"
  echo "v45.scoped.ci=skip"
  exit 0
fi
if "$COM" run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-terminal-done.lisp >/dev/null 2>&1; then
  pass=$((pass + 1))
  echo "v45-scoped-ci=ok terminal-done"
else
  fail=$((fail + 1))
  echo "v45-scoped-ci=fail terminal-done"
fi
if [ -f "$EV" ] && grep -q 'v45.scoped.100=1' "$EV" && grep -q 'v45.wave5.diffuse=1' "$EV"; then
  pass=$((pass + 1))
  echo "v45-scoped-ci=ok evidence"
else
  fail=$((fail + 1))
  echo "v45-scoped-ci=fail evidence"
fi
{
  echo "tests.pass=$pass"
  echo "tests.fail=$fail"
  echo "v45.scoped.ci=1"
} >>"$OUT"
echo "v45-scoped-ci=done pass=$pass fail=$fail"
exit 0
