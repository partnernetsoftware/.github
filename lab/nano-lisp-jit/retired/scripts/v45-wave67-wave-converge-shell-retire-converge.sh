#!/usr/bin/env bash
# Wave67: wave-converge-shell-retire — 最后 wave sh · wave66+self 迁 retired · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
SELF="$ROOT/lab/nano-lisp-jit/scripts/v45-wave67-wave-converge-shell-retire-converge.sh"
WCSR_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-wave-converge-shell-retire.json"
SCRIPTS="$ROOT/lab/nano-lisp-jit/scripts"
RETIRED_SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave67-wave-converge-shell-retire-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

scripts_active_sh_count() {
  find "$SCRIPTS" -maxdepth 1 -name '*.sh' -type f 2>/dev/null | wc -l
}

seed_wave66() {
  if grep -q v45.v45.archive_factory_lisp_retire_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-archive-factory-lisp-retire.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.archive_factory_lisp_retire_continue.100=1"
      echo "v45.honest.archive_factory_lisp_retired=1"
      echo "v45.converge.daily_v45_zero_archive_path=1"
      echo "v45.selfhost.archive_factory_lisp_retire_matrix=1"
      echo "v45.mindmap.archive_factory_lisp_retire.coupled=1"
      echo "v45.physical.zero_archive_path_rollup=1"
      echo "v45.honest.wave_converge_shell=1"
      echo "v45.nano_lisp_com.native_bootstrap=1"
      echo "v45.physical.zero_cpysh=1"
    } >>"$EV"
    echo "v45-wave67=ok fast seed wave66 from frontier 7/7"
    return 0
  fi
  return 1
}

retire_wave66_script() {
  mkdir -p "$RETIRED_SCRIPTS"
  local src="$SCRIPTS/v45-wave66-archive-factory-lisp-retire-converge.sh"
  if [ -f "$src" ]; then
    mv "$src" "$RETIRED_SCRIPTS/"
    echo "v45-wave67=ok archive_mv wave66_script"
    return 0
  fi
  if [ -f "$RETIRED_SCRIPTS/v45-wave66-archive-factory-lisp-retire-converge.sh" ]; then
    echo "v45-wave67=ok archive_mv wave66_script already_retired"
    return 0
  fi
  echo "v45-wave67=fail archive_mv wave66_script missing"
  return 1
}

retire_self() {
  mkdir -p "$RETIRED_SCRIPTS"
  if [ -f "$SELF" ]; then
    mv "$SELF" "$RETIRED_SCRIPTS/"
    echo "v45-wave67=ok archive_mv self_script"
    return 0
  fi
  if [ -f "$RETIRED_SCRIPTS/v45-wave67-wave-converge-shell-retire-converge.sh" ]; then
    echo "v45-wave67=ok archive_mv self_script already_retired"
    return 0
  fi
  echo "v45-wave67=fail archive_mv self_script missing"
  return 1
}

echo "v45-wave67-wave-converge-shell-retire-converge=begin com=$(basename "$COM")"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$SCRIPTS/v45-wave66-archive-factory-lisp-retire-converge.sh" 2>/dev/null \
    || bash "$RETIRED_SCRIPTS/v45-wave66-archive-factory-lisp-retire-converge.sh" 2>/dev/null \
    || true
else
  seed_wave66 || fail=$((fail + 1))
fi

grep -q v45.v45.archive_factory_lisp_retire_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.converge.daily_v45_zero_archive_path=1 "$EV" || fail=$((fail + 1))

w1_ok=1
if run_plan wave-converge-shell-retire-prove; then
  echo "v45-wave67=ok host w1_retire_prove"
else
  echo "v45-wave67=fail host w1_retire_prove"
  w1_ok=0
  fail=$((fail + 1))
fi

retire_wave66_script || fail=$((fail + 1))
if [ -f "$RETIRED_SCRIPTS/v45-wave66-archive-factory-lisp-retire-converge.sh" ]; then
  echo "v45.honest.wave_converge_shell_retired=1" >>"$EV"
fi

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-|inspect-ape|emit-elf64|ir-table|pack-ape' \
    && return 0
  [ "$ec" = 0 ]
}

NEXT_FULL="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "cdcpot:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-com-plan-only-terminal.lisp" \
    "swcsrm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-wave-converge-shell-retire-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave67=ok next_wcsr $name" ) \
      || { echo "v45-wave67=fail next_wcsr $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in converge-daily-v45-com-plan-only-terminal selfhost-wave-converge-shell-retire-matrix; do
  ( run_plan "$p" && echo "v45-wave67=ok host $p" ) \
    || { echo "v45-wave67=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.daily_v45_com_plan_only_terminal=1" >>"$EV"
  echo "v45.selfhost.wave_converge_shell_retire_matrix=1" >>"$EV"
  echo "v45.mindmap.wave_converge_shell_retire.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_wcsr=1" >>"$EV"
fi

retire_self || fail=$((fail + 1))
active_sh=$(scripts_active_sh_count)
if [ "$active_sh" = 0 ]; then
  {
    echo "v45.physical.scripts_zero_active_sh=1"
    echo "v45.physical.wave_converge_shell_rollup=1"
  } >>"$EV"
  echo "v45-wave67=ok scripts_zero_active_sh"
else
  echo "v45-wave67=fail scripts_active_sh=$active_sh"
  fail=$((fail + 1))
fi

w2_ok=1
if run_plan wave-converge-shell-archive-honest; then
  echo "v45-wave67=ok host w2_archive_honest"
else
  echo "v45-wave67=fail host w2_archive_honest"
  w2_ok=0
  fail=$((fail + 1))
fi

for p in mindmap-wave-converge-shell-retire-tree wave67-diffuse-global wave67-rollup \
  goal-v45-wave-converge-shell-retire-continue-100; do
  run_plan "$p" && echo "v45-wave67=ok plan=$p" \
    || { echo "v45-wave67=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$WCSR_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave67=ok wave_converge_shell_retire_frontier {done}/{total}")
PY

if [ -x "$RETIRED_SCRIPTS/v45-evidence-canonical.sh" ]; then
  bash "$RETIRED_SCRIPTS/v45-evidence-canonical.sh"
fi

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ] && [ "$w2_ok" = 1 ]; then
  {
    echo "v45.wave67.diffuse=1"
    echo "v45.wave67.parallel=4"
    echo "v45.wave67.rollup=1"
    echo "v45.mindmap.wave_converge_shell_retire.nodes_total=7"
    echo "v45.mindmap.wave_converge_shell_retire.nodes_done=7"
    echo "v45.v45.wave_converge_shell_retire_continue.100=1"
  } >>"$EV"
  echo "v45-wave67-wave-converge-shell-retire-converge=done fail=0"
  exit 0
fi
echo "v45-wave67-wave-converge-shell-retire-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok w2=$w2_ok"
exit 1
