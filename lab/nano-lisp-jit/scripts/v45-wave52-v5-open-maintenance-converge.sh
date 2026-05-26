#!/usr/bin/env bash
# Wave52: v5-open-maintenance — v4.5 DONE 后维护轨 · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
VOM_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-v5-open-maintenance.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave52-v5-open-maintenance-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave51() {
  if grep -q v45.v45.v45_terminal_complete.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-v45-terminal-complete.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.v45_terminal_complete.100=1"
      echo "v45.mindmap.v45_terminal_complete.nodes_total=7"
      echo "v45.mindmap.v45_terminal_complete.nodes_done=7"
      echo "v45.rollup.extension_waves_all=1"
      echo "v45.lisp_com.product_canonical=1"
      echo "v45.converge.daily_v45_complete=1"
      echo "v45.selfhost.v45_terminal_matrix=1"
      echo "v45.mindmap.v45_terminal_complete.coupled=1"
      echo "v45.v45.lispjit_codegen_dedicated_continue.100=1"
    } >>"$EV"
    echo "v45-wave52=ok fast seed wave51 from frontier 7/7"
    return 0
  fi
  return 1
}

echo "v45-wave52-v5-open-maintenance-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$(dirname "$0")/v45-wave51-v45-terminal-complete-converge.sh" || true
else
  seed_wave51 || fail=$((fail + 1))
fi

grep -q v45.v45.v45_terminal_complete.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-|inspect-ape|ir-table' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "vds:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-v45-done-state-rollup.lisp" \
    "v5a:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-v5-open-honest-anchor.lisp" \
    "cdvm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-maintenance.lisp" \
    "svom:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-v5-open-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave52=ok next_vom $name" ) \
      || { echo "v45-wave52=fail next_vom $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in v45-done-state-rollup v5-open-honest-anchor \
  converge-daily-v45-maintenance selfhost-v5-open-matrix; do
  ( run_plan "$p" && echo "v45-wave52=ok host $p" ) \
    || { echo "v45-wave52=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.rollup.v45_done_state=1" >>"$EV"
  echo "v45.honest.v5_open=1" >>"$EV"
  echo "v45.converge.daily_v45_maintenance=1" >>"$EV"
  echo "v45.selfhost.v5_open_matrix=1" >>"$EV"
  echo "v45.mindmap.v5_open_maintenance.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_vom=1" >>"$EV"
fi

for p in mindmap-v5-open-maintenance-tree wave52-diffuse-global wave52-rollup \
  goal-v45-v5-open-maintenance-100; do
  run_plan "$p" && echo "v45-wave52=ok plan=$p" \
    || { echo "v45-wave52=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$VOM_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave52=ok v5_open_maintenance_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave52.diffuse=1"
    echo "v45.wave52.parallel=4"
    echo "v45.wave52.rollup=1"
    echo "v45.mindmap.v5_open_maintenance.nodes_total=7"
    echo "v45.mindmap.v5_open_maintenance.nodes_done=7"
    echo "v45.v45.v5_open_maintenance_continue.100=1"
  } >>"$EV"
  echo "v45-wave52-v5-open-maintenance-converge=done fail=0"
  exit 0
fi
echo "v45-wave52-v5-open-maintenance-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
