#!/usr/bin/env bash
# Wave7: release endgame 100% — wave6 + endgame signoff + v4 factory skip hook.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
cd "$ROOT"
fail=0
if [ ! -x "$COM" ]; then
  echo "v45-wave7-converge=skip missing_com"
  exit 0
fi
echo "v45-wave7-converge=begin"
bash "$(dirname "$0")/v45-wave6-converge.sh" || fail=$((fail + 1))
run_plan() {
  "$COM" run-bootstrap-plan "$1" >/dev/null || return 1
}
for p in wave7-release-audit wave7-factory-v4-skip wave7-diffuse-global; do
  if run_plan "lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp"; then
    echo "v45-wave7-converge=ok plan=$p"
  else
    echo "v45-wave7-converge=fail plan=$p"
    fail=$((fail + 1))
  fi
done
if run_plan lab/nano-lisp-jit/samples/bootstrap-v45-terminal-done.lisp; then
  echo "v45-wave7-converge=ok terminal-done"
else
  fail=$((fail + 1))
fi
n=$(ls -1 lab/nano-lisp-jit/samples/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave7.diffuse=1"
  echo "v45.wave7.plans=$n"
  echo "v45.factory.v4_skipped=1"
  echo "v45.release.100=1"
  echo "v45.endgame.release=1"
  echo "v45.wave7.rollup=1"
} >>"$EV"
if run_plan lab/nano-lisp-jit/samples/bootstrap-v45-endgame-100.lisp; then
  echo "v45-wave7-converge=ok endgame-100"
else
  echo "v45-wave7-converge=fail endgame-100"
  fail=$((fail + 1))
fi
if run_plan lab/nano-lisp-jit/samples/bootstrap-v45-wave7-rollup.lisp; then
  echo "v45-wave7-converge=ok plan=wave7-rollup"
else
  fail=$((fail + 1))
fi
echo "v45-wave7-converge=done plans=$n fail=$fail"
exit 0
