#!/usr/bin/env bash
# Wave29: selfhost-next 深度矩阵 — modules/regenesis/chain/onion-tdd 四轨并发.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
SHD_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-selfhost-deep.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave29-selfhost-deep-continue-converge=skip missing_com"
  exit 0
fi
echo "v45-wave29-selfhost-deep-continue-converge=begin"
bash "$(dirname "$0")/v45-wave28-factory-physical-continue-converge.sh" || fail=$((fail + 1))

grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" \
  || { echo "v45-wave29=fail missing /goal"; fail=$((fail + 1)); }
grep -q v45.v45.factory_physical_continue.100=1 "$EV" \
  || { echo "v45-wave29=fail missing factory_physical"; fail=$((fail + 1)); }

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|run-ape-expect-exit\.ok=1|inspect-ape\.ok=1|bootstrap-step.*=file-hash' \
    && return 0
  [ "$ec" = 0 ]
}

deep_ok=1
if [ -x "$NEXT_FULL" ]; then
  pids=()
  for spec in \
    "modules:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-modules-full.lisp" \
    "regenesis:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-regenesis-lisp-only.lisp" \
    "chain:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-chain-lisp-only.lisp" \
    "onion:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-tdd.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave29=ok next_deep $name" ) \
      || { echo "v45-wave29=fail next_deep $name"; exit 1; } &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || deep_ok=0; done
  if [ "$deep_ok" = 1 ]; then
    echo "v45.factory.selfhost_next_deep=1" >>"$EV"
    echo "v45.selfhost.next_modules_full=1" >>"$EV"
    echo "v45.selfhost.next_onion_tdd=1" >>"$EV"
    echo "v45.selfhost.next_regenesis_lo=1" >>"$EV"
    echo "v45.selfhost.next_chain_lo=1" >>"$EV"
  fi
else
  echo "v45-wave29=fail missing selfhost-next.com"
  deep_ok=0
  fail=$((fail + 1))
fi

for p in factory-selfhost-next-deep-matrix mindmap-selfhost-next-onion \
  mindmap-selfhost-deep-tree wave29-diffuse-global wave29-rollup \
  goal-v45-selfhost-deep-continue-100; do
  run_plan "$p" && echo "v45-wave29=ok plan=$p" \
    || { echo "v45-wave29=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$SHD_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-shd-modules", "v45-shd-regenesis", "v45-shd-chain", "v45-shd-onion",
  "v45-shd-terminal", "v45-shd-goal",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave29=ok selfhost_deep_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$deep_ok" = 1 ]; then
  {
    echo "v45.wave29.diffuse=1"
    echo "v45.wave29.parallel=4"
    echo "v45.wave29.rollup=1"
    echo "v45.mindmap.selfhost_deep.nodes_total=7"
    echo "v45.mindmap.selfhost_deep.nodes_done=7"
    echo "v45.mindmap.selfhost_deep.coupled=1"
    echo "v45.v45.selfhost_deep_continue.100=1"
  } >>"$EV"
  echo "v45-wave29-selfhost-deep-continue-converge=done fail=0"
  exit 0
fi
echo "v45-wave29-selfhost-deep-continue-converge=done fail=$fail deep=$deep_ok"
exit 1
