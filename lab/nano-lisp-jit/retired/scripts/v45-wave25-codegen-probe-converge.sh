#!/usr/bin/env bash
# Wave25: lisp runner codegen 探针四轨 + 代际 onion + wave24 发行继续.
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
  echo "v45-wave25-codegen-probe-converge=skip missing_com"
  exit 0
fi
echo "v45-wave25-codegen-probe-converge=begin"
bash "$(dirname "$0")/v45-wave24-release-converge.sh" || fail=$((fail + 1))

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

probe_ok=1
pids=()
for p in codegen-lisp-slice-min codegen-lisp-slice-ir-exit codegen-lisp-ir-table; do
  ( run_plan "$p" && echo "v45-wave25=ok probe=$p" ) \
    || { echo "v45-wave25=fail probe=$p"; exit 1; } &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || probe_ok=0; done

next_lo_onion_ok() {
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_LO" run-bootstrap-plan \
      lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|run-ape-expect-exit\.ok=1' && return 0
  [ "$ec" = 0 ] || [ "$ec" = 42 ]
}
if [ -x "$NEXT_LO" ]; then
  if next_lo_onion_ok; then
    echo "v45-wave25=ok next_lo_onion"
    echo "v45.factory.next_lisp_only_onion=1" >>"$EV"
  else
    echo "v45-wave25=warn next_lo_onion"
  fi
fi

if [ "$probe_ok" = 1 ]; then
  echo "v45.codegen.lisp_runner_probe=1" >>"$EV"
  echo "v45.codegen.lisp_slices=3" >>"$EV"
fi

for p in mindmap-codegen-lisp-runner goal-v45-codegen-probe-100; do
  run_plan "$p" && echo "v45-wave25=ok plan=$p" \
    || { echo "v45-wave25=fail plan=$p"; fail=$((fail + 1)); }
done

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$probe_ok" = 1 ]; then
  {
    echo "v45.wave25.diffuse=1"
    echo "v45.wave25.parallel=4"
    echo "v45.wave25.rollup=1"
    echo "v45.v45.codegen_probe.100=1"
  } >>"$EV"
  echo "v45-wave25-codegen-probe-converge=done fail=0"
  exit 0
fi
echo "v45-wave25-codegen-probe-converge=done fail=$fail probe=$probe_ok"
exit 1
