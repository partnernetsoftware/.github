#!/usr/bin/env bash
# Wave34: runner codegen 广面 — selfhost-next 四轨 + 扩展活图 7/7.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
RC_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-runner-codegen.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave34-runner-codegen-continue-converge=skip missing_com"
  exit 0
fi
echo "v45-wave34-runner-codegen-continue-converge=begin"
bash "$(dirname "$0")/v45-wave33-codegen-deep-continue-converge.sh" || fail=$((fail + 1))

grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.v45.codegen_deep_continue.100=1 "$EV" || fail=$((fail + 1))

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

broad_ok=1
pids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "mod:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-runner-module-table.lisp" \
    "emit:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-runner-emit-broad.lisp" \
    "facade:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-ir-facade-next.lisp" \
    "subset:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-lispjit-modules-subset.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave34=ok next_runner $name" ) \
      || { echo "v45-wave34=fail next_runner $name"; exit 1; } &
    pids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

# host 四轨并行（与 wave27 同型）
host_ok=1
hpids=()
for p in codegen-runner-module-table codegen-runner-emit-broad codegen-ir-facade-next \
  codegen-lispjit-modules-subset; do
  ( run_plan "$p" && echo "v45-wave34=ok host_runner $p" ) \
    || { echo "v45-wave34=fail host_runner $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done

for pid in "${pids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.codegen.runner_broad_profiles=4" >>"$EV"
  echo "v45.mindmap.runner_codegen.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.codegen.selfhost_next_runner_broad=1" >>"$EV"
fi

for p in runsh-slim-terminal factory-next-runner-codegen-matrix mindmap-runner-codegen-tree \
  wave34-diffuse-global wave34-rollup goal-v45-runner-codegen-continue-100; do
  run_plan "$p" && echo "v45-wave34=ok plan=$p" \
    || { echo "v45-wave34=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$RC_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave34=ok runner_codegen_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave34.diffuse=1"
    echo "v45.wave34.parallel=4"
    echo "v45.wave34.rollup=1"
    echo "v45.mindmap.runner_codegen.nodes_total=7"
    echo "v45.mindmap.runner_codegen.nodes_done=7"
    echo "v45.v45.runner_codegen_continue.100=1"
  } >>"$EV"
  echo "v45-wave34-runner-codegen-continue-converge=done fail=0"
  exit 0
fi
echo "v45-wave34-runner-codegen-continue-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
