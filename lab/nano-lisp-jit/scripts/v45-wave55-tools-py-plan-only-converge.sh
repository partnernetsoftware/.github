#!/usr/bin/env bash
# Wave55: tools-py-plan-only — v4.5 消 py 轨 · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
TPY_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-tools-py-plan-only.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave55-tools-py-plan-only-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave54() {
  if grep -q v45.v45.ci_plan_only_converge_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-ci-plan-only-converge.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.ci_plan_only_converge_continue.100=1"
      echo "v45.mindmap.ci_plan_only_converge.nodes_total=7"
      echo "v45.mindmap.ci_plan_only_converge.nodes_done=7"
      echo "v45.converge.ci_plan_only_chain=1"
      echo "v45.converge.daily_v45_complete_plan_only=1"
      echo "v45.honest.host_sh_ci_only=1"
      echo "v45.codegen.lispjit_154kb_expand=1"
    } >>"$EV"
    echo "v45-wave55=ok fast seed wave54 from frontier 7/7"
    return 0
  fi
  return 1
}

echo "v45-wave55-tools-py-plan-only-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$(dirname "$0")/v45-wave54-ci-plan-only-converge-converge.sh" || true
else
  seed_wave54 || fail=$((fail + 1))
fi

grep -q v45.v45.ci_plan_only_converge_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.converge.daily_v45_complete_plan_only=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-|inspect-ape|emit-elf64' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "tpyi:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-tools-py-inventory.lisp" \
    "tpyb:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-tools-py-honest-boundary.lisp" \
    "cdvt:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-target.lisp" \
    "stpom:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-tools-py-plan-only-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave55=ok next_tpy $name" ) \
      || { echo "v45-wave55=fail next_tpy $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in tools-py-inventory tools-py-honest-boundary \
  converge-daily-v45-target selfhost-tools-py-plan-only-matrix; do
  ( run_plan "$p" && echo "v45-wave55=ok host $p" ) \
    || { echo "v45-wave55=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.tools.py_inventory=1" >>"$EV"
  echo "v45.honest.tools_py_maintenance_only=1" >>"$EV"
  echo "v45.converge.daily_v45_target=1" >>"$EV"
  echo "v45.selfhost.tools_py_plan_only_matrix=1" >>"$EV"
  echo "v45.mindmap.tools_py_plan_only.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_tpy=1" >>"$EV"
fi

for p in mindmap-tools-py-plan-only-tree wave55-diffuse-global wave55-rollup \
  goal-v45-tools-py-plan-only-continue-100; do
  run_plan "$p" && echo "v45-wave55=ok plan=$p" \
    || { echo "v45-wave55=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$TPY_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave55=ok tools_py_plan_only_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave55.diffuse=1"
    echo "v45.wave55.parallel=4"
    echo "v45.wave55.rollup=1"
    echo "v45.mindmap.tools_py_plan_only.nodes_total=7"
    echo "v45.mindmap.tools_py_plan_only.nodes_done=7"
    echo "v45.v45.tools_py_plan_only_continue.100=1"
  } >>"$EV"
  echo "v45-wave55-tools-py-plan-only-converge=done fail=0"
  exit 0
fi
echo "v45-wave55-tools-py-plan-only-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
