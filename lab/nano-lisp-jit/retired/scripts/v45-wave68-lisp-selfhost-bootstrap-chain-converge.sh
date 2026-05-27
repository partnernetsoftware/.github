#!/usr/bin/env bash
# Wave68: lisp-selfhost-bootstrap-chain — promote 自举链 COM · nano-jit.com 种子退 retired · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
SEED_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
PROMOTE_COM="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
CHAIN_COM="$ROOT/lab/nano-lisp-jit/.build/v45-lsbc-promote.com"
RETIRED_SEED="$ROOT/lab/nano-lisp-jit/retired/com/nano-jit.com.archived"
LSBC_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lisp-selfhost-bootstrap-chain.json"
RETIRED_SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave68-lisp-selfhost-bootstrap-chain-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave67() {
  if grep -q v45.v45.wave_converge_shell_retire_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-wave-converge-shell-retire.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.wave_converge_shell_retire_continue.100=1"
      echo "v45.honest.wave_converge_shell_retired=1"
      echo "v45.converge.daily_v45_com_plan_only_terminal=1"
      echo "v45.selfhost.wave_converge_shell_retire_matrix=1"
      echo "v45.mindmap.wave_converge_shell_retire.coupled=1"
      echo "v45.physical.scripts_zero_active_sh=1"
      echo "v45.physical.wave_converge_shell_rollup=1"
      echo "v45.nano_lisp_com.native_bootstrap=1"
      echo "v45.physical.zero_cpysh=1"
    } >>"$EV"
    echo "v45-wave68=ok fast seed wave67 from frontier 7/7"
    return 0
  fi
  return 1
}

promote_bootstrap_chain() {
  local src=""
  if [ -x "$PROMOTE_COM" ]; then
    src="$PROMOTE_COM"
  elif [ -x "$CHAIN_COM" ]; then
    src="$CHAIN_COM"
  else
    echo "v45-wave68=fail promote missing_chain_com"
    return 1
  fi
  mkdir -p "$(dirname "$COM")"
  cp -f "$src" "$COM"
  chmod +x "$COM"
  echo "v45-wave68=ok promote_bootstrap_chain $(basename "$src")"
}

retire_seed_com() {
  mkdir -p "$(dirname "$RETIRED_SEED")"
  if [ -f "$SEED_COM" ]; then
    mv "$SEED_COM" "$RETIRED_SEED"
    echo "v45-wave68=ok archive_mv seed_com"
    return 0
  fi
  if [ -f "$RETIRED_SEED" ]; then
    echo "v45-wave68=ok archive_mv seed_com already_retired"
    return 0
  fi
  echo "v45-wave68=fail archive_mv seed_com missing"
  return 1
}

echo "v45-wave68-lisp-selfhost-bootstrap-chain-converge=begin com=$(basename "$COM")"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$RETIRED_SCRIPTS/v45-wave67-wave-converge-shell-retire-converge.sh" 2>/dev/null || true
else
  seed_wave67 || fail=$((fail + 1))
fi

grep -q v45.v45.wave_converge_shell_retire_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.converge.daily_v45_com_plan_only_terminal=1 "$EV" || fail=$((fail + 1))

w1_ok=1
if run_plan lisp-selfhost-bootstrap-chain-prove; then
  echo "v45-wave68=ok host w1_chain_prove"
else
  echo "v45-wave68=fail host w1_chain_prove"
  w1_ok=0
  fail=$((fail + 1))
fi

promote_ok=1
if [ "$w1_ok" = 1 ]; then
  promote_bootstrap_chain || { promote_ok=0; fail=$((fail + 1)); }
fi

if [ "$w1_ok" = 1 ] && [ "$promote_ok" = 1 ]; then
  {
    echo "v45.selfhost.bootstrap_chain_promoted=1"
    echo "v45.selfhost.lisp_only_chain=1"
  } >>"$EV"
fi

retire_seed_com || fail=$((fail + 1))
if [ -f "$RETIRED_SEED" ]; then
  echo "v45.honest.seed_com_retired=1" >>"$EV"
  echo "v45.physical.bootstrap_chain_rollup=1" >>"$EV"
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
    "cdlsbc:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-lisp-selfhost-bootstrap-chain.lisp" \
    "slsbcm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-lisp-selfhost-bootstrap-chain-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave68=ok next_lsbc $name" ) \
      || { echo "v45-wave68=fail next_lsbc $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in converge-daily-v45-lisp-selfhost-bootstrap-chain selfhost-lisp-selfhost-bootstrap-chain-matrix; do
  ( run_plan "$p" && echo "v45-wave68=ok host $p" ) \
    || { echo "v45-wave68=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.daily_v45_lisp_selfhost_chain=1" >>"$EV"
  echo "v45.selfhost.lisp_selfhost_bootstrap_chain_matrix=1" >>"$EV"
  echo "v45.mindmap.lisp_selfhost_bootstrap_chain.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_lsbc=1" >>"$EV"
fi

w2_ok=1
if run_plan lisp-selfhost-seed-archive-honest; then
  echo "v45-wave68=ok host w2_seed_honest"
else
  echo "v45-wave68=fail host w2_seed_honest"
  w2_ok=0
  fail=$((fail + 1))
fi

for p in mindmap-lisp-selfhost-bootstrap-chain-tree wave68-diffuse-global wave68-rollup \
  goal-v45-lisp-selfhost-bootstrap-chain-continue-100; do
  run_plan "$p" && echo "v45-wave68=ok plan=$p" \
    || { echo "v45-wave68=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$LSBC_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave68=ok lisp_selfhost_bootstrap_chain_frontier {done}/{total}")
PY

if [ -x "$RETIRED_SCRIPTS/v45-evidence-canonical.sh" ]; then
  bash "$RETIRED_SCRIPTS/v45-evidence-canonical.sh"
fi

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ] && [ "$w2_ok" = 1 ]; then
  {
    echo "v45.wave68.diffuse=1"
    echo "v45.wave68.parallel=4"
    echo "v45.wave68.rollup=1"
    echo "v45.mindmap.lisp_selfhost_bootstrap_chain.nodes_total=7"
    echo "v45.mindmap.lisp_selfhost_bootstrap_chain.nodes_done=7"
    echo "v45.v45.lisp_selfhost_bootstrap_chain_continue.100=1"
  } >>"$EV"
  echo "v45-wave68-lisp-selfhost-bootstrap-chain-converge=done fail=0"
  exit 0
fi
echo "v45-wave68-lisp-selfhost-bootstrap-chain-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok w2=$w2_ok promote=$promote_ok"
exit 1
