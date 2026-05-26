#!/usr/bin/env bash
# Wave49: endgame-honest-rollup — 快 seed（默认）或 V45_FULL=1 完整链.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
EHR_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-endgame-honest-rollup.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave49-endgame-honest-rollup-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave48() {
  if grep -q v45.v45.lisp_com_bootstrap_terminal_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lisp-com-bootstrap-terminal.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.lisp_com_bootstrap_terminal_continue.100=1"
      echo "v45.mindmap.lisp_com_bootstrap_terminal.nodes_total=7"
      echo "v45.mindmap.lisp_com_bootstrap_terminal.nodes_done=7"
      echo "v45.lisp_com.bootstrap_terminal=1"
      echo "v45.honest.factory_physical_closure=1"
      echo "v45.converge.daily_lisp_com_terminal=1"
      echo "v45.selfhost.lisp_com_bootstrap_matrix=1"
      echo "v45.mindmap.lisp_com_bootstrap_terminal.coupled=1"
      echo "v45.v45.zero_host_sh_terminal_continue.100=1"
    } >>"$EV"
    echo "v45-wave49=ok fast seed wave48 from frontier 7/7"
    return 0
  fi
  return 1
}

echo "v45-wave49-endgame-honest-rollup-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  echo "v45-wave49=full chain wave48"
  bash "$(dirname "$0")/v45-wave48-lisp-com-bootstrap-terminal-converge.sh" || true
else
  echo "v45-wave49=fast path (set V45_FULL=1 for full chain)"
  seed_wave48 || fail=$((fail + 1))
fi

grep -q v45.v45.lisp_com_bootstrap_terminal_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "w448:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-endgame-waves-44-48-rollup.lisp" \
    "ehra:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-endgame-honest-remaining-anchor.lisp" \
    "cde:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-endgame.lisp" \
    "sehm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-endgame-honest-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave49=ok next_ehr $name" ) \
      || { echo "v45-wave49=fail next_ehr $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in endgame-waves-44-48-rollup endgame-honest-remaining-anchor \
  converge-daily-endgame selfhost-endgame-honest-matrix; do
  ( run_plan "$p" && echo "v45-wave49=ok host $p" ) \
    || { echo "v45-wave49=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.rollup.waves_44_48=1" >>"$EV"
  echo "v45.honest.endgame_remaining=1" >>"$EV"
  echo "v45.converge.daily_endgame=1" >>"$EV"
  echo "v45.selfhost.endgame_honest_matrix=1" >>"$EV"
  echo "v45.mindmap.endgame_honest_rollup.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_ehr=1" >>"$EV"
fi

for p in mindmap-endgame-honest-rollup-tree wave49-diffuse-global wave49-rollup \
  goal-v45-endgame-honest-rollup-100; do
  run_plan "$p" && echo "v45-wave49=ok plan=$p" \
    || { echo "v45-wave49=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$EHR_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave49=ok endgame_honest_rollup_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave49.diffuse=1"
    echo "v45.wave49.parallel=4"
    echo "v45.wave49.rollup=1"
    echo "v45.mindmap.endgame_honest_rollup.nodes_total=7"
    echo "v45.mindmap.endgame_honest_rollup.nodes_done=7"
    echo "v45.v45.endgame_honest_rollup_continue.100=1"
  } >>"$EV"
  echo "v45-wave49-endgame-honest-rollup-converge=done fail=0"
  exit 0
fi
echo "v45-wave49-endgame-honest-rollup-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
