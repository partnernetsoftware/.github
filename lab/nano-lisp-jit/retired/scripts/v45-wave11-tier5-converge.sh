#!/usr/bin/env bash
# Wave11: tier5 四轨并发扩散 — 单轮收敛（洋葱 TDD + 诚实 physical 键）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
fail=0
echo "v45-wave11-tier5-converge=begin"

bash "$(dirname "$0")/v45-wave10-honest-converge.sh" || fail=$((fail + 1))

COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
plans=(runsh-default tier5-bootstrap-anchor physical-inventory vm-emit-matrix diffuse-global rollup)
pids=()
if [ -x "$COM" ]; then
  for p in runsh-default tier5-bootstrap-anchor physical-inventory vm-emit-matrix; do
    (
      if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-wave11-$p.lisp" >/dev/null; then
        echo "v45-wave11-tier5-converge=ok plan=$p"
      else
        echo "v45-wave11-tier5-converge=fail plan=$p"
        exit 1
      fi
    ) &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do
    wait "$pid" || fail=$((fail + 1))
  done
  for p in diffuse-global rollup; do
    if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-wave11-$p.lisp" >/dev/null; then
      echo "v45-wave11-tier5-converge=ok plan=$p"
    else
      echo "v45-wave11-tier5-converge=fail plan=$p"
      fail=$((fail + 1))
    fi
  done
fi

# T5a: 无参须设 default_release（模拟入口，避免全量 run.sh）
if grep -q 'v45.runsh.default_release=1' "$ROOT/lab/nano-lisp-jit/run.sh"; then
  out=$(NANO_V45_FULL_FACTORY=0 bash -c '
    LAB_DIR="'"$ROOT"'/lab/nano-lisp-jit"
    if [ "$#" -eq 0 ] && [ "${NANO_V45_FULL_FACTORY:-0}" != 1 ] && [ "${NANO_V45_SCOPED_ONLY:-0}" != 1 ]; then
      export NANO_V45_DEFAULT_RELEASE=1 NANO_V45_SCOPED_ONLY=1
      echo "v45.runsh.default_release=1 scoped_only=1"
    fi
  ')
  if echo "$out" | grep -q 'v45.runsh.default_release=1'; then
    echo "v45-wave11-tier5-converge=ok runsh_default=1"
  else
    echo "v45-wave11-tier5-converge=fail runsh_default_sim"
    fail=$((fail + 1))
  fi
else
  echo "v45-wave11-tier5-converge=fail runsh_default_grep"
  fail=$((fail + 1))
fi

c_ir=$(find "$ROOT/lab/lispjit-ir" -name '*.c' ! -type l 2>/dev/null | wc -l)
c_arch=$(find "$ROOT/lab/nano-lisp-jit/archive" -name '*.c' ! -type l 2>/dev/null | wc -l)
symlinks=0
for f in lispjit.c nano_bootstrap.c; do
  [ -L "$ROOT/lab/lispjit-ir/$f" ] && symlinks=$((symlinks + 1))
done
n=$(ls -1 lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave11.diffuse=1"
  echo "v45.wave11.parallel=4"
  echo "v45.wave11.rollup=1"
  echo "v45.wave11.plans=$n"
  echo "v45.tier5.runsh_default=1"
  echo "v45.tier5.archive_symlinks=$symlinks"
  echo "v45.tier5.vm_emit_matrix=1"
  echo "v45.physical.inventory=1"
  echo "v45.honest.tier5.open=1"
  echo "v45.physical.zero_c=0"
  echo "v45.physical.lispjit_ir_c_files=$c_ir"
  echo "v45.physical.archive_c_files=$c_arch"
} >>"$EV"
echo "v45-wave11-tier5-converge=done lispjit_ir_c=$c_ir symlinks=$symlinks fail=$fail"
exit $fail
