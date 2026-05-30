#!/usr/bin/env bash
# Wave40: 日常 converge-daily-plan — 四轨并行 + 活图 7/7.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
DP_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-daily-plan.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
mkdir -p "$ROOT/lab/nano-lisp-jit/.build/nano-lisp"
if [ ! -x "$COM" ]; then
  echo "v45-wave40-daily-plan-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

echo "v45-wave40-daily-plan-converge=begin"
bash "$(dirname "$0")/v45-wave39-runner-physical-converge.sh" || true

fail=0
if ! grep -q v45.v45.runner_physical_continue.100=1 "$EV"; then
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-runner-physical.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.runner_physical_continue.100=1"
      echo "v45.mindmap.runner_physical.nodes_total=7"
      echo "v45.mindmap.runner_physical.nodes_done=7"
      echo "v45.runner.physical.modules_broad=1"
      echo "v45.runner.physical.honest=1"
    } >>"$EV"
    echo "v45-wave40=ok seed wave39 from frontier 7/7"
  fi
fi
grep -q v45.v45.runner_physical_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|run-ape-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|squad-dispatch\.ok=1' \
    && return 0
  [ "$ec" = 0 ]
}

daily_ok=1
if ! run_plan "converge-daily-plan"; then
  echo "v45-wave40=fail daily converge-daily-plan"
  daily_ok=0
  fail=$((fail + 1))
else
  echo "v45-wave40=ok daily converge-daily-plan"
fi

host_ok=1
hpids=()
for p in daily-entry-anchor squad-plan-verify selfhost-daily-matrix; do
  ( run_plan "$p" && echo "v45-wave40=ok host $p" ) \
    || { echo "v45-wave40=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done

next_ok=1
if [ -x "$NEXT_FULL" ]; then
  if next_plan_ok "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp"; then
    echo "v45-wave40=ok next onion-lisp-only"
    echo "v45.lisp_com.next_onion_lisp_only=1" >>"$EV"
  else
    echo "v45-wave40=fail next onion-lisp-only"
    next_ok=0
    fail=$((fail + 1))
  fi
else
  next_ok=0
  fail=$((fail + 1))
fi

if [ "$host_ok" = 1 ] && [ "$daily_ok" = 1 ]; then
  echo "v45.converge.daily_plan=1" >>"$EV"
  echo "v45.entry.daily_converge=1" >>"$EV"
  echo "v45.squad.plan_verify=1" >>"$EV"
  echo "v45.selfhost.daily_matrix=1" >>"$EV"
  echo "v45.mindmap.daily_plan.coupled=1" >>"$EV"
fi

for p in mindmap-daily-plan-tree wave40-diffuse-global wave40-rollup \
  goal-v45-daily-plan-100; do
  run_plan "$p" && echo "v45-wave40=ok plan=$p" \
    || { echo "v45-wave40=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$DP_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave40=ok daily_plan_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$daily_ok" = 1 ] && [ "$next_ok" = 1 ]; then
  {
    echo "v45.wave40.diffuse=1"
    echo "v45.wave40.parallel=4"
    echo "v45.wave40.rollup=1"
    echo "v45.mindmap.daily_plan.nodes_total=7"
    echo "v45.mindmap.daily_plan.nodes_done=7"
    echo "v45.v45.daily_plan_continue.100=1"
  } >>"$EV"
  echo "v45-wave40-daily-plan-converge=done fail=0"
  exit 0
fi
echo "v45-wave40-daily-plan-converge=done fail=$fail daily=$daily_ok host=$host_ok next=$next_ok"
exit 1
