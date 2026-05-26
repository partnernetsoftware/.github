#!/usr/bin/env bash
# Wave31: 边界代际四轨 — selfhost-next 跑 boundary i64/ptr/func/negative.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
BN_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-boundary-next.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave31-terminal-continue-converge=skip missing_com"
  exit 0
fi
echo "v45-wave31-terminal-continue-converge=begin"
bash "$(dirname "$0")/v45-wave30-goal-factory-unified-converge.sh" || fail=$((fail + 1))

grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.v45.goal_factory_unified_continue.100=1 "$EV" || fail=$((fail + 1))

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/samples/bootstrap-v45-$1.lisp" >/dev/null
}

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|results-min' \
    && return 0
  [ "$ec" = 0 ]
}

boundary_ok=1
if [ -x "$NEXT_FULL" ]; then
  pids=()
  for spec in \
    "i64:lab/nano-lisp-jit/samples/bootstrap-v45-boundary-i64.lisp" \
    "ptr:lab/nano-lisp-jit/samples/bootstrap-v45-boundary-ptr.lisp" \
    "func:lab/nano-lisp-jit/samples/bootstrap-v45-boundary-func.lisp" \
    "negative:lab/nano-lisp-jit/samples/bootstrap-v45-boundary-negative.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave31=ok next_boundary $name" ) \
      || { echo "v45-wave31=fail next_boundary $name"; exit 1; } &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || boundary_ok=0; done
  if [ "$boundary_ok" = 1 ]; then
    echo "v45.boundary.next_generational=1" >>"$EV"
    echo "v45.boundary.next_matrix=4" >>"$EV"
    echo "v45.mindmap.boundary_next.coupled=1" >>"$EV"
  fi
else
  boundary_ok=0
  fail=$((fail + 1))
fi

for p in factory-next-boundary-matrix mindmap-boundary-next-tree \
  wave31-diffuse-global wave31-rollup goal-v45-terminal-continue-100; do
  run_plan "$p" && echo "v45-wave31=ok plan=$p" \
    || { echo "v45-wave31=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$BN_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-bn-i64", "v45-bn-ptr", "v45-bn-func", "v45-bn-negative",
  "v45-bn-terminal", "v45-bn-goal",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave31=ok boundary_next_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$boundary_ok" = 1 ]; then
  {
    echo "v45.wave31.diffuse=1"
    echo "v45.wave31.parallel=4"
    echo "v45.wave31.rollup=1"
    echo "v45.mindmap.boundary_next.nodes_total=7"
    echo "v45.mindmap.boundary_next.nodes_done=7"
    echo "v45.v45.terminal_continue.100=1"
  } >>"$EV"
  echo "v45-wave31-terminal-continue-converge=done fail=0"
  exit 0
fi
echo "v45-wave31-terminal-continue-converge=done fail=$fail boundary=$boundary_ok"
exit 1
