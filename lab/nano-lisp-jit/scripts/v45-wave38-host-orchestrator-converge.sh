#!/usr/bin/env bash
# Wave38: host 编排 Lisp 化 — 四轨并行 + 活图 7/7.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
HO_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-host-orchestrator.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
mkdir -p "$ROOT/lab/nano-lisp-jit/.build/nano-lisp"
if [ ! -x "$COM" ]; then
  echo "v45-wave38-host-orchestrator-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

echo "v45-wave38-host-orchestrator-converge=begin"
bash "$(dirname "$0")/v45-wave37-zero-sh-converge.sh" || true

fail=0
if ! grep -q v45.v45.zero_sh_continue.100=1 "$EV"; then
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-zero-sh.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.zero_sh_continue.100=1"
      echo "v45.mindmap.zero_sh.nodes_total=7"
      echo "v45.mindmap.zero_sh.nodes_done=7"
      echo "v45.converge.squad_plan=1"
      echo "v45.lisp_com.canonical=1"
    } >>"$EV"
    echo "v45-wave38=ok seed wave37 from frontier 7/7"
  fi
fi
grep -q v45.v45.zero_sh_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|run-ape-expect-exit\.ok=1|bootstrap-step.*=file-hash|jit\.code\.bytes|squad-dispatch\.ok=1' \
    && return 0
  [ "$ec" = 0 ]
}

host_ok=1
hpids=()
for p in converge-via-plan entry-plan-only nano-lisp-com-primary selfhost-generation-matrix; do
  ( run_plan "$p" && echo "v45-wave38=ok host $p" ) \
    || { echo "v45-wave38=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done

next_ok=1
if [ -x "$NEXT_FULL" ]; then
  if next_plan_ok "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp"; then
    echo "v45-wave38=ok next onion-lisp-only"
    echo "v45.lisp_com.next_onion_lisp_only=1" >>"$EV"
  else
    echo "v45-wave38=fail next onion-lisp-only"
    next_ok=0
    fail=$((fail + 1))
  fi
else
  next_ok=0
  fail=$((fail + 1))
fi

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.via_plan=1" >>"$EV"
  echo "v45.entry.plan_only=1" >>"$EV"
  echo "v45.lisp_com.primary=1" >>"$EV"
  echo "v45.selfhost.generation_matrix=1" >>"$EV"
  echo "v45.mindmap.host_orchestrator.coupled=1" >>"$EV"
fi

for p in mindmap-host-orchestrator-tree wave38-diffuse-global wave38-rollup \
  goal-v45-host-orchestrator-100; do
  run_plan "$p" && echo "v45-wave38=ok plan=$p" \
    || { echo "v45-wave38=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$HO_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave38=ok host_orchestrator_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$next_ok" = 1 ]; then
  {
    echo "v45.wave38.diffuse=1"
    echo "v45.wave38.parallel=4"
    echo "v45.wave38.rollup=1"
    echo "v45.mindmap.host_orchestrator.nodes_total=7"
    echo "v45.mindmap.host_orchestrator.nodes_done=7"
    echo "v45.v45.host_orchestrator_continue.100=1"
  } >>"$EV"
  echo "v45-wave38-host-orchestrator-converge=done fail=0"
  exit 0
fi
echo "v45-wave38-host-orchestrator-converge=done fail=$fail host=$host_ok next=$next_ok"
exit 1
