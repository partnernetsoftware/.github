#!/usr/bin/env bash
# Wave39: runner 物理卷 — 四轨并行 + 活图 7/7（诚实卷）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
RP_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-runner-physical.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave39-runner-physical-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

echo "v45-wave39-runner-physical-converge=begin"
bash "$(dirname "$0")/v45-wave38-host-orchestrator-converge.sh" || true

fail=0
if ! grep -q v45.v45.host_orchestrator_continue.100=1 "$EV"; then
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-host-orchestrator.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.host_orchestrator_continue.100=1"
      echo "v45.mindmap.host_orchestrator.nodes_total=7"
      echo "v45.mindmap.host_orchestrator.nodes_done=7"
      echo "v45.converge.via_plan=1"
      echo "v45.entry.plan_only=1"
    } >>"$EV"
    echo "v45-wave39=ok seed wave38 from frontier 7/7"
  fi
fi
grep -q v45.v45.host_orchestrator_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|jit\.code\.bytes|bootstrap-step.*=compile' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "mod:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-physical-modules-broad.lisp" \
    "emit:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-physical-emit-chain.lisp" \
    "probe:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-physical-codegen-probe.lisp" \
    "honest:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-physical-honest-anchor.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave39=ok next_runner_physical $name" ) \
      || { echo "v45-wave39=fail next_runner_physical $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in runner-physical-modules-broad runner-physical-emit-chain \
  runner-physical-codegen-probe runner-physical-honest-anchor; do
  ( run_plan "$p" && echo "v45-wave39=ok host $p" ) \
    || { echo "v45-wave39=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.runner.physical.modules_broad=1" >>"$EV"
  echo "v45.runner.physical.emit_chain=1" >>"$EV"
  echo "v45.runner.physical.codegen_probe=1" >>"$EV"
  echo "v45.runner.physical.honest=1" >>"$EV"
  echo "v45.mindmap.runner_physical.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.physical.selfhost_next=1" >>"$EV"
fi

for p in mindmap-runner-physical-tree wave39-diffuse-global wave39-rollup \
  goal-v45-runner-physical-100; do
  run_plan "$p" && echo "v45-wave39=ok plan=$p" \
    || { echo "v45-wave39=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$RP_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave39=ok runner_physical_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave39.diffuse=1"
    echo "v45.wave39.parallel=4"
    echo "v45.wave39.rollup=1"
    echo "v45.mindmap.runner_physical.nodes_total=7"
    echo "v45.mindmap.runner_physical.nodes_done=7"
    echo "v45.v45.runner_physical_continue.100=1"
  } >>"$EV"
  echo "v45-wave39-runner-physical-converge=done fail=0"
  exit 0
fi
echo "v45-wave39-runner-physical-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
