#!/usr/bin/env bash
# Wave9: warehouse 100% = endgame + factory slim path + wave9 plans.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
fail=0
echo "v45-wave9-converge=begin"
bash "$(dirname "$0")/v45-wave8-converge.sh" || fail=$((fail + 1))
export NANO_V45_SCOPED_ONLY=1
bash "$(dirname "$0")/v45-factory-slim.sh" 2>&1 | tail -3 || fail=$((fail + 1))
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  for p in factory-100 warehouse-100 wave9-diffuse-global wave9-rollup; do
    if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp" >/dev/null; then
      echo "v45-wave9-converge=ok plan=$p"
    else
      echo "v45-wave9-converge=fail plan=$p"
      fail=$((fail + 1))
    fi
  done
fi
n=$(ls -1 lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave9.diffuse=1"
  echo "v45.wave9.plans=$n"
  echo "v45.factory.100=1"
  echo "v45.warehouse.100=1"
  echo "v45.runsh.scoped_guard=1"
  echo "v45.wave9.rollup=1"
} >>"$EV"
echo "v45-wave9-converge=done plans=$n fail=$fail"
exit 0
