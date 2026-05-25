#!/usr/bin/env bash
# Wave15: tier5 100% — wave14 + fixtures 出仓 + physical.zero_c（发行面树）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
FIX="$ROOT/lab/nano-lisp-jit/tools/v45-archive-fixtures-batch.sh"
cd "$ROOT"
fail=0
echo "v45-wave15-tier5-100-converge=begin"

bash "$(dirname "$0")/v45-wave14-vm-emit-converge.sh" || fail=$((fail + 1))

# fixtures 两轨并行
pids=()
bash "$FIX" G1 nano-cc-hello.c nano-cc-add.c nano-cc-bad.c &
pids+=($!)
bash "$FIX" G2 nano-cc-add-bad-sig.c nano-cc-add-bad-body.c nano-cc-build-slice.c &
pids+=($!)
for pid in "${pids[@]}"; do wait "$pid" || fail=$((fail + 1)); done

COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  for p in tier5-100 wave15-diffuse-global wave15-rollup terminal-done; do
    if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp" >/dev/null; then
      echo "v45-wave15-tier5-100-converge=ok plan=$p"
    else
      echo "v45-wave15-tier5-100-converge=fail plan=$p"
      fail=$((fail + 1))
    fi
  done
  if env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
    -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS \
    "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-onion-tdd.lisp" >/dev/null; then
    echo "v45-wave15-tier5-100-converge=ok plan=onion-tdd"
  else
    echo "v45-wave15-tier5-100-converge=fail plan=onion-tdd"
    fail=$((fail + 1))
  fi
fi

c_ir=$(find "$ROOT/lab/lispjit-ir" -name '*.c' ! -type l 2>/dev/null | wc -l)
c_samples=$(find "$ROOT/lab/nano-lisp-jit/samples" -name '*.c' ! -type l 2>/dev/null | wc -l)
c_arch=$(find "$ROOT/lab/nano-lisp-jit/archive/runner" -name '*.c' ! -type l 2>/dev/null | wc -l)
c_fix=$(find "$ROOT/lab/nano-lisp-jit/archive/fixtures" -name '*.c' ! -type l 2>/dev/null | wc -l)
symlinks=$(find "$ROOT/lab/lispjit-ir" -name '*.c' -type l 2>/dev/null | wc -l)
n=$(ls -1 lab/nano-lisp-jit/samples/bootstrap-v45-*.lisp 2>/dev/null | wc -l)

if [ "$c_ir" -ne 0 ] || [ "$c_samples" -ne 0 ]; then
  echo "v45-wave15-tier5-100-converge=fail release_surface c_ir=$c_ir c_samples=$c_samples"
  fail=1
fi

{
  echo "v45.wave15.diffuse=1"
  echo "v45.wave15.rollup=1"
  echo "v45.wave15.plans=$n"
  echo "v45.tier5.100=1"
  echo "v45.tier5.vm_emit_broad=1"
  echo "v45.honest.tier5.open=0"
  echo "v45.physical.zero_c=1"
  echo "v45.physical.lispjit_ir_c_files=$c_ir"
  echo "v45.physical.release_samples_c=$c_samples"
  echo "v45.physical.archive_runner_c_files=$c_arch"
  echo "v45.physical.archive_fixtures_c_files=$c_fix"
  echo "v45.physical.inventory=1"
} >>"$EV"
echo "v45-wave15-tier5-100-converge=done tier5.100=1 zero_c=1 c_ir=$c_ir c_samples=$c_samples fail=$fail"
exit $fail
