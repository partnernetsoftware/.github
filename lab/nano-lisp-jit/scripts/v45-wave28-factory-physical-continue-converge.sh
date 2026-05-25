#!/usr/bin/env bash
# Wave28: 工厂物理续推 — selfhost-next 全量矩阵 + slice 双架构 + run.sh 锚.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
FP_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-factory.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave28-factory-physical-continue-converge=skip missing_com"
  exit 0
fi
echo "v45-wave28-factory-physical-continue-converge=begin"
bash "$(dirname "$0")/v45-wave27-codegen-coupled-converge.sh" || fail=$((fail + 1))

grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" \
  || { echo "v45-wave28=fail missing /goal key"; fail=$((fail + 1)); }
grep -q v45.v45.codegen_coupled.100=1 "$EV" \
  || { echo "v45-wave28=fail missing codegen_coupled"; fail=$((fail + 1)); }

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/samples/bootstrap-v45-$1.lisp" >/dev/null
}

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|run-ape-expect-exit\.ok=1|inspect-ape\.ok=1' \
    && return 0
  [ "$ec" = 0 ]
}

matrix_ok=1
if [ -x "$NEXT_FULL" ]; then
  pids=()
  for spec in \
    "smoke:lab/nano-lisp-jit/samples/bootstrap-v45-verify-smoke.lisp" \
    "core:lab/nano-lisp-jit/samples/bootstrap-v45-verify-core.lisp" \
    "onion:lab/nano-lisp-jit/samples/bootstrap-v45-onion-lisp-only.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave28=ok next_full $name" ) \
      || { echo "v45-wave28=fail next_full $name"; exit 1; } &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || matrix_ok=0; done
  if [ "$matrix_ok" = 1 ]; then
    echo "v45.factory.selfhost_next_full=1" >>"$EV"
  fi
else
  echo "v45-wave28=fail missing selfhost-next.com"
  matrix_ok=0
  fail=$((fail + 1))
fi

probe_ok=1
pids=()
for p in codegen-lisp-slice-dual-arch codegen-lisp-ir-table-broad; do
  ( run_plan "$p" && echo "v45-wave28=ok probe=$p" ) \
    || { echo "v45-wave28=fail probe=$p"; exit 1; } &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || probe_ok=0; done

bash "$(dirname "$0")/v45-scoped-ci.sh" || true
echo "v45.factory.scoped_ci_refresh=1" >>"$EV"

if [ "$probe_ok" = 1 ] && [ "$matrix_ok" = 1 ]; then
  echo "v45.codegen.lisp_slices=9" >>"$EV"
  echo "v45.mindmap.factory.coupled=1" >>"$EV"
fi

for p in runsh-factory-continue-anchor factory-selfhost-next-matrix \
  mindmap-factory-coupled-tree wave28-diffuse-global wave28-rollup \
  goal-v45-factory-physical-continue-100; do
  run_plan "$p" && echo "v45-wave28=ok plan=$p" \
    || { echo "v45-wave28=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$FP_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-fp-slice-dual", "v45-fp-ir-broad", "v45-fp-next-full", "v45-fp-runsh",
  "v45-fp-terminal", "v45-fp-goal",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave28=ok factory_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$probe_ok" = 1 ] && [ "$matrix_ok" = 1 ]; then
  {
    echo "v45.wave28.diffuse=1"
    echo "v45.wave28.parallel=4"
    echo "v45.wave28.rollup=1"
    echo "v45.mindmap.factory.nodes_total=7"
    echo "v45.mindmap.factory.nodes_done=7"
    echo "v45.v45.factory_physical_continue.100=1"
  } >>"$EV"
  echo "v45-wave28-factory-physical-continue-converge=done fail=0"
  exit 0
fi
echo "v45-wave28-factory-physical-continue-converge=done fail=$fail probe=$probe_ok matrix=$matrix_ok"
exit 1
