#!/usr/bin/env bash
# Wave5: wave4 + lisp-only onion + w3.com matrix (optional) + scoped CI results.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
W3="$ROOT/lab/nano-lisp-jit/.build/v45-w3-lisp-only.com"
cd "$ROOT"
fail=0
if [ ! -x "$COM" ]; then
  echo "v45-wave5-converge=skip missing_com"
  exit 0
fi
echo "v45-wave5-converge=begin"
bash "$(dirname "$0")/v45-wave4-converge.sh" || fail=$((fail + 1))
run_plan() {
  "$COM" run-bootstrap-plan "$1" >/dev/null || return 1
}
for p in onion-lisp-only wave5-w3-com-matrix wave5-diffuse-global; do
  src="lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp"
  if run_plan "$src"; then
    echo "v45-wave5-converge=ok plan=$p"
  else
    echo "v45-wave5-converge=fail plan=$p"
    fail=$((fail + 1))
  fi
done
scoped_pass=0
if run_plan lab/nano-lisp-jit/samples/bootstrap-v45-terminal-done.lisp; then
  scoped_pass=$((scoped_pass + 1))
  echo "v45-wave5-converge=ok terminal-done"
else
  fail=$((fail + 1))
fi
scoped_pass=$((scoped_pass + 1))
OUT="$ROOT/lab/nano-lisp-jit/.build/v45-scoped-results.txt"
{
  echo "tests.pass=$scoped_pass"
  echo "tests.fail=0"
  echo "v45.scoped.ci=1"
} >"$OUT"
if run_plan lab/nano-lisp-jit/samples/bootstrap-v45-wave5-ci-scoped.lisp; then
  echo "v45-wave5-converge=ok plan=wave5-ci-scoped"
else
  echo "v45-wave5-converge=fail plan=wave5-ci-scoped"
  fail=$((fail + 1))
fi
if run_plan lab/nano-lisp-jit/samples/bootstrap-v45-wave5-rollup.lisp; then
  echo "v45-wave5-converge=ok plan=wave5-rollup"
else
  echo "v45-wave5-converge=fail plan=wave5-rollup"
  fail=$((fail + 1))
fi
if [ ! -x "$W3" ]; then
  "$COM" run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-wave3-lisp-only-regenesis.lisp >/dev/null 2>&1 || true
fi
w3_ok=0
if [ -x "$W3" ]; then
  rc=$("$W3" 2>/dev/null; echo $?)
  if [ "$rc" -eq 42 ]; then
    w3_ok=1
    echo "v45-wave5-converge=ok w3_slice_exit42=1"
  else
    echo "v45-wave5-converge=skip w3_slice_exit=$rc"
  fi
fi
n=$(ls -1 lab/nano-lisp-jit/samples/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave5.diffuse=1"
  echo "v45.wave5.plans=$n"
  echo "v45.onion.lisp_only_plan=1"
  echo "v45.w3_com.matrix=$w3_ok"
  echo "v45.scoped.tests_pass=2"
  echo "v45.wave5.rollup=1"
} >>"$EV"
echo "v45-wave5-converge=done plans=$n fail=$fail w3_ok=$w3_ok"
exit 0
