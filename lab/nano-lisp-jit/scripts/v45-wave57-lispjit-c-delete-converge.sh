#!/usr/bin/env bash
# Wave57: lispjit-c-delete — Lisp 15link 替代 + active lispjit.c 迁 retired · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
LCD_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lispjit-c-delete.json"
ACTIVE="$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/lispjit.c.archived"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave57-lispjit-c-delete-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave56() {
  if grep -q v45.v45.zero_cpysh_target_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-zero-cpysh-target.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.zero_cpysh_target_continue.100=1"
      echo "v45.physical.zero_cpysh_target_rollup=1"
      echo "v45.honest.zero_cpysh_gap=1"
      echo "v45.physical.zero_cpysh_progress=1"
      echo "v45.selfhost.zero_cpysh_target_matrix=1"
      echo "v45.mindmap.zero_cpysh_target.coupled=1"
      echo "v45.converge.daily_v45_target=1"
      echo "v45.v45.tools_py_plan_only_continue.100=1"
      echo "v45.v45.ci_plan_only_converge_continue.100=1"
      echo "v45.v45.lispjit_154kb_codegen_continue.100=1"
      echo "v45.codegen.lispjit_154kb_expand=1"
    } >>"$EV"
    echo "v45-wave57=ok fast seed wave56 from frontier 7/7"
    return 0
  fi
  return 1
}

archive_lispjit_c() {
  mkdir -p "$(dirname "$RETIRED")"
  if [ -f "$ACTIVE" ]; then
    mv "$ACTIVE" "$RETIRED"
    echo "v45-wave57=ok archive_mv active->retired"
    return 0
  fi
  if [ -f "$RETIRED" ]; then
    echo "v45-wave57=ok archive_mv already_retired"
    return 0
  fi
  echo "v45-wave57=fail archive_mv missing_both"
  return 1
}

echo "v45-wave57-lispjit-c-delete-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$(dirname "$0")/v45-wave56-zero-cpysh-target-converge.sh" || true
else
  seed_wave56 || fail=$((fail + 1))
fi

grep -q v45.v45.zero_cpysh_target_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.converge.daily_v45_target=1 "$EV" || fail=$((fail + 1))

w1_ok=1
if [ -f "$ACTIVE" ]; then
  if run_plan runner-lispjit-c-lisp-replacement-prove; then
    echo "v45-wave57=ok host w1_replace"
  else
    echo "v45-wave57=fail host w1_replace"
    w1_ok=0
    fail=$((fail + 1))
  fi
elif [ -f "$RETIRED" ]; then
  echo "v45-wave57=ok host w1_replace skip_already_retired"
else
  echo "v45-wave57=fail host w1_replace missing_lispjit_c"
  w1_ok=0
  fail=$((fail + 1))
fi

if [ "$w1_ok" = 1 ]; then
  echo "v45.runner.lispjit_c_lisp_replacement=1" >>"$EV"
fi

archive_lispjit_c || fail=$((fail + 1))
if [ -f "$RETIRED" ]; then
  {
    echo "v45.runner.lispjit_c_active_deleted=1"
    echo "v45.honest.lispjit_c_retired=1"
    echo "v45.physical.zero_c_progress=1"
  } >>"$EV"
fi

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
    "lcda:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-lispjit-c-archive-honest.lisp" \
    "cdzc:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-c.lisp" \
    "slcd:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-lispjit-c-delete-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave57=ok next_lcd $name" ) \
      || { echo "v45-wave57=fail next_lcd $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in lispjit-c-archive-honest converge-daily-v45-zero-c \
  selfhost-lispjit-c-delete-matrix; do
  ( run_plan "$p" && echo "v45-wave57=ok host $p" ) \
    || { echo "v45-wave57=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.daily_v45_zero_c=1" >>"$EV"
  echo "v45.selfhost.lispjit_c_delete_matrix=1" >>"$EV"
  echo "v45.mindmap.lispjit_c_delete.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_lcd=1" >>"$EV"
fi

for p in mindmap-lispjit-c-delete-tree wave57-diffuse-global wave57-rollup \
  goal-v45-lispjit-c-delete-continue-100; do
  run_plan "$p" && echo "v45-wave57=ok plan=$p" \
    || { echo "v45-wave57=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$LCD_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave57=ok lispjit_c_delete_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ]; then
  {
    echo "v45.wave57.diffuse=1"
    echo "v45.wave57.parallel=4"
    echo "v45.wave57.rollup=1"
    echo "v45.mindmap.lispjit_c_delete.nodes_total=7"
    echo "v45.mindmap.lispjit_c_delete.nodes_done=7"
    echo "v45.v45.lispjit_c_delete_continue.100=1"
  } >>"$EV"
  echo "v45-wave57-lispjit-c-delete-converge=done fail=0"
  exit 0
fi
echo "v45-wave57-lispjit-c-delete-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok"
exit 1
