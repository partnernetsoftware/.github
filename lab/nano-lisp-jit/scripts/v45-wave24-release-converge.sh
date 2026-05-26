#!/usr/bin/env bash
# Wave24: 发行面继续 — wave23 + 代际 verify-core/modules + scoped CI.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
NEXT_LO="$ROOT/lab/nano-lisp-jit/.build/v45-next-lisp-only.com"
CHAIN_LO="$ROOT/lab/nano-lisp-jit/.build/v45-chain-lo-next.com"
cd "$ROOT"
fail=0
touch "$EV"
echo "v45-wave24-release-converge=begin"
bash "$(dirname "$0")/v45-wave23-continue-converge.sh" || fail=$((fail + 1))

run_on_com() {
  local com=$1 plan=$2
  [ -x "$com" ] || return 1
  local out ec=0
  out=$("$com" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$plan.lisp" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=run ' \
    && return 0
  [ "$ec" = 0 ] || [ "$ec" = 42 ]
}

full_ok=1
pids=()
for spec in "next-lo:$NEXT_LO:verify-core" "next-lo:$NEXT_LO:selfhost-modules-full" \
            "chain-lo:$CHAIN_LO:verify-core"; do
  IFS=: read -r name com plan <<<"$spec"
  ( run_on_com "$com" "$plan" && echo "v45-wave24=ok $name plan=$plan" ) \
    || { echo "v45-wave24=fail $name plan=$plan"; exit 1; } &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || full_ok=0; done
if [ "$full_ok" = 1 ]; then
  echo "v45.factory.next_lisp_only_full=1" >>"$EV"
fi

bash "$(dirname "$0")/v45-scoped-ci.sh" || fail=$((fail + 1))
echo "v45.release.scoped_ci=1" >>"$EV"

COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  for p in factory-next-lisp-only-full runsh-release-anchor goal-v45-release-100; do
    "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp" >/dev/null \
      && echo "v45-wave24=ok plan=$p" \
      || { echo "v45-wave24=fail plan=$p"; fail=$((fail + 1)); }
  done
fi
bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$full_ok" = 1 ]; then
  {
    echo "v45.wave24.diffuse=1"
    echo "v45.wave24.rollup=1"
    echo "v45.v45.release.100=1"
  } >>"$EV"
  echo "v45-wave24-release-converge=done fail=0"
  exit 0
fi
echo "v45-wave24-release-converge=done fail=$fail full=$full_ok"
exit 1
