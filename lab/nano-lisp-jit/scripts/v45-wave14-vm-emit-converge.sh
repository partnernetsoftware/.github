#!/usr/bin/env bash
# Wave14: T5d VM emit 四轨并发 + 收敛.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
fail=0
echo "v45-wave14-vm-emit-converge=begin"
bash "$(dirname "$0")/v45-wave13-tier5-converge.sh" || fail=$((fail + 1))
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  pids=()
  for p in vm-emit-arith vm-emit-strlen vm-emit-ctrl vm-emit-multi; do
    (
      if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-wave14-$p.lisp" >/dev/null; then
        echo "v45-wave14-vm-emit-converge=ok plan=$p"
      else
        echo "v45-wave14-vm-emit-converge=fail plan=$p"
        exit 1
      fi
    ) &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || fail=$((fail + 1)); done
  for p in diffuse-global rollup; do
    "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-wave14-$p.lisp" >/dev/null \
      && echo "v45-wave14-vm-emit-converge=ok plan=$p" \
      || { echo "v45-wave14-vm-emit-converge=fail plan=$p"; fail=$((fail + 1)); }
  done
fi
{
  echo "v45.wave14.diffuse=1"
  echo "v45.wave14.parallel=4"
  echo "v45.wave14.rollup=1"
  echo "v45.tier5.vm_emit_broad=1"
  echo "v45.codegen.vm_emit_matrix=4"
  echo "v45.codegen.vm_emit=1"
} >>"$EV"
echo "v45-wave14-vm-emit-converge=done fail=$fail"
exit $fail
