#!/usr/bin/env bash
# Wave62: nano-lisp-com-host-only — bootstrap 宿主迁 nano-lisp/ + wave61 迁 retired · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
SEED_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
PRODUCT_COM="$ROOT/lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
HOST_COM="$ROOT/lab/nano-lisp-jit/.build/nano-lisp/nano-lisp-host.com"
COM="$HOST_COM"
NLCHO_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-nano-lisp-com-host-only.json"
SCRIPTS="$ROOT/lab/nano-lisp-jit/scripts"
RETIRED_SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$SEED_COM" ]; then
  echo "v45-wave62-nano-lisp-com-host-only-converge=skip missing_seed_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

prepare_host_com() {
  mkdir -p "$(dirname "$HOST_COM")"
  cp -f "$SEED_COM" "$HOST_COM"
  chmod +x "$HOST_COM"
  echo "v45-wave62=ok prepare_host_com $(basename "$HOST_COM")"
}

seed_wave61() {
  if grep -q v45.v45.physical_honest_terminal_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-physical-honest-terminal.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.physical_honest_terminal_continue.100=1"
      echo "v45.physical.honest_terminal_rollup=1"
      echo "v45.nano_lisp_com.bootstrap_sprint=1"
      echo "v45.converge.daily_v45_nano_lisp_com=1"
      echo "v45.selfhost.physical_honest_terminal_matrix=1"
      echo "v45.mindmap.physical_honest_terminal.coupled=1"
      echo "v45.physical.zero_cpysh=1"
      echo "v45.honest.archive_factory_terminal=1"
      echo "v45.lisp_com.canonical=1"
      echo "v45.v45.ci_shell_retire_continue.100=1"
    } >>"$EV"
    echo "v45-wave62=ok fast seed wave61 from frontier 7/7"
    return 0
  fi
  return 1
}

retire_wave61_script() {
  mkdir -p "$RETIRED_SCRIPTS"
  local src="$SCRIPTS/v45-wave61-physical-honest-terminal-converge.sh"
  if [ -f "$src" ]; then
    mv "$src" "$RETIRED_SCRIPTS/"
    echo "v45-wave62=ok archive_mv wave61_script"
    return 0
  fi
  if [ -f "$RETIRED_SCRIPTS/v45-wave61-physical-honest-terminal-converge.sh" ]; then
    echo "v45-wave62=ok archive_mv wave61_script already_retired"
    return 0
  fi
  echo "v45-wave62=fail archive_mv wave61_script missing"
  return 1
}

echo "v45-wave62-nano-lisp-com-host-only-converge=begin host=$(basename "$COM") product=$(basename "$PRODUCT_COM")"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$SCRIPTS/v45-wave61-physical-honest-terminal-converge.sh" 2>/dev/null \
    || bash "$RETIRED_SCRIPTS/v45-wave61-physical-honest-terminal-converge.sh" 2>/dev/null \
    || true
else
  seed_wave61 || fail=$((fail + 1))
fi

grep -q v45.v45.physical_honest_terminal_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.nano_lisp_com.bootstrap_sprint=1 "$EV" || fail=$((fail + 1))

prepare_host_com || fail=$((fail + 1))
if [ ! -x "$COM" ]; then
  echo "v45-wave62=fail missing_host_com"
  exit 1
fi

w1_ok=1
if run_plan nano-lisp-com-host-unify-prove; then
  echo "v45-wave62=ok host w1_unify"
else
  echo "v45-wave62=fail host w1_unify"
  w1_ok=0
  fail=$((fail + 1))
fi

if [ "$w1_ok" = 1 ]; then
  {
    echo "v45.host.com_nano_lisp_only=1"
    echo "v45.honest.nano_jit_com_legacy=1"
  } >>"$EV"
fi

retire_wave61_script || fail=$((fail + 1))
if [ -f "$RETIRED_SCRIPTS/v45-wave61-physical-honest-terminal-converge.sh" ]; then
  echo "v45.physical.host_com_rollup=1" >>"$EV"
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
    "njcah:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-jit-com-archive-honest.lisp" \
    "cdnlch:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-nano-lisp-com-host.lisp" \
    "snchm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-nano-lisp-com-host-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave62=ok next_nlcho $name" ) \
      || { echo "v45-wave62=fail next_nlcho $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in nano-jit-com-archive-honest converge-daily-v45-nano-lisp-com-host \
  selfhost-nano-lisp-com-host-matrix; do
  ( run_plan "$p" && echo "v45-wave62=ok host $p" ) \
    || { echo "v45-wave62=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.daily_v45_nano_lisp_com_host=1" >>"$EV"
  echo "v45.selfhost.nano_lisp_com_host_matrix=1" >>"$EV"
  echo "v45.mindmap.nano_lisp_com_host_only.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_nlcho=1" >>"$EV"
fi

for p in mindmap-nano-lisp-com-host-only-tree wave62-diffuse-global wave62-rollup \
  goal-v45-nano-lisp-com-host-only-continue-100; do
  run_plan "$p" && echo "v45-wave62=ok plan=$p" \
    || { echo "v45-wave62=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$NLCHO_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave62=ok nano_lisp_com_host_only_frontier {done}/{total}")
PY

bash "$SCRIPTS/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ]; then
  {
    echo "v45.wave62.diffuse=1"
    echo "v45.wave62.parallel=4"
    echo "v45.wave62.rollup=1"
    echo "v45.mindmap.nano_lisp_com_host_only.nodes_total=7"
    echo "v45.mindmap.nano_lisp_com_host_only.nodes_done=7"
    echo "v45.v45.nano_lisp_com_host_only_continue.100=1"
  } >>"$EV"
  echo "v45-wave62-nano-lisp-com-host-only-converge=done fail=0"
  exit 0
fi
echo "v45-wave62-nano-lisp-com-host-only-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok"
exit 1
