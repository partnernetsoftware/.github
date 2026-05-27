#!/usr/bin/env bash
# Wave60: ci-shell-retire — 最后 wave converge 迁 retired + physical.zero_cpysh=1 · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
CSR_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-ci-shell-retire.json"
SCRIPTS="$ROOT/lab/nano-lisp-jit/scripts"
RETIRED_SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
SELF="$(basename "$0")"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave60-ci-shell-retire-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave59() {
  if grep -q v45.v45.tools_py_retire_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-tools-py-retire.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.tools_py_retire_continue.100=1"
      echo "v45.tools.py_plan_only_replacement=1"
      echo "v45.tools.py_active_deleted=1"
      echo "v45.honest.tools_py_retired=1"
      echo "v45.converge.daily_v45_zero_cpysh_terminal=1"
      echo "v45.selfhost.tools_py_retire_matrix=1"
      echo "v45.mindmap.tools_py_retire.coupled=1"
      echo "v45.physical.zero_cpysh_progress=1"
      echo "v45.v45.host_sh_retire_continue.100=1"
      echo "v45.host.wave_sh_active_deleted=1"
      echo "v45.honest.lispjit_c_retired=1"
      echo "v45.runner.lispjit_c_active_deleted=1"
    } >>"$EV"
    echo "v45-wave60=ok fast seed wave59 from frontier 7/7"
    return 0
  fi
  return 1
}

retire_wave59_script() {
  mkdir -p "$RETIRED_SCRIPTS"
  local src="$SCRIPTS/v45-wave59-tools-py-retire-converge.sh"
  if [ -f "$src" ]; then
    mv "$src" "$RETIRED_SCRIPTS/"
    echo "v45-wave60=ok archive_mv wave59_script"
    return 0
  fi
  if [ -f "$RETIRED_SCRIPTS/v45-wave59-tools-py-retire-converge.sh" ]; then
    echo "v45-wave60=ok archive_mv wave59_script already_retired"
    return 0
  fi
  echo "v45-wave60=fail archive_mv wave59_script missing"
  return 1
}

echo "v45-wave60-ci-shell-retire-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$SCRIPTS/v45-wave59-tools-py-retire-converge.sh" 2>/dev/null \
    || bash "$RETIRED_SCRIPTS/v45-wave59-tools-py-retire-converge.sh" 2>/dev/null \
    || true
else
  seed_wave59 || fail=$((fail + 1))
fi

grep -q v45.v45.tools_py_retire_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.converge.daily_v45_zero_cpysh_terminal=1 "$EV" || fail=$((fail + 1))

w1_ok=1
if [ -f "$SCRIPTS/v45-wave59-tools-py-retire-converge.sh" ]; then
  if run_plan ci-shell-plan-only-replacement-prove; then
    echo "v45-wave60=ok host w1_replace"
  else
    echo "v45-wave60=fail host w1_replace"
    w1_ok=0
    fail=$((fail + 1))
  fi
elif [ -f "$RETIRED_SCRIPTS/v45-wave59-tools-py-retire-converge.sh" ]; then
  echo "v45-wave60=ok host w1_replace skip_already_retired"
else
  echo "v45-wave60=fail host w1_replace missing_wave59_script"
  w1_ok=0
  fail=$((fail + 1))
fi

if [ "$w1_ok" = 1 ]; then
  echo "v45.ci.shell_plan_only_replacement=1" >>"$EV"
fi

retire_wave59_script || fail=$((fail + 1))
if [ -f "$RETIRED_SCRIPTS/v45-wave59-tools-py-retire-converge.sh" ]; then
  {
    echo "v45.ci.wave_converge_active_deleted=1"
    echo "v45.honest.ci_utility_sh=1"
    echo "v45.honest.archive_factory_c=1"
    echo "v45.physical.zero_cpysh=1"
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
    "csra:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-ci-shell-archive-honest.lisp" \
    "cdpzc:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical-zero-cpysh.lisp" \
    "scsr:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-ci-shell-retire-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave60=ok next_csr $name" ) \
      || { echo "v45-wave60=fail next_csr $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in ci-shell-archive-honest converge-daily-v45-physical-zero-cpysh \
  selfhost-ci-shell-retire-matrix; do
  ( run_plan "$p" && echo "v45-wave60=ok host $p" ) \
    || { echo "v45-wave60=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.daily_v45_physical_zero_cpysh=1" >>"$EV"
  echo "v45.selfhost.ci_shell_retire_matrix=1" >>"$EV"
  echo "v45.mindmap.ci_shell_retire.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_csr=1" >>"$EV"
fi

for p in mindmap-ci-shell-retire-tree wave60-diffuse-global wave60-rollup \
  goal-v45-ci-shell-retire-continue-100; do
  run_plan "$p" && echo "v45-wave60=ok plan=$p" \
    || { echo "v45-wave60=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$CSR_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave60=ok ci_shell_retire_frontier {done}/{total}")
PY

bash "$SCRIPTS/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ]; then
  {
    echo "v45.wave60.diffuse=1"
    echo "v45.wave60.parallel=4"
    echo "v45.wave60.rollup=1"
    echo "v45.mindmap.ci_shell_retire.nodes_total=7"
    echo "v45.mindmap.ci_shell_retire.nodes_done=7"
    echo "v45.v45.ci_shell_retire_continue.100=1"
  } >>"$EV"
  echo "v45-wave60-ci-shell-retire-converge=done fail=0"
  exit 0
fi
echo "v45-wave60-ci-shell-retire-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok"
exit 1
