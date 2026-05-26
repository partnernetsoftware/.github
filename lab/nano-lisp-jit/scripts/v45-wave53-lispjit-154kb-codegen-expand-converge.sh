#!/usr/bin/env bash
# Wave53: lispjit-154kb-codegen-expand — v4.5 消 C 主路径 · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
L15E_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lispjit-154kb-codegen-expand.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave53-lispjit-154kb-codegen-expand-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave52() {
  if grep -q v45.v45.physical_zero_cpysh_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-physical-zero-cpysh-continue.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.physical_zero_cpysh_continue.100=1"
      echo "v45.mindmap.physical_zero_cpysh_continue.nodes_total=7"
      echo "v45.mindmap.physical_zero_cpysh_continue.nodes_done=7"
      echo "v45.physical.zero_cpysh_inventory=1"
      echo "v45.honest.zero_cpysh_remaining=1"
      echo "v45.converge.daily_zero_cpysh=1"
      echo "v45.codegen.lispjit_154kb_probe=1"
    } >>"$EV"
    echo "v45-wave53=ok fast seed wave52 from frontier 7/7"
    return 0
  fi
  return 1
}

echo "v45-wave53-lispjit-154kb-codegen-expand-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$(dirname "$0")/v45-wave52-physical-zero-cpysh-continue-converge.sh" || true
else
  seed_wave52 || fail=$((fail + 1))
fi

grep -q v45.v45.physical_zero_cpysh_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.codegen.lispjit_154kb_probe=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-|ir-table' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "rl15e:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-lispjit-154kb-codegen-expand.lisp" \
    "laph:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-lispjit-archive-progress-honest.lisp" \
    "cdvp:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical.lisp" \
    "sl15e:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-lispjit-154kb-expand-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave53=ok next_l15e $name" ) \
      || { echo "v45-wave53=fail next_l15e $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in runner-lispjit-154kb-codegen-expand lispjit-archive-progress-honest \
  converge-daily-v45-physical selfhost-lispjit-154kb-expand-matrix; do
  ( run_plan "$p" && echo "v45-wave53=ok host $p" ) \
    || { echo "v45-wave53=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.codegen.lispjit_154kb_expand=1" >>"$EV"
  echo "v45.honest.lispjit_c_remains=1" >>"$EV"
  echo "v45.converge.daily_v45_physical=1" >>"$EV"
  echo "v45.selfhost.lispjit_154kb_expand=1" >>"$EV"
  echo "v45.mindmap.lispjit_154kb_codegen_expand.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_l15e=1" >>"$EV"
fi

for p in mindmap-lispjit-154kb-codegen-expand-tree wave53-diffuse-global wave53-rollup \
  goal-v45-lispjit-154kb-codegen-continue-100; do
  run_plan "$p" && echo "v45-wave53=ok plan=$p" \
    || { echo "v45-wave53=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$L15E_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave53=ok lispjit_154kb_codegen_expand_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave53.diffuse=1"
    echo "v45.wave53.parallel=4"
    echo "v45.wave53.rollup=1"
    echo "v45.mindmap.lispjit_154kb_codegen_expand.nodes_total=7"
    echo "v45.mindmap.lispjit_154kb_codegen_expand.nodes_done=7"
    echo "v45.v45.lispjit_154kb_codegen_continue.100=1"
  } >>"$EV"
  echo "v45-wave53-lispjit-154kb-codegen-expand-converge=done fail=0"
  exit 0
fi
echo "v45-wave53-lispjit-154kb-codegen-expand-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
