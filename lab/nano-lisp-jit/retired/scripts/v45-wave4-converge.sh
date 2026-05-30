#!/usr/bin/env bash
# Wave4: wave3 matrix + next.com onion-tdd + tier3/squad anchors (one-shot).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
if [ ! -x "$COM" ]; then
  echo "v45-wave4-converge=skip missing_com"
  exit 0
fi
echo "v45-wave4-converge=begin"
# Wave3 body (all v45 plans + evidence baseline)
bash "$(dirname "$0")/v45-wave3-converge.sh" || fail=$((fail + 1))
needs_genesis() {
  case "$1" in
    *build-slice-genesis*|*onion-tdd*|*selfhost-regenesis*|*selfhost-chain*|*next-onion*) return 0 ;;
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
# Wave4-only plans (tier3 anchor, squad plan-only, diffuse/rollup)
for p in wave4-tier3-anchor wave4-squad-plan wave4-diffuse-global wave4-rollup; do
  src="lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp"
  if run_plan "$COM" "$src" "$p"; then
    echo "v45-wave4-converge=ok plan=$p"
  else
    echo "v45-wave4-converge=fail plan=$p"
    fail=$((fail + 1))
  fi
done
if [ -x "$NEXT" ]; then
  for p in onion-tdd verify-core entry boundary-probe; do
    if run_plan "$NEXT" "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp" "$p"; then
      echo "v45-wave4-converge=ok next_com plan=$p"
    else
      echo "v45-wave4-converge=fail next_com plan=$p"
      fail=$((fail + 1))
    fi
  done
  if run_plan "$NEXT" "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-tdd.lisp" "next-onion"; then
    echo "v45-wave4-converge=ok next_com_onion_tdd=1"
  else
    echo "v45-wave4-converge=fail next_com_onion_tdd"
    fail=$((fail + 1))
  fi
  echo "v45.selfhost.next_onion=1" >>"$EV"
fi
shopt -s nullglob
n=$(ls -1 lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave4.diffuse=1"
  echo "v45.wave4.plans=$n"
  echo "v45.tier3.runner_archived=1"
  echo "v45.tier3.plan_no_c=1"
  echo "v45.squad.plan_no_sh=1"
  echo "v45.wave4.rollup=1"
} >>"$EV"
echo "v45-wave4-converge=done plans=$n fail=$fail"
exit 0
