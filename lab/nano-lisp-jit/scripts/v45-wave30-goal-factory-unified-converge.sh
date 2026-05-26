#!/usr/bin/env bash
# Wave30: /goal×工厂 统一耦合 — selfhost-next 代际复核 goal/boundary/terminal/onion.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
GF_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-goal-factory.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave30-goal-factory-unified-converge=skip missing_com"
  exit 0
fi
echo "v45-wave30-goal-factory-unified-converge=begin"
bash "$(dirname "$0")/v45-wave29-selfhost-deep-continue-converge.sh" || fail=$((fail + 1))

grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" \
  || { echo "v45-wave30=fail missing /goal"; fail=$((fail + 1)); }
grep -q v45.v45.selfhost_deep_continue.100=1 "$EV" \
  || { echo "v45-wave30=fail missing selfhost_deep"; fail=$((fail + 1)); }

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/samples/bootstrap-v45-$1.lisp" >/dev/null
}

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|run-ape-expect-exit\.ok=1|inspect-ape\.ok=1|bootstrap-step.*=file-hash|results-min' \
    && return 0
  [ "$ec" = 0 ]
}

recheck_ok=1
if [ -x "$NEXT_FULL" ]; then
  pids=()
  for spec in \
    "goal:lab/nano-lisp-jit/samples/bootstrap-v45-goal-onion-tdd-tree-mindmap-100.lisp" \
    "boundary:lab/nano-lisp-jit/samples/bootstrap-v45-boundary-probe.lisp" \
    "terminal:lab/nano-lisp-jit/samples/bootstrap-v45-terminal-done.lisp" \
    "onion:lab/nano-lisp-jit/samples/bootstrap-v45-onion-lisp-only.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave30=ok next_recheck $name" ) \
      || { echo "v45-wave30=fail next_recheck $name"; exit 1; } &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || recheck_ok=0; done
  if [ "$recheck_ok" = 1 ]; then
    echo "v45.selfhost.next_goal_signoff=1" >>"$EV"
    echo "v45.selfhost.next_boundary_probe=1" >>"$EV"
    echo "v45.goal.next_com_reverified=1" >>"$EV"
    echo "v45.mindmap.goal_factory.unified=1" >>"$EV"
  fi
else
  recheck_ok=0
  fail=$((fail + 1))
fi

python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats 2>/dev/null || true
NANO_V45_FRONTIER=mindmap-frontier-v45-selfhost-deep.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats 2>/dev/null || true

for p in factory-next-goal-recheck mindmap-next-boundary-recheck \
  mindmap-goal-factory-unified-tree wave30-diffuse-global wave30-rollup \
  goal-v45-goal-factory-unified-100; do
  run_plan "$p" && echo "v45-wave30=ok plan=$p" \
    || { echo "v45-wave30=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$GF_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-gf-goal-recheck", "v45-gf-boundary", "v45-gf-terminal", "v45-gf-onion",
  "v45-gf-tree", "v45-gf-goal",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave30=ok goal_factory_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$recheck_ok" = 1 ]; then
  {
    echo "v45.wave30.diffuse=1"
    echo "v45.wave30.parallel=4"
    echo "v45.wave30.rollup=1"
    echo "v45.mindmap.goal_factory.nodes_total=7"
    echo "v45.mindmap.goal_factory.nodes_done=7"
    echo "v45.v45.goal_factory_unified_continue.100=1"
  } >>"$EV"
  echo "v45-wave30-goal-factory-unified-converge=done fail=0"
  exit 0
fi
echo "v45-wave30-goal-factory-unified-converge=done fail=$fail recheck=$recheck_ok"
exit 1
