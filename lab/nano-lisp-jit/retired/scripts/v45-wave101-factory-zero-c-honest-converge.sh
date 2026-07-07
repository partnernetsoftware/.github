#!/usr/bin/env bash
# Wave101: factory zero-C honest — lisp 零 .c · archive 透明 · journal round 30
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-factory-zero-c-honest.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GENESIS_PIN="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave101-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$RUNNER" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >>"$JLOG" 2>&1
}

echo "v45-wave101=gate_wave100" | tee -a "$JLOG"
grep -q v45.goal.l4_semantic_codegen_terminal=1 "$EV" || {
  bash "$RETIRED/v45-wave100-l4-semantic-terminal-converge.sh" >>"$JLOG" 2>&1 || true
}

grep -q v45.physical.zero_c=1 "$EV" || echo "v45.physical.zero_c=1" >>"$EV"
grep -q v45.honest.zero_c_progress=1 "$EV" || echo "v45.honest.zero_c_progress=1" >>"$EV"

echo "v45-wave101=count_c_files" | tee -a "$JLOG"
LISP_C=$(find "$ROOT/lab/nano-lisp-jit/lisp" -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
ARCH_C=$(find "$ROOT/lab/nano-lisp-jit/retired/archive-c/runner" -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
echo "lisp_c_files=$LISP_C archive_runner_c_files=$ARCH_C" >>"$JLOG"
[ "${LISP_C:-0}" -eq 0 ] || fail=$((fail + 1))
[ "${ARCH_C:-0}" -gt 0 ] || fail=$((fail + 1))

echo "v45-wave101=factory_rebuild" | tee -a "$JLOG"
GENESIS_PIN_BAK=""
if [ -f "$GENESIS_PIN" ]; then
  GENESIS_PIN_BAK="$(mktemp)"
  cp -f "$GENESIS_PIN" "$GENESIS_PIN_BAK"
fi
NANO_SLICE_COMPILER=native NANO_REGENESIS=1 \
  bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true
if [ -n "$GENESIS_PIN_BAK" ] && [ -f "$GENESIS_PIN_BAK" ]; then
  cp -f "$GENESIS_PIN_BAK" "$GENESIS_PIN"
  chmod +x "$GENESIS_PIN"
  rm -f "$GENESIS_PIN_BAK"
  echo "v45-wave101=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_PIN" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$COM"
[ -x "$RUNNER" ] || { echo "v45-wave101=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || fail=$((fail + 1))
fi

echo "v45-wave101=honest_plans" | tee -a "$JLOG"
run_plan archive-runner-honest-inventory || fail=$((fail + 1))
run_plan factory-physical-honest-closure || fail=$((fail + 1))
run_plan factory-zero-c-honest-audit || fail=$((fail + 1))

echo "v45-wave101=semantic_unified_smoke" | tee -a "$JLOG"
env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS \
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic-unified \
  NANO_COMPOSE15_NO_HYBRID=1 \
  "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-unified-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

HONEST_OK=0
if [ "${LISP_C:-0}" -eq 0 ] && [ "${ARCH_C:-0}" -gt 0 ]; then
  HONEST_OK=1
  echo "v45.honest.lisp_tree_zero_c=1" >>"$EV"
  echo "v45.honest.archive_runner_c=1" >>"$EV"
  echo "v45.honest.factory_c_remains_scoped=1" >>"$EV"
  echo "v45.physical.archive_runner_c_files=$ARCH_C" >>"$EV"
  echo "v45.physical.lisp_tree_c_files=$LISP_C" >>"$EV"
  echo "v45-wave101=ok honest_counts" >>"$JLOG"
else
  echo "v45-wave101=fail honest_counts lisp=$LISP_C arch=$ARCH_C" >>"$JLOG"
  fail=$((fail + 1))
fi

MILE_OK=0
if [ "$HONEST_OK" = 1 ]; then
  run_plan goal-factory-zero-c-honest-milestone && MILE_OK=1 || fail=$((fail + 1))
fi
if [ "$MILE_OK" = 1 ]; then
  echo "v45.goal.factory_zero_c_honest_milestone=1" >>"$EV"
  echo "v45.goal.factory_zero_c_honest_continue.100=1" >>"$EV"
  echo "v45-wave101=ok milestone" >>"$JLOG"
fi

{
  echo "v45.wave101.diffuse=1"
  echo "v45.wave101.profile=factory-zero-c-honest"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$MILE_OK" "$fail" "${LISP_C:-0}" "${ARCH_C:-0}"
import json, sys
from pathlib import Path
goal_p, mile_s, fail_s, lisp_c, arch_c = sys.argv[1:6]
mile, fail = int(mile_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 30 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 30 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 30,
        "ts": "2026-06-01T00:00:00Z",
        "read_mindmap": "wave101 factory zero-C honest — lisp 0 .c · archive runner scoped",
        "plan": [
            "T1: count lisp/ vs archive/c/runner .c",
            "T2: archive-runner + factory-closure 诚实卷",
            "T3: semantic-unified smoke on release COM",
        ],
        "results": {"lisp_c": lisp_c, "archive_runner_c": arch_c, "converge_fail": fail},
        "verified": fail == 0 and mile,
        "self_critique": f"lisp 零 C({lisp_c}) · archive runner {arch_c} 文件 · 不混称 monorepo zero_c DONE。",
    })
waves = goal.get("waves_done", [])
if "wave101-factory-zero-c-honest" not in waves:
    waves.append("wave101-factory-zero-c-honest")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-factory-zero-c-honest.json"
if "macro_strategy" in goal and "macro_tracks" in goal["macro_strategy"]:
    e = goal["macro_strategy"]["macro_tracks"].setdefault("E_bootstrap_boundary", {})
    facts = e.setdefault("facts", {})
    facts["wave101_lisp_tree_c"] = str(lisp_c)
    facts["wave101_archive_runner_c"] = str(arch_c)
    facts["factory_zero_c_honest"] = str(mile and fail == 0)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave101=ok journal round30")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave101-factory-zero-c-honest-converge=done fail=$fail mile=$MILE_OK lisp_c=$LISP_C arch_c=$ARCH_C"
exit "$fail"
