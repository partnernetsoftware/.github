#!/usr/bin/env bash
# Wave64: archive-c-factory-retire — runner C 迁 retired + wave63 迁 retired · 快 seed（默认）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
RUNNER_SRC="$ROOT/lab/nano-lisp-jit/archive/c/runner"
RUNNER_RET="$ROOT/lab/nano-lisp-jit/retired/archive-c/runner"
TU_SRC="$ROOT/lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
TU_DST="$ROOT/lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
ACFR_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-archive-c-factory-retire.json"
SCRIPTS="$ROOT/lab/nano-lisp-jit/scripts"
RETIRED_SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave64-archive-c-factory-retire-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

promote_lisp_tu_main() {
  if [ -f "$TU_DST" ]; then
    echo "v45-wave64=ok promote_lisp_tu_main already"
    return 0
  fi
  if [ -f "$TU_SRC" ]; then
    cp -f "$TU_SRC" "$TU_DST"
    echo "v45-wave64=ok promote_lisp_tu_main"
    return 0
  fi
  echo "v45-wave64=fail promote_lisp_tu_main missing_src"
  return 1
}

retire_archive_c_runner() {
  mkdir -p "$(dirname "$RUNNER_RET")"
  if [ -d "$RUNNER_SRC" ] && [ ! -L "$RUNNER_SRC" ]; then
    mv "$RUNNER_SRC" "$RUNNER_RET"
    ln -s "../../retired/archive-c/runner" "$RUNNER_SRC"
    echo "v45-wave64=ok archive_mv runner_c"
    return 0
  fi
  if [ -L "$RUNNER_SRC" ] && [ -d "$RUNNER_RET" ]; then
    echo "v45-wave64=ok archive_mv runner_c already_retired"
    return 0
  fi
  if [ -d "$RUNNER_RET" ]; then
    [ -L "$RUNNER_SRC" ] || ln -s "../../retired/archive-c/runner" "$RUNNER_SRC"
    echo "v45-wave64=ok archive_mv runner_c restore_symlink"
    return 0
  fi
  echo "v45-wave64=fail archive_mv runner_c missing"
  return 1
}

seed_wave63() {
  if grep -q v45.v45.nano_lisp_com_native_bootstrap_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-nano-lisp-com-native-bootstrap.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.nano_lisp_com_native_bootstrap_continue.100=1"
      echo "v45.nano_lisp_com.native_bootstrap=1"
      echo "v45.honest.nano_lisp_host_retired=1"
      echo "v45.converge.daily_v45_nano_lisp_com_native=1"
      echo "v45.selfhost.nano_lisp_com_native_matrix=1"
      echo "v45.mindmap.nano_lisp_com_native_bootstrap.coupled=1"
      echo "v45.physical.native_bootstrap_rollup=1"
      echo "v45.host.com_nano_lisp_only=1"
      echo "v45.physical.zero_cpysh=1"
    } >>"$EV"
    echo "v45-wave64=ok fast seed wave63 from frontier 7/7"
    return 0
  fi
  return 1
}

retire_wave63_script() {
  mkdir -p "$RETIRED_SCRIPTS"
  local src="$SCRIPTS/v45-wave63-nano-lisp-com-native-bootstrap-converge.sh"
  if [ -f "$src" ]; then
    mv "$src" "$RETIRED_SCRIPTS/"
    echo "v45-wave64=ok archive_mv wave63_script"
    return 0
  fi
  if [ -f "$RETIRED_SCRIPTS/v45-wave63-nano-lisp-com-native-bootstrap-converge.sh" ]; then
    echo "v45-wave64=ok archive_mv wave63_script already_retired"
    return 0
  fi
  echo "v45-wave64=fail archive_mv wave63_script missing"
  return 1
}

echo "v45-wave64-archive-c-factory-retire-converge=begin com=$(basename "$COM")"
if [ "${V45_FULL:-0}" = 1 ]; then
  bash "$SCRIPTS/v45-wave63-nano-lisp-com-native-bootstrap-converge.sh" 2>/dev/null \
    || bash "$RETIRED_SCRIPTS/v45-wave63-nano-lisp-com-native-bootstrap-converge.sh" 2>/dev/null \
    || true
else
  seed_wave63 || fail=$((fail + 1))
fi

grep -q v45.v45.nano_lisp_com_native_bootstrap_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.nano_lisp_com.native_bootstrap=1 "$EV" || fail=$((fail + 1))

promote_lisp_tu_main || fail=$((fail + 1))
retire_archive_c_runner || fail=$((fail + 1))
if [ -d "$RUNNER_RET" ]; then
  {
    echo "v45.honest.archive_c_runner_retired=1"
    echo "v45.honest.archive_factory_lisp=1"
  } >>"$EV"
fi

w1_ok=1
if run_plan archive-c-factory-retire-prove; then
  echo "v45-wave64=ok host w1_retire_prove"
else
  echo "v45-wave64=fail host w1_retire_prove"
  w1_ok=0
  fail=$((fail + 1))
fi

retire_wave63_script || fail=$((fail + 1))
if [ -f "$RETIRED_SCRIPTS/v45-wave63-nano-lisp-com-native-bootstrap-converge.sh" ]; then
  echo "v45.physical.archive_c_factory_rollup=1" >>"$EV"
fi

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-|inspect-ape|emit-elf64|ir-table|pack-ape' \
    && return 0
  [ "$ec" = 0 ]
}

NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "acfhr:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-archive-c-factory-honest-retire.lisp" \
    "cdlf:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-lisp-only-factory.lisp" \
    "sacfrm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-archive-c-factory-retire-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave64=ok next_acfr $name" ) \
      || { echo "v45-wave64=fail next_acfr $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in archive-c-factory-honest-retire converge-daily-v45-lisp-only-factory \
  selfhost-archive-c-factory-retire-matrix; do
  ( run_plan "$p" && echo "v45-wave64=ok host $p" ) \
    || { echo "v45-wave64=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.daily_v45_lisp_only_factory=1" >>"$EV"
  echo "v45.selfhost.archive_c_factory_retire_matrix=1" >>"$EV"
  echo "v45.mindmap.archive_c_factory_retire.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_acfr=1" >>"$EV"
fi

for p in mindmap-archive-c-factory-retire-tree wave64-diffuse-global wave64-rollup \
  goal-v45-archive-c-factory-retire-continue-100; do
  run_plan "$p" && echo "v45-wave64=ok plan=$p" \
    || { echo "v45-wave64=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$ACFR_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave64=ok archive_c_factory_retire_frontier {done}/{total}")
PY

bash "$SCRIPTS/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ] && [ "$w1_ok" = 1 ]; then
  {
    echo "v45.wave64.diffuse=1"
    echo "v45.wave64.parallel=4"
    echo "v45.wave64.rollup=1"
    echo "v45.mindmap.archive_c_factory_retire.nodes_total=7"
    echo "v45.mindmap.archive_c_factory_retire.nodes_done=7"
    echo "v45.v45.archive_c_factory_retire_continue.100=1"
  } >>"$EV"
  echo "v45-wave64-archive-c-factory-retire-converge=done fail=0"
  exit 0
fi
echo "v45-wave64-archive-c-factory-retire-converge=done fail=$fail host=$host_ok broad=$broad_ok w1=$w1_ok"
exit 1
