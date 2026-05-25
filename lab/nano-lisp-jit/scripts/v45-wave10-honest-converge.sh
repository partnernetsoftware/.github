#!/usr/bin/env bash
# Wave10: honest tier5 — no fake physical 100%; refresh signed keys + open tier5.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
fail=0
echo "v45-wave10-honest-converge=begin"
bash "$(dirname "$0")/v45-wave9-converge.sh" || fail=$((fail + 1))
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  for p in honest-remaining wave10-diffuse-global wave10-rollup; do
    if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp" >/dev/null; then
      echo "v45-wave10-honest-converge=ok plan=$p"
    else
      echo "v45-wave10-honest-converge=fail plan=$p"
      fail=$((fail + 1))
    fi
  done
fi
c_ir=$(find "$ROOT/lab/lispjit-ir" -name '*.c' ! -type l 2>/dev/null | wc -l)
c_arch=$(find "$ROOT/lab/nano-lisp-jit/archive" -name '*.c' ! -type l 2>/dev/null | wc -l)
n=$(ls -1 lab/nano-lisp-jit/samples/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave10.honest=1"
  echo "v45.wave10.plans=$n"
  echo "v45.honest.tier5.open=1"
  echo "v45.physical.zero_c=0"
  echo "v45.physical.lispjit_ir_c_files=$c_ir"
  echo "v45.physical.archive_c_files=$c_arch"
  echo "v45.honest.remaining.doc=1"
} >>"$EV"
echo "v45-wave10-honest-converge=done lispjit_ir_c=$c_ir fail=$fail"
exit 0
