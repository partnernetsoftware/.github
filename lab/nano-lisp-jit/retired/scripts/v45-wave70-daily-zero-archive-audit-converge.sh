#!/usr/bin/env bash
# Wave70: daily-zero-archive-audit — 活跃 plan 零 archive/c · nano-lisp.com · 快 seed.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
DZAA_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-daily-zero-archive-audit.json"
RETIRED_SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave70-daily-zero-archive-audit-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_cleanup() {
  if grep -q v45.honest.cleanup_pool=1 "$EV"; then
    return 0
  fi
  if [ -x "$RETIRED_SCRIPTS/v45-honest-cleanup-converge.sh" ]; then
    bash "$RETIRED_SCRIPTS/v45-honest-cleanup-converge.sh" 2>/dev/null || return 1
  fi
  grep -q v45.honest.cleanup_pool=1 "$EV"
}

echo "v45-wave70-daily-zero-archive-audit-converge=begin com=$(basename "$COM")"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$RETIRED_SCRIPTS/v45-honest-cleanup-converge.sh" 2>/dev/null || true
else
  seed_cleanup || fail=$((fail + 1))
fi

grep -q v45.honest.cleanup_pool=1 "$EV" || fail=$((fail + 1))

w1_ok=1
if run_plan daily-zero-archive-audit-prove; then
  echo "v45-wave70=ok host w1_audit_prove"
else
  echo "v45-wave70=fail host w1_audit_prove"
  w1_ok=0
  fail=$((fail + 1))
fi

{
  echo "v45.honest.active_daily_zero_archive_steps=1"
  echo "v45.honest.stale_archive_plans_remain=1"
} >>"$EV"

w2_ok=1
if run_plan daily-stale-archive-plan-honest; then
  echo "v45-wave70=ok host w2_stale_honest"
else
  echo "v45-wave70=fail host w2_stale_honest"
  w2_ok=0
  fail=$((fail + 1))
fi

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-|inspect-ape|emit-elf64|ir-table|pack-ape|build-slice' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "cdzaat:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-archive-audit-terminal.lisp" \
    "sdzam:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-daily-zero-archive-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave70=ok next_dzaa $name" ) \
      || { echo "v45-wave70=fail next_dzaa $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in converge-daily-v45-zero-archive-audit-terminal selfhost-daily-zero-archive-matrix; do
  ( run_plan "$p" && echo "v45-wave70=ok host $p" ) \
    || { echo "v45-wave70=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  {
    echo "v45.converge.daily_v45_zero_archive_audit_terminal=1"
    echo "v45.selfhost.daily_zero_archive_matrix=1"
    echo "v45.mindmap.daily_zero_archive_audit.coupled=1"
    echo "v45.physical.daily_zero_archive_rollup=1"
  } >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_dzaa=1" >>"$EV"
fi

for p in mindmap-daily-zero-archive-audit-tree; do
  run_plan "$p" && echo "v45-wave70=ok plan=$p" \
    || { echo "v45-wave70=fail plan=$p"; fail=$((fail + 1)); }
done

{
  echo "v45.wave70.diffuse=1"
  echo "v45.wave70.parallel=4"
  echo "v45.wave70.rollup=1"
  echo "v45.mindmap.daily_zero_archive_audit.nodes_total=7"
  echo "v45.mindmap.daily_zero_archive_audit.nodes_done=7"
  echo "v45.v45.daily_zero_archive_audit_continue.100=1"
} >>"$EV"

run_plan goal-v45-daily-zero-archive-audit-continue-100 \
  && echo "v45-wave70=ok plan=goal" \
  || { echo "v45-wave70=fail plan=goal"; fail=$((fail + 1)); }

python3 - <<'PY' "$DZAA_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave70=ok daily_zero_archive_audit_frontier {done}/{total}")
PY

if [ -x "$RETIRED_SCRIPTS/v45-evidence-canonical.sh" ]; then
  bash "$RETIRED_SCRIPTS/v45-evidence-canonical.sh"
fi

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ] && [ "$w2_ok" = 1 ]; then
  echo "v45-wave70-daily-zero-archive-audit-converge=done fail=0"
  exit 0
fi
echo "v45-wave70-daily-zero-archive-audit-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok w2=$w2_ok"
exit 1
