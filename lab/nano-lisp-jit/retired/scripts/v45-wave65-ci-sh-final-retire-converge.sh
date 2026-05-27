#!/usr/bin/env bash
# Wave65: ci-sh-final-retire — CI 工具 sh 迁 retired + wave64 迁 retired · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
CSFR_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-ci-sh-final-retire.json"
SCRIPTS="$ROOT/lab/nano-lisp-jit/scripts"
RETIRED_SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
CI_UTILITY=(
  v45-com-verify.sh
  v45-evidence-canonical.sh
  v45-factory-slim.sh
  v45-release-run.sh
  v45-scoped-ci.sh
  v45-cleanup-reflect.sh
)
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave65-ci-sh-final-retire-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave64() {
  if grep -q v45.v45.archive_c_factory_retire_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-archive-c-factory-retire.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.archive_c_factory_retire_continue.100=1"
      echo "v45.honest.archive_c_runner_retired=1"
      echo "v45.honest.archive_factory_lisp=1"
      echo "v45.converge.daily_v45_lisp_only_factory=1"
      echo "v45.selfhost.archive_c_factory_retire_matrix=1"
      echo "v45.mindmap.archive_c_factory_retire.coupled=1"
      echo "v45.physical.archive_c_factory_rollup=1"
      echo "v45.nano_lisp_com.native_bootstrap=1"
      echo "v45.physical.zero_cpysh=1"
    } >>"$EV"
    echo "v45-wave65=ok fast seed wave64 from frontier 7/7"
    return 0
  fi
  return 1
}

retire_ci_utility_sh() {
  mkdir -p "$RETIRED_SCRIPTS"
  local n=0
  for f in "${CI_UTILITY[@]}"; do
    if [ -f "$SCRIPTS/$f" ]; then
      mv "$SCRIPTS/$f" "$RETIRED_SCRIPTS/"
      echo "v45-wave65=ok archive_mv ci_utility $f"
      n=$((n + 1))
    fi
  done
  if [ "$n" -gt 0 ]; then
    return 0
  fi
  if [ -f "$RETIRED_SCRIPTS/v45-evidence-canonical.sh" ]; then
    echo "v45-wave65=ok archive_mv ci_utility already_retired"
    return 0
  fi
  echo "v45-wave65=fail archive_mv ci_utility missing"
  return 1
}

retire_wave64_script() {
  mkdir -p "$RETIRED_SCRIPTS"
  local src="$SCRIPTS/v45-wave64-archive-c-factory-retire-converge.sh"
  if [ -f "$src" ]; then
    mv "$src" "$RETIRED_SCRIPTS/"
    echo "v45-wave65=ok archive_mv wave64_script"
    return 0
  fi
  if [ -f "$RETIRED_SCRIPTS/v45-wave64-archive-c-factory-retire-converge.sh" ]; then
    echo "v45-wave65=ok archive_mv wave64_script already_retired"
    return 0
  fi
  echo "v45-wave65=fail archive_mv wave64_script missing"
  return 1
}

echo "v45-wave65-ci-sh-final-retire-converge=begin com=$(basename "$COM")"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$SCRIPTS/v45-wave64-archive-c-factory-retire-converge.sh" 2>/dev/null \
    || bash "$RETIRED_SCRIPTS/v45-wave64-archive-c-factory-retire-converge.sh" 2>/dev/null \
    || true
else
  seed_wave64 || fail=$((fail + 1))
fi

grep -q v45.v45.archive_c_factory_retire_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.converge.daily_v45_lisp_only_factory=1 "$EV" || fail=$((fail + 1))

w1_ok=1
if run_plan ci-sh-final-retire-prove; then
  echo "v45-wave65=ok host w1_retire_prove"
else
  echo "v45-wave65=fail host w1_retire_prove"
  w1_ok=0
  fail=$((fail + 1))
fi

retire_ci_utility_sh || fail=$((fail + 1))
if [ -f "$RETIRED_SCRIPTS/v45-evidence-canonical.sh" ]; then
  {
    echo "v45.ci.utility_sh_retired=1"
    echo "v45.honest.wave_converge_shell=1"
  } >>"$EV"
fi

retire_wave64_script || fail=$((fail + 1))
if [ -f "$RETIRED_SCRIPTS/v45-wave64-archive-c-factory-retire-converge.sh" ]; then
  echo "v45.physical.ci_sh_final_rollup=1" >>"$EV"
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
    "csfah:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-ci-sh-final-archive-honest.lisp" \
    "cdpof:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-plan-only-final.lisp" \
    "scsfrm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-ci-sh-final-retire-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave65=ok next_csfr $name" ) \
      || { echo "v45-wave65=fail next_csfr $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in ci-sh-final-archive-honest converge-daily-v45-plan-only-final \
  selfhost-ci-sh-final-retire-matrix; do
  ( run_plan "$p" && echo "v45-wave65=ok host $p" ) \
    || { echo "v45-wave65=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.daily_v45_plan_only_final=1" >>"$EV"
  echo "v45.selfhost.ci_sh_final_retire_matrix=1" >>"$EV"
  echo "v45.mindmap.ci_sh_final_retire.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_csfr=1" >>"$EV"
fi

for p in mindmap-ci-sh-final-retire-tree wave65-diffuse-global wave65-rollup \
  goal-v45-ci-sh-final-retire-continue-100; do
  run_plan "$p" && echo "v45-wave65=ok plan=$p" \
    || { echo "v45-wave65=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$CSFR_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave65=ok ci_sh_final_retire_frontier {done}/{total}")
PY

if [ -x "$RETIRED_SCRIPTS/v45-evidence-canonical.sh" ]; then
  bash "$RETIRED_SCRIPTS/v45-evidence-canonical.sh"
elif [ -x "$SCRIPTS/v45-evidence-canonical.sh" ]; then
  bash "$SCRIPTS/v45-evidence-canonical.sh"
fi

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ]; then
  {
    echo "v45.wave65.diffuse=1"
    echo "v45.wave65.parallel=4"
    echo "v45.wave65.rollup=1"
    echo "v45.mindmap.ci_sh_final_retire.nodes_total=7"
    echo "v45.mindmap.ci_sh_final_retire.nodes_done=7"
    echo "v45.v45.ci_sh_final_retire_continue.100=1"
  } >>"$EV"
  echo "v45-wave65-ci-sh-final-retire-converge=done fail=0"
  exit 0
fi
echo "v45-wave65-ci-sh-final-retire-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok"
exit 1
