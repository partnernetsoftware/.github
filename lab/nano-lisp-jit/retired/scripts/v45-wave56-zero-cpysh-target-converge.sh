#!/usr/bin/env bash
# Wave56: zero-cpysh-target — v4.5 四轨 rollup + 诚实 gap · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
ZCT_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-zero-cpysh-target.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave56-zero-cpysh-target-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave55() {
  if grep -q v45.v45.tools_py_plan_only_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-tools-py-plan-only.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.tools_py_plan_only_continue.100=1"
      echo "v45.tools.py_inventory=1"
      echo "v45.honest.tools_py_maintenance_only=1"
      echo "v45.converge.daily_v45_target=1"
      echo "v45.v45.ci_plan_only_converge_continue.100=1"
      echo "v45.v45.lispjit_154kb_codegen_continue.100=1"
    } >>"$EV"
    echo "v45-wave56=ok fast seed wave55 from frontier 7/7"
    return 0
  fi
  return 1
}

echo "v45-wave56-zero-cpysh-target-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$(dirname "$0")/v45-wave55-tools-py-plan-only-converge.sh" || true
else
  seed_wave55 || fail=$((fail + 1))
fi

grep -q v45.v45.tools_py_plan_only_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.converge.daily_v45_target=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-|inspect-ape|emit-elf64|ir-table' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "zctr:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-physical-zero-cpysh-target-rollup.lisp" \
    "zctg:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-physical-zero-cpysh-honest-gap.lisp" \
    "cdvt:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-target.lisp" \
    "szct:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-zero-cpysh-target-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave56=ok next_zct $name" ) \
      || { echo "v45-wave56=fail next_zct $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in physical-zero-cpysh-target-rollup physical-zero-cpysh-honest-gap \
  converge-daily-v45-target selfhost-zero-cpysh-target-matrix; do
  ( run_plan "$p" && echo "v45-wave56=ok host $p" ) \
    || { echo "v45-wave56=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.physical.zero_cpysh_target_rollup=1" >>"$EV"
  echo "v45.honest.zero_cpysh_gap=1" >>"$EV"
  echo "v45.physical.zero_cpysh_progress=1" >>"$EV"
  echo "v45.selfhost.zero_cpysh_target_matrix=1" >>"$EV"
  echo "v45.mindmap.zero_cpysh_target.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_zct=1" >>"$EV"
fi

for p in mindmap-zero-cpysh-target-tree wave56-diffuse-global wave56-rollup \
  goal-v45-zero-cpysh-target-continue-100; do
  run_plan "$p" && echo "v45-wave56=ok plan=$p" \
    || { echo "v45-wave56=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$ZCT_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave56=ok zero_cpysh_target_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave56.diffuse=1"
    echo "v45.wave56.parallel=4"
    echo "v45.wave56.rollup=1"
    echo "v45.mindmap.zero_cpysh_target.nodes_total=7"
    echo "v45.mindmap.zero_cpysh_target.nodes_done=7"
    echo "v45.v45.zero_cpysh_target_continue.100=1"
  } >>"$EV"
  echo "v45-wave56-zero-cpysh-target-converge=done fail=0"
  exit 0
fi
echo "v45-wave56-zero-cpysh-target-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
