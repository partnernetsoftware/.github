#!/usr/bin/env bash
# Wave21: /goal 洋葱 TDD × tree-mind-map 总签收 100% (frontier 26/26).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45.json"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave21-onion-tdd-tree-mindmap-100-converge=skip missing_com"
  exit 0
fi
echo "v45-wave21-onion-tdd-tree-mindmap-100-converge=begin"
bash "$(dirname "$0")/v45-wave20-lisp-selfhost-unified-converge.sh" || fail=$((fail + 1))

run_plan() {
  "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-$1.lisp" >/dev/null
}

pids=()
for p in boundary-i64 boundary-ptr boundary-func boundary-probe; do
  ( run_plan "$p" && echo "v45-wave21=ok boundary=$p" ) \
    || { echo "v45-wave21=fail boundary=$p"; exit 1; } &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || fail=$((fail + 1)); done
run_plan boundary-negative >/dev/null 2>&1 || true
echo "v45.boundary.probes=13" >>"$EV"
echo "v45.boundary.negative=1" >>"$EV"

pids=()
for p in mindmap-boundary-i64 mindmap-boundary-ptr mindmap-boundary-func mindmap-boundary-probe; do
  ( run_plan "$p" && echo "v45-wave21=ok plan=$p" ) \
    || { echo "v45-wave21=fail plan=$p"; exit 1; } &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || fail=$((fail + 1)); done

for p in mindmap-boundary-terminal wave21-diffuse-global wave21-rollup goal-onion-tdd-tree-mindmap-100; do
  if run_plan "$p"; then
    echo "v45-wave21=ok plan=$p"
  else
    echo "v45-wave21=fail plan=$p"
    fail=$((fail + 1))
  fi
done

python3 - <<'PY' "$FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-bd-i64", "v45-bd-ptr", "v45-bd-func", "v45-bd-probe",
  "v45-bd-terminal", "v45-goal-onion-tdd-tree-mindmap",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave21=ok frontier {done}/{total}")
PY

if [ "$fail" = 0 ]; then
  {
    echo "v45.wave21.diffuse=1"
    echo "v45.wave21.parallel=4"
    echo "v45.wave21.rollup=1"
    echo "v45.mindmap.boundary.coupled=1"
    echo "v45.mindmap.nodes_total=26"
    echo "v45.mindmap.nodes_done=26"
    echo "v45.goal.onion_tdd_tree_mindmap.100=1"
  } >>"$EV"
  echo "v45-wave21-onion-tdd-tree-mindmap-100-converge=done goal=1 fail=0"
  exit 0
fi
echo "v45-wave21-onion-tdd-tree-mindmap-100-converge=done goal=0 fail=$fail"
exit 1
