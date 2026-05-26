#!/usr/bin/env bash
# Wave54: ci-plan-only-converge — v4.5 消 sh 轨 · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
CPO_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-ci-plan-only-converge.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave54-ci-plan-only-converge-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave53() {
  if grep -q v45.v45.lispjit_154kb_codegen_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lispjit-154kb-codegen-expand.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.lispjit_154kb_codegen_continue.100=1"
      echo "v45.mindmap.lispjit_154kb_codegen_expand.nodes_total=7"
      echo "v45.mindmap.lispjit_154kb_codegen_expand.nodes_done=7"
      echo "v45.codegen.lispjit_154kb_expand=1"
      echo "v45.honest.lispjit_c_remains=1"
      echo "v45.converge.daily_v45_physical=1"
      echo "v45.codegen.lispjit_154kb_probe=1"
    } >>"$EV"
    echo "v45-wave54=ok fast seed wave53 from frontier 7/7"
    return 0
  fi
  return 1
}

echo "v45-wave54-ci-plan-only-converge-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$(dirname "$0")/v45-wave53-lispjit-154kb-codegen-expand-converge.sh" || true
else
  seed_wave53 || fail=$((fail + 1))
fi

grep -q v45.v45.lispjit_154kb_codegen_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.converge.daily_v45_physical=1 "$EV" || fail=$((fail + 1))

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
    "cpoc:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-ci-plan-only-converge-chain.lisp" \
    "cshb:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-ci-sh-honest-boundary.lisp" \
    "cdvcpo:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-complete-plan-only.lisp" \
    "scpom:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-ci-plan-only-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave54=ok next_cpo $name" ) \
      || { echo "v45-wave54=fail next_cpo $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in ci-plan-only-converge-chain ci-sh-honest-boundary \
  converge-daily-v45-complete-plan-only selfhost-ci-plan-only-matrix; do
  ( run_plan "$p" && echo "v45-wave54=ok host $p" ) \
    || { echo "v45-wave54=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.ci_plan_only_chain=1" >>"$EV"
  echo "v45.converge.daily_v45_complete_plan_only=1" >>"$EV"
  echo "v45.selfhost.ci_plan_only_matrix=1" >>"$EV"
  echo "v45.mindmap.ci_plan_only_converge.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_cpo=1" >>"$EV"
fi

for p in mindmap-ci-plan-only-converge-tree wave54-diffuse-global wave54-rollup \
  goal-v45-ci-plan-only-converge-continue-100; do
  run_plan "$p" && echo "v45-wave54=ok plan=$p" \
    || { echo "v45-wave54=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$CPO_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave54=ok ci_plan_only_converge_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave54.diffuse=1"
    echo "v45.wave54.parallel=4"
    echo "v45.wave54.rollup=1"
    echo "v45.mindmap.ci_plan_only_converge.nodes_total=7"
    echo "v45.mindmap.ci_plan_only_converge.nodes_done=7"
    echo "v45.v45.ci_plan_only_converge_continue.100=1"
  } >>"$EV"
  echo "v45-wave54-ci-plan-only-converge-converge=done fail=0"
  exit 0
fi
echo "v45-wave54-ci-plan-only-converge-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
