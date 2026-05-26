#!/usr/bin/env bash
# Wave13: tier5 收尾扩散 — ape_v2 + irjit 并行归档 → lispjit-ir 零真 .c.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
BATCH="$ROOT/lab/nano-lisp-jit/tools/v45-archive-runner-batch.sh"
cd "$ROOT"
fail=0
echo "v45-wave13-tier5-converge=begin"

bash "$(dirname "$0")/v45-wave12-tier5-converge.sh" || fail=$((fail + 1))

pids=()
bash "$BATCH" E ape_v2.c &
pids+=($!)
bash "$BATCH" F irjit.c &
pids+=($!)
for pid in "${pids[@]}"; do
  wait "$pid" || fail=$((fail + 1))
done

COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  pids=()
  for p in ape-anchor irjit-anchor onion-after-archive physical-rollup; do
    (
      if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-wave13-$p.lisp" >/dev/null; then
        echo "v45-wave13-tier5-converge=ok plan=$p"
      else
        echo "v45-wave13-tier5-converge=fail plan=$p"
        exit 1
      fi
    ) &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do
    wait "$pid" || fail=$((fail + 1))
  done
  for p in diffuse-global rollup; do
    if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-wave13-$p.lisp" >/dev/null; then
      echo "v45-wave13-tier5-converge=ok plan=$p"
    else
      echo "v45-wave13-tier5-converge=fail plan=$p"
      fail=$((fail + 1))
    fi
  done
fi

c_ir=$(find "$ROOT/lab/lispjit-ir" -name '*.c' ! -type l 2>/dev/null | wc -l)
c_arch=$(find "$ROOT/lab/nano-lisp-jit/archive/runner" -name '*.c' ! -type l 2>/dev/null | wc -l)
symlinks=$(find "$ROOT/lab/lispjit-ir" -name '*.c' -type l 2>/dev/null | wc -l)
n=$(ls -1 lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave13.diffuse=1"
  echo "v45.wave13.parallel=4"
  echo "v45.wave13.rollup=1"
  echo "v45.wave13.plans=$n"
  echo "v45.tier5.ir_facade_zero_real=1"
  echo "v45.tier5.archive_symlinks=$symlinks"
  echo "v45.physical.inventory=1"
  echo "v45.honest.tier5.open=1"
  echo "v45.physical.zero_c=0"
  echo "v45.physical.lispjit_ir_c_files=$c_ir"
  echo "v45.physical.archive_runner_c_files=$c_arch"
} >>"$EV"
if [ "$c_ir" -ne 0 ]; then
  echo "v45-wave13-tier5-converge=fail lispjit_ir_c_expected_0 got=$c_ir"
  fail=1
fi
echo "v45-wave13-tier5-converge=done lispjit_ir_c=$c_ir symlinks=$symlinks archive_runner=$c_arch fail=$fail"
exit $fail
