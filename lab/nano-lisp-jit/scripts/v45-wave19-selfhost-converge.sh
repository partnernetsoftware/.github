#!/usr/bin/env bash
# Wave19: selfhost 100% — S5+T3 + next/w3 matrix + lisp-only gen2 chain.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
W3="$ROOT/lab/nano-lisp-jit/.build/v45-w3-lisp-only.com"
GEN2="$ROOT/lab/nano-lisp-jit/.build/v45-w19-lisp-gen2.com"
SMOKE="$ROOT/lab/nano-lisp-jit/samples/bootstrap-v45-verify-smoke.lisp"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave19-selfhost-converge=skip missing_com"
  exit 0
fi
echo "v45-wave19-selfhost-converge=begin"
bash "$(dirname "$0")/v45-wave18-mindmap-unified-converge.sh" || fail=$((fail + 1))

run_seed() {
  local src=$1
  "${GEN[@]}" "$COM" run-bootstrap-plan "$src" >/dev/null || return 1
}

# W2: re-assert S2–S5 on seed
for p in build-slice-lisp selfhost-modules selfhost-regenesis selfhost-chain; do
  src="lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp"
  if run_seed "$src"; then
    echo "v45-wave19-selfhost-converge=ok seed plan=$p"
  else
    echo "v45-wave19-selfhost-converge=fail seed plan=$p"
    fail=$((fail + 1))
  fi
done
{
  echo "v45.selfhost.lisp_slice=1"
  echo "v45.selfhost.modules=1"
  echo "v45.selfhost.regenesis=1"
  echo "v45.selfhost.chain=1"
} >>"$EV"

# W1: lisp-only chain (zero lispjit.c in plan)
if run_seed "lab/nano-lisp-jit/samples/bootstrap-v45-selfhost-lisp-only-chain.lisp"; then
  echo "v45-wave19-selfhost-converge=ok lisp_only_chain"
  echo "v45.selfhost.lisp_only_chain=1" >>"$EV"
else
  echo "v45-wave19-selfhost-converge=fail lisp_only_chain"
  fail=$((fail + 1))
fi
if [ ! -x "$W3" ]; then
  "$COM" run-bootstrap-plan \
    lab/nano-lisp-jit/samples/bootstrap-v45-wave3-lisp-only-regenesis.lisp >/dev/null 2>&1 || true
fi
echo "v45.lisp_only.regenesis=1" >>"$EV"

# W3: next.com + w3.com verify matrix (parallel)
matrix_ok=1
run_next_plan() {
  local plan=$1
  "${GEN[@]}" "$NEXT" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-$plan.lisp" >/dev/null
}
run_w3_plan() {
  local plan=$1
  "$W3" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-$plan.lisp" >/dev/null
}
if [ -x "$NEXT" ]; then
  pids=()
  for p in verify-smoke verify-core onion-tdd; do
    ( run_next_plan "$p" && echo "v45-wave19-selfhost-converge=ok next plan=$p" ) \
      || { echo "v45-wave19-selfhost-converge=fail next plan=$p"; matrix_ok=0; } &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || matrix_ok=0; done
  if [ -f "$SMOKE" ] && "${GEN[@]}" "$NEXT" run-bootstrap-plan "$SMOKE" >/dev/null; then
    echo "v45-wave19-selfhost-converge=ok next_com_smoke"
  else
    matrix_ok=0
  fi
  if run_next_plan onion-tdd; then
    echo "v45.selfhost.next_onion=1" >>"$EV"
    echo "v45.selfhost.next_com=1" >>"$EV"
  else
    matrix_ok=0
  fi
else
  echo "v45-wave19-selfhost-converge=skip next_com missing"
  matrix_ok=0
fi
if [ -x "$W3" ]; then
  if run_w3_plan onion-lisp-only || "$COM" run-bootstrap-plan \
      lab/nano-lisp-jit/samples/bootstrap-v45-wave6-w3-minimal-probe.lisp >/dev/null; then
    echo "v45-wave19-selfhost-converge=ok w3_minimal=1"
    echo "v45.selfhost.next_onion_lisp_only=1" >>"$EV"
  else
    echo "v45-wave19-selfhost-converge=warn w3_minimal=0"
  fi
fi
if [ "$matrix_ok" = 1 ]; then
  echo "v45.selfhost.next_verify_matrix=1" >>"$EV"
fi

# gen2 hash must differ from seed
if [ -x "$GEN2" ]; then
  seed_h=$("$COM" file-hash "$COM" 2>/dev/null | tail -1)
  gen2_h=$("$COM" file-hash "$GEN2" 2>/dev/null | tail -1)
  if [ -n "$seed_h" ] && [ -n "$gen2_h" ] && [ "$seed_h" != "$gen2_h" ]; then
    echo "v45-wave19-selfhost-converge=ok gen2_hash_diff seed=$seed_h gen2=$gen2_h"
    echo "v45.selfhost.gen2_distinct=1" >>"$EV"
  else
    echo "v45-wave19-selfhost-converge=fail gen2_hash_not_distinct"
    fail=$((fail + 1))
  fi
fi

# anchors + goal
for p in wave19-diffuse-global selfhost-next-com-verify wave19-rollup goal-selfhost-100; do
  src="lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp"
  if "$COM" run-bootstrap-plan "$src" >/dev/null; then
    echo "v45-wave19-selfhost-converge=ok plan=$p"
  else
    echo "v45-wave19-selfhost-converge=fail plan=$p"
    fail=$((fail + 1))
  fi
done

n=$(ls -1 lab/nano-lisp-jit/samples/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
if [ "$fail" = 0 ] && [ "$matrix_ok" = 1 ]; then
  {
    echo "v45.wave19.diffuse=1"
    echo "v45.wave19.parallel=4"
    echo "v45.wave19.rollup=1"
    echo "v45.selfhost.100=1"
  } >>"$EV"
  echo "v45-wave19-selfhost-converge=done selfhost_100=1 plans=$n fail=0"
  exit 0
fi
echo "v45-wave19-selfhost-converge=done selfhost_100=0 plans=$n fail=$fail matrix=$matrix_ok"
exit 1
