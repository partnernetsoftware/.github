#!/usr/bin/env bash
# Wave26: wave25 + VM emit 双轨 + next-lo 最小 onion 探针.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_LO="$ROOT/lab/nano-lisp-jit/.build/v45-next-lisp-only.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave26-codegen-expand-converge=skip missing_com"
  exit 0
fi
echo "v45-wave26-codegen-expand-converge=begin"
bash "$(dirname "$0")/v45-wave25-codegen-probe-converge.sh" || fail=$((fail + 1))

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/samples/bootstrap-v45-$1.lisp" >/dev/null
}

probe_ok=1
pids=()
for p in codegen-lisp-vm-arith codegen-lisp-vm-strlen; do
  ( run_plan "$p" && echo "v45-wave26=ok probe=$p" ) \
    || { echo "v45-wave26=fail probe=$p"; exit 1; } &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || probe_ok=0; done

if [ -x "$NEXT_LO" ]; then
  if "${GEN[@]}" "$NEXT_LO" run-bootstrap-plan \
      lab/nano-lisp-jit/samples/bootstrap-v45-onion-next-lo-minimal.lisp >/dev/null 2>&1; then
    echo "v45-wave26=ok next_lo_minimal"
    echo "v45.factory.next_lisp_only_onion_minimal=1" >>"$EV"
  else
    echo "v45-wave26=fail next_lo_minimal"
    fail=$((fail + 1))
  fi
fi

if [ "$probe_ok" = 1 ]; then
  echo "v45.codegen.lisp_slices=5" >>"$EV"
fi

for p in mindmap-codegen-expand goal-v45-codegen-expand-100; do
  run_plan "$p" && echo "v45-wave26=ok plan=$p" \
    || { echo "v45-wave26=fail plan=$p"; fail=$((fail + 1)); }
done

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$probe_ok" = 1 ]; then
  {
    echo "v45.wave26.diffuse=1"
    echo "v45.wave26.parallel=4"
    echo "v45.wave26.rollup=1"
    echo "v45.v45.codegen_expand.100=1"
  } >>"$EV"
  echo "v45-wave26-codegen-expand-converge=done fail=0"
  exit 0
fi
echo "v45-wave26-codegen-expand-converge=done fail=$fail probe=$probe_ok"
exit 1
