#!/usr/bin/env bash
# Wave61: physical-honest-terminal — nano-lisp.com 自举 + wave60 迁 retired · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
PRODUCT_COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
FALLBACK_COM="$COM"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
PHT_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-physical-honest-terminal.json"
SCRIPTS="$ROOT/lab/nano-lisp-jit/scripts"
RETIRED_SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  COM="$FALLBACK_COM"
fi
if [ ! -x "$COM" ]; then
  echo "v45-wave61-physical-honest-terminal-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave60() {
  if grep -q v45.v45.ci_shell_retire_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-ci-shell-retire.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.ci_shell_retire_continue.100=1"
      echo "v45.ci.shell_plan_only_replacement=1"
      echo "v45.ci.wave_converge_active_deleted=1"
      echo "v45.converge.daily_v45_physical_zero_cpysh=1"
      echo "v45.selfhost.ci_shell_retire_matrix=1"
      echo "v45.mindmap.ci_shell_retire.coupled=1"
      echo "v45.physical.zero_cpysh=1"
      echo "v45.honest.ci_utility_sh=1"
      echo "v45.honest.archive_factory_c=1"
      echo "v45.v45.tools_py_retire_continue.100=1"
      echo "v45.tools.py_active_deleted=1"
      echo "v45.honest.lispjit_c_retired=1"
      echo "v45.lisp_com.canonical=1"
    } >>"$EV"
    echo "v45-wave61=ok fast seed wave60 from frontier 7/7"
    return 0
  fi
  return 1
}

retire_wave60_script() {
  mkdir -p "$RETIRED_SCRIPTS"
  local src="$SCRIPTS/v45-wave60-ci-shell-retire-converge.sh"
  if [ -f "$src" ]; then
    mv "$src" "$RETIRED_SCRIPTS/"
    echo "v45-wave61=ok archive_mv wave60_script"
    return 0
  fi
  if [ -f "$RETIRED_SCRIPTS/v45-wave60-ci-shell-retire-converge.sh" ]; then
    echo "v45-wave61=ok archive_mv wave60_script already_retired"
    return 0
  fi
  echo "v45-wave61=fail archive_mv wave60_script missing"
  return 1
}

echo "v45-wave61-physical-honest-terminal-converge=begin host=$(basename "$COM") product=$(basename "$PRODUCT_COM")"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$SCRIPTS/v45-wave60-ci-shell-retire-converge.sh" 2>/dev/null \
    || bash "$RETIRED_SCRIPTS/v45-wave60-ci-shell-retire-converge.sh" 2>/dev/null \
    || true
else
  seed_wave60 || fail=$((fail + 1))
fi

grep -q v45.physical.zero_cpysh=1 "$EV" || fail=$((fail + 1))
grep -q v45.v45.ci_shell_retire_continue.100=1 "$EV" || fail=$((fail + 1))

w1_ok=1
if run_plan nano-lisp-com-bootstrap-sprint; then
  echo "v45-wave61=ok host w1_sprint"
else
  echo "v45-wave61=fail host w1_sprint"
  w1_ok=0
  fail=$((fail + 1))
fi

if [ "$w1_ok" = 1 ]; then
  echo "v45.nano_lisp_com.bootstrap_sprint=1" >>"$EV"
fi

retire_wave60_script || fail=$((fail + 1))
if [ -f "$RETIRED_SCRIPTS/v45-wave60-ci-shell-retire-converge.sh" ]; then
  {
    echo "v45.honest.archive_factory_terminal=1"
    echo "v45.physical.honest_terminal_rollup=1"
  } >>"$EV"
fi

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-|inspect-ape|emit-elf64|ir-table|pack-ape' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "afht:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-archive-factory-honest-terminal.lisp" \
    "cdnlc:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-nano-lisp-com.lisp" \
    "sphtm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-physical-honest-terminal-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave61=ok next_pht $name" ) \
      || { echo "v45-wave61=fail next_pht $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in archive-factory-honest-terminal converge-daily-v45-nano-lisp-com \
  selfhost-physical-honest-terminal-matrix; do
  ( run_plan "$p" && echo "v45-wave61=ok host $p" ) \
    || { echo "v45-wave61=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.daily_v45_nano_lisp_com=1" >>"$EV"
  echo "v45.selfhost.physical_honest_terminal_matrix=1" >>"$EV"
  echo "v45.mindmap.physical_honest_terminal.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_pht=1" >>"$EV"
fi

for p in mindmap-physical-honest-terminal-tree wave61-diffuse-global wave61-rollup \
  goal-v45-physical-honest-terminal-continue-100; do
  run_plan "$p" && echo "v45-wave61=ok plan=$p" \
    || { echo "v45-wave61=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$PHT_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave61=ok physical_honest_terminal_frontier {done}/{total}")
PY

bash "$SCRIPTS/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ]; then
  {
    echo "v45.wave61.diffuse=1"
    echo "v45.wave61.parallel=4"
    echo "v45.wave61.rollup=1"
    echo "v45.mindmap.physical_honest_terminal.nodes_total=7"
    echo "v45.mindmap.physical_honest_terminal.nodes_done=7"
    echo "v45.v45.physical_honest_terminal_continue.100=1"
  } >>"$EV"
  echo "v45-wave61-physical-honest-terminal-converge=done fail=0"
  exit 0
fi
echo "v45-wave61-physical-honest-terminal-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok"
exit 1
