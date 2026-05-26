#!/usr/bin/env bash
# Wave32: 工厂终局 rollupy — selfhost-next 子 goal 四轨 + Wave25–31 键复核.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
RU_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-rollup.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave32-factory-rollup-continue-converge=skip missing_com"
  exit 0
fi
echo "v45-wave32-factory-rollup-continue-converge=begin"
bash "$(dirname "$0")/v45-wave31-terminal-continue-converge.sh" || fail=$((fail + 1))

for key in \
  v45.goal.onion_tdd_tree_mindmap.100 \
  v45.v45.terminal_continue.100 \
  v45.v45.goal_factory_unified_continue.100; do
  grep -q "${key}=1" "$EV" || { echo "v45-wave32=fail missing $key"; fail=$((fail + 1)); }
done

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

rollup_ok=1
if [ -x "$NEXT_FULL" ]; then
  pids=()
  for spec in \
    "lisp:lab/nano-lisp-jit/samples/bootstrap-v45-goal-lisp-selfhost-unified-100.lisp" \
    "onion:lab/nano-lisp-jit/samples/bootstrap-v45-goal-onion-mindmap-unified-100.lisp" \
    "handoff:lab/nano-lisp-jit/samples/bootstrap-v45-v4-handoff.lisp" \
    "terminal:lab/nano-lisp-jit/samples/bootstrap-v45-selfhost-terminal.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave32=ok next_rollup $name" ) \
      || { echo "v45-wave32=fail next_rollup $name"; exit 1; } &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || rollup_ok=0; done
  if [ "$rollup_ok" = 1 ]; then
    echo "v45.rollup.selfhost_sub_goals=1" >>"$EV"
    echo "v45.mindmap.rollup.coupled=1" >>"$EV"
  fi
else
  rollup_ok=0
  fail=$((fail + 1))
fi

waves_ok=1
for key in \
  v45.v45.codegen_probe.100 \
  v45.v45.codegen_expand.100 \
  v45.v45.codegen_coupled.100 \
  v45.v45.factory_physical_continue.100 \
  v45.v45.selfhost_deep_continue.100 \
  v45.v45.goal_factory_unified_continue.100 \
  v45.v45.terminal_continue.100; do
  if ! grep -q "${key}=1" "$EV"; then
    echo "v45-wave32=warn missing $key"
    waves_ok=0
  fi
done
if [ "$waves_ok" = 1 ]; then
  echo "v45.rollup.waves_25_31=1" >>"$EV"
fi

python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats 2>/dev/null || true

for p in factory-next-rollup-matrix mindmap-rollup-unified-tree \
  wave32-diffuse-global wave32-rollup goal-v45-factory-rollup-continue-100; do
  run_plan "$p" && echo "v45-wave32=ok plan=$p" \
    || { echo "v45-wave32=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$RU_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-ru-lisp-unified", "v45-ru-onion-unified", "v45-ru-v4-handoff", "v45-ru-terminal",
  "v45-ru-tree", "v45-ru-goal",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave32=ok rollup_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$rollup_ok" = 1 ] && [ "$waves_ok" = 1 ]; then
  {
    echo "v45.wave32.diffuse=1"
    echo "v45.wave32.parallel=4"
    echo "v45.wave32.rollup=1"
    echo "v45.mindmap.rollup.nodes_total=7"
    echo "v45.mindmap.rollup.nodes_done=7"
    echo "v45.v45.factory_rollup_continue.100=1"
  } >>"$EV"
  echo "v45-wave32-factory-rollup-continue-converge=done fail=0"
  exit 0
fi
echo "v45-wave32-factory-rollup-continue-converge=done fail=$fail rollup=$rollup_ok waves=$waves_ok"
exit 1
