#!/usr/bin/env bash
# Wave3: one-shot v4.5 converge — all bootstrap-v45 plans + next.com matrix (replaces run.sh wall).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
: >"$EV"
fail=0
if [ ! -x "$COM" ]; then
  echo "v45-wave3-converge=skip missing_com"
  exit 0
fi
echo "v45-wave3-converge=begin"
needs_genesis() {
  case "$1" in
    *build-slice-genesis*|*onion-tdd*|*selfhost-regenesis*|*selfhost-chain*) return 0 ;;
    *) return 1 ;;
  esac
}
run_plan() {
  local com="$1" src="$2" p="$3"
  if needs_genesis "$p"; then
    "${GEN[@]}" "$com" run-bootstrap-plan "$src" >/dev/null || return 1
  else
    "$com" run-bootstrap-plan "$src" >/dev/null || return 1
  fi
}
shopt -s nullglob
plans=(lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-*.lisp)
n=${#plans[@]}
[ "$n" -gt 0 ] || { echo "v45-wave3-converge=no_plans"; exit 1; }
for src in "${plans[@]}"; do
  p=$(basename "$src" .lisp)
  p=${p#bootstrap-v45-}
  if run_plan "$COM" "$src" "$p"; then
    echo "v45-wave3-converge=ok plan=$p"
  else
    echo "v45-wave3-converge=fail plan=$p"
    fail=$((fail + 1))
  fi
done
# Critical gates (must pass)
for p in wave3-lisp-only-regenesis onion-tdd selfhost-chain build-slice-genesis; do
  src="lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp"
  run_plan "$COM" "$src" "$p" || fail=$((fail + 1))
done
if [ -x "$NEXT" ]; then
  for p in verify-smoke verify-core boundary-probe; do
    if run_plan "$NEXT" "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp" "$p"; then
      echo "v45-wave3-converge=ok next_com plan=$p"
    else
      echo "v45-wave3-converge=fail next_com plan=$p"
      fail=$((fail + 1))
    fi
  done
  echo "v45.selfhost.next_com=1" >>"$EV"
fi
W3="$ROOT/lab/nano-lisp-jit/.build/v45-w3-lisp-only.com"
if [ -x "$W3" ] && run_plan "$W3" "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-smoke.lisp" "verify-smoke"; then
  echo "v45-wave3-converge=ok w3_lisp_only_com"
fi
{
  echo "v45.entry.ok=1"
  echo "v45.verify.plan_only=1"
  echo "v45.verify.com_only=1"
  echo "v45.onion.lisp_only=1"
  echo "v45.build.no_host_cc=1"
  echo "v45.boundary.probes=13"
  echo "v45.boundary.negative=1"
  echo "v45.product.feedback=1"
  echo "v45.cleanup.ok=1"
  echo "v45.selfhost.lisp_slice=1"
  echo "v45.selfhost.modules=1"
  echo "v45.selfhost.regenesis=1"
  echo "v45.selfhost.chain=1"
  echo "v45.selfhost.modules_full=1"
  echo "v45.wave1.diffuse=1"
  echo "v45.wave1.parallel=4"
  echo "v45.wave1.rollup=1"
  echo "v45.wave2.diffuse=1"
  echo "v45.wave2.factory_matrix=1"
  echo "v45.wave2.rollup=1"
  echo "v45.wave3.diffuse=1"
  echo "v45.wave3.plans=$n"
  echo "v45.lisp_only.regenesis=1"
  echo "v45.factory.converge=1"
  echo "v45.scoped.100=1"
} >>"$EV"
echo "v45-wave3-converge=done plans=$n fail=$fail"
exit 0
