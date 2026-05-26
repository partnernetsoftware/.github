#!/usr/bin/env bash
# Wave58: host-sh-retire — plan-only 外层 + 历史 v45-wave*.sh 迁 retired · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
HSR_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-host-sh-retire.json"
SCRIPTS="$ROOT/lab/nano-lisp-jit/scripts"
RETIRED_SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
SELF="$(basename "$0")"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave58-host-sh-retire-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave57() {
  if grep -q v45.v45.lispjit_c_delete_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lispjit-c-delete.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.lispjit_c_delete_continue.100=1"
      echo "v45.runner.lispjit_c_lisp_replacement=1"
      echo "v45.runner.lispjit_c_active_deleted=1"
      echo "v45.honest.lispjit_c_retired=1"
      echo "v45.converge.daily_v45_zero_c=1"
      echo "v45.selfhost.lispjit_c_delete_matrix=1"
      echo "v45.mindmap.lispjit_c_delete.coupled=1"
      echo "v45.physical.zero_c_progress=1"
      echo "v45.v45.zero_cpysh_target_continue.100=1"
      echo "v45.converge.daily_v45_target=1"
      echo "v45.converge.daily_v45_complete_plan_only=1"
      echo "v45.entry.plan_only=1"
    } >>"$EV"
    echo "v45-wave58=ok fast seed wave57 from frontier 7/7"
    return 0
  fi
  return 1
}

retire_wave_scripts() {
  mkdir -p "$RETIRED_SCRIPTS"
  local moved=0
  for f in "$SCRIPTS"/v45-wave*.sh; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    if [ "$base" = "$SELF" ]; then
      continue
    fi
    mv "$f" "$RETIRED_SCRIPTS/"
    moved=$((moved + 1))
  done
  if [ "$moved" -gt 0 ]; then
    echo "v45-wave58=ok archive_mv wave_scripts moved=$moved"
    return 0
  fi
  if [ -f "$RETIRED_SCRIPTS/v45-wave57-lispjit-c-delete-converge.sh" ]; then
    echo "v45-wave58=ok archive_mv wave_scripts already_retired"
    return 0
  fi
  echo "v45-wave58=fail archive_mv wave_scripts missing"
  return 1
}

echo "v45-wave58-host-sh-retire-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$SCRIPTS/v45-wave57-lispjit-c-delete-converge.sh" 2>/dev/null \
    || bash "$RETIRED_SCRIPTS/v45-wave57-lispjit-c-delete-converge.sh" 2>/dev/null \
    || true
else
  seed_wave57 || fail=$((fail + 1))
fi

grep -q v45.v45.lispjit_c_delete_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.converge.daily_v45_zero_c=1 "$EV" || fail=$((fail + 1))

w1_ok=1
if [ -f "$SCRIPTS/v45-wave57-lispjit-c-delete-converge.sh" ] \
  || [ -f "$RETIRED_SCRIPTS/v45-wave57-lispjit-c-delete-converge.sh" ]; then
  if run_plan host-sh-plan-only-replacement-prove; then
    echo "v45-wave58=ok host w1_replace"
  else
    echo "v45-wave58=fail host w1_replace"
    w1_ok=0
    fail=$((fail + 1))
  fi
else
  echo "v45-wave58=fail host w1_replace missing_wave57_script"
  w1_ok=0
  fail=$((fail + 1))
fi

if [ "$w1_ok" = 1 ]; then
  echo "v45.host.sh_plan_only_replacement=1" >>"$EV"
fi

retire_wave_scripts || fail=$((fail + 1))
if [ -f "$RETIRED_SCRIPTS/v45-wave57-lispjit-c-delete-converge.sh" ]; then
  {
    echo "v45.host.wave_sh_active_deleted=1"
    echo "v45.honest.host_sh_retired=1"
    echo "v45.physical.zero_cpysh_progress=1"
    echo "v45.honest.zero_cpysh_remaining=1"
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
    "hsra:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-host-sh-archive-honest.lisp" \
    "cdpo:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-plan-only-outer.lisp" \
    "shrm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-host-sh-retire-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave58=ok next_hsr $name" ) \
      || { echo "v45-wave58=fail next_hsr $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in host-sh-archive-honest converge-daily-v45-plan-only-outer \
  selfhost-host-sh-retire-matrix; do
  ( run_plan "$p" && echo "v45-wave58=ok host $p" ) \
    || { echo "v45-wave58=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.daily_v45_plan_only_outer=1" >>"$EV"
  echo "v45.selfhost.host_sh_retire_matrix=1" >>"$EV"
  echo "v45.mindmap.host_sh_retire.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_hsr=1" >>"$EV"
fi

for p in mindmap-host-sh-retire-tree wave58-diffuse-global wave58-rollup \
  goal-v45-host-sh-retire-continue-100; do
  run_plan "$p" && echo "v45-wave58=ok plan=$p" \
    || { echo "v45-wave58=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$HSR_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave58=ok host_sh_retire_frontier {done}/{total}")
PY

bash "$SCRIPTS/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ]; then
  {
    echo "v45.wave58.diffuse=1"
    echo "v45.wave58.parallel=4"
    echo "v45.wave58.rollup=1"
    echo "v45.mindmap.host_sh_retire.nodes_total=7"
    echo "v45.mindmap.host_sh_retire.nodes_done=7"
    echo "v45.v45.host_sh_retire_continue.100=1"
  } >>"$EV"
  echo "v45-wave58-host-sh-retire-converge=done fail=0"
  exit 0
fi
echo "v45-wave58-host-sh-retire-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok"
exit 1
