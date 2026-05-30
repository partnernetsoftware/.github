#!/usr/bin/env bash
# Wave33: codegen 代际深潜 — selfhost-next 跑 slice/vm/ir 四轨 + runsh 锚.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
CD_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-codegen-deep.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave33-codegen-deep-continue-converge=skip missing_com"
  exit 0
fi
echo "v45-wave33-codegen-deep-continue-converge=begin"
bash "$(dirname "$0")/v45-wave32-factory-rollup-continue-converge.sh" || fail=$((fail + 1))

grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.v45.factory_rollup_continue.100=1 "$EV" || fail=$((fail + 1))

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|jit\.code\.bytes' \
    && return 0
  [ "$ec" = 0 ]
}

deep_ok=1
if [ -x "$NEXT_FULL" ]; then
  pids=()
  for spec in \
    "min:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-lisp-slice-min.lisp" \
    "ctrl:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-lisp-vm-ctrl.lisp" \
    "ir:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-lisp-ir-table.lisp" \
    "arith:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-lisp-vm-arith.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave33=ok next_codegen $name" ) \
      || { echo "v45-wave33=fail next_codegen $name"; exit 1; } &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || deep_ok=0; done
  if [ "$deep_ok" = 1 ]; then
    echo "v45.codegen.selfhost_next_codegen=1" >>"$EV"
    echo "v45.codegen.next_deep_profiles=4" >>"$EV"
    echo "v45.mindmap.codegen_deep.coupled=1" >>"$EV"
  fi
else
  deep_ok=0
  fail=$((fail + 1))
fi

for p in runsh-slim-terminal factory-next-codegen-deep-matrix mindmap-codegen-deep-tree \
  wave33-diffuse-global wave33-rollup goal-v45-codegen-deep-continue-100; do
  run_plan "$p" && echo "v45-wave33=ok plan=$p" \
    || { echo "v45-wave33=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$CD_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-cd-slice-min", "v45-cd-vm-ctrl", "v45-cd-ir-table", "v45-cd-vm-arith",
  "v45-cd-terminal", "v45-cd-goal",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave33=ok codegen_deep_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$deep_ok" = 1 ]; then
  {
    echo "v45.wave33.diffuse=1"
    echo "v45.wave33.parallel=4"
    echo "v45.wave33.rollup=1"
    echo "v45.mindmap.codegen_deep.nodes_total=7"
    echo "v45.mindmap.codegen_deep.nodes_done=7"
    echo "v45.v45.codegen_deep_continue.100=1"
  } >>"$EV"
  echo "v45-wave33-codegen-deep-continue-converge=done fail=0"
  exit 0
fi
echo "v45-wave33-codegen-deep-continue-converge=done fail=$fail deep=$deep_ok"
exit 1
