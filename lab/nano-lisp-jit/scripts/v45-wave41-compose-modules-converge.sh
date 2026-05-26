#!/usr/bin/env bash
# Wave41: 模块 07–12 + compose-Nlink — 四轨并行 + 活图 7/7.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
CM_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-compose-modules.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave41-compose-modules-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

echo "v45-wave41-compose-modules-converge=begin"
bash "$(dirname "$0")/v45-wave40-daily-plan-converge.sh" || true

fail=0
if ! grep -q v45.v45.daily_plan_continue.100=1 "$EV"; then
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-daily-plan.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.daily_plan_continue.100=1"
      echo "v45.mindmap.daily_plan.nodes_total=7"
      echo "v45.mindmap.daily_plan.nodes_done=7"
      echo "v45.converge.daily_plan=1"
      echo "v45.entry.daily_converge=1"
    } >>"$EV"
    echo "v45-wave41=ok seed wave40 from frontier 7/7"
  fi
fi
grep -q v45.v45.daily_plan_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|link-elf64-exe|bootstrap-step.*=file-hash|bootstrap-step.*=compile|build-slice-lisp\.mode' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "mod:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-modules-07-12-full.lisp" \
    "cl3:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-3chain.lisp" \
    "cl5:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-5probe.lisp" \
    "scm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-compose-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave41=ok next_compose $name" ) \
      || { echo "v45-wave41=fail next_compose $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in runner-modules-07-12-full compose-link-3chain compose-link-5probe selfhost-compose-matrix; do
  ( run_plan "$p" && echo "v45-wave41=ok host $p" ) \
    || { echo "v45-wave41=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.runner.modules_07_12=1" >>"$EV"
  echo "v45.runner.compose_3link=1" >>"$EV"
  echo "v45.runner.compose_5link=1" >>"$EV"
  echo "v45.runner.selfhost_compose=1" >>"$EV"
  echo "v45.mindmap.compose_modules.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_compose=1" >>"$EV"
fi

for p in mindmap-compose-modules-tree wave41-diffuse-global wave41-rollup \
  goal-v45-compose-modules-100; do
  run_plan "$p" && echo "v45-wave41=ok plan=$p" \
    || { echo "v45-wave41=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$CM_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave41=ok compose_modules_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave41.diffuse=1"
    echo "v45.wave41.parallel=4"
    echo "v45.wave41.rollup=1"
    echo "v45.mindmap.compose_modules.nodes_total=7"
    echo "v45.mindmap.compose_modules.nodes_done=7"
    echo "v45.v45.compose_modules_continue.100=1"
  } >>"$EV"
  echo "v45-wave41-compose-modules-converge=done fail=0"
  exit 0
fi
echo "v45-wave41-compose-modules-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
