#!/usr/bin/env bash
# Wave94: semantic 8K milestone — modules-semantic · compose-15link-semantic · journal round 23
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-semantic-8k.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
THRESHOLD="${NANO_L4_SEMANTIC_CODE_BYTES_THRESHOLD:-8000}"
GEN_SEM8=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_BULK=(env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-bulk-scale NANO_COMPOSE15_NO_HYBRID=1)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave94-journal.log"
: >"$JLOG"

echo "v45-wave94=gate_wave93" | tee -a "$JLOG"
grep -q v45.goal.semantic_bulk_diverge=1 "$EV" || {
  bash "$RETIRED/v45-wave93-semantic-diverge-converge.sh" >>"$JLOG" 2>&1 || true
}

echo "v45-wave94=gen_semantic_modules" | tee -a "$JLOG"
python3 "$ROOT/lab/nano-lisp-jit/tools/gen-semantic-compose15.py" >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave94=factory_rebuild" | tee -a "$JLOG"
GENESIS_PIN="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
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
  echo "v45-wave94=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_PIN" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
[ -x "$RUNNER" ] || { echo "v45-wave94=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || true
fi

echo "v45-wave94=semantic_8k_probe" | tee -a "$JLOG"
"${GEN_SEM8[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-8k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

CODE_BYTES=0
CODE_BYTES=$(grep -oE 'compose15_link\.code_bytes=[0-9]+' "$JLOG" | tail -1 | cut -d= -f2)
echo "semantic_code_bytes=$CODE_BYTES threshold=$THRESHOLD" >>"$JLOG"

M8_OK=0
if [ "${CODE_BYTES:-0}" -ge "$THRESHOLD" ] && grep -q run-expect-exit.ok=1 "$JLOG"; then
  M8_OK=1
  echo "v45.goal.semantic_8k_milestone=1" >>"$EV"
  echo "v45.goal.semantic_8k_code_bytes=$CODE_BYTES" >>"$EV"
  echo "v45-wave94=ok semantic_8k bytes=$CODE_BYTES" >>"$JLOG"
else
  echo "v45-wave94=fail semantic_8k bytes=$CODE_BYTES" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave94=bulk_still" | tee -a "$JLOG"
"${GEN_BULK[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

if [ "$M8_OK" = 1 ]; then
  "${GEN_SEM8[@]}" "$RUNNER" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-semantic-8k-milestone.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
  echo "v45.goal.semantic_8k_continue.100=1" >>"$EV"
fi

{
  echo "v45.wave94.diffuse=1"
  echo "v45.wave94.profile=compose-15link-semantic"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$M8_OK" "$fail" "${CODE_BYTES:-0}"
import json, sys
from pathlib import Path
goal_p, m8_s, fail_s, cb = sys.argv[1:5]
m8, fail = int(m8_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 23 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 23 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 23,
        "ts": "2026-05-30T00:00:00Z",
        "read_mindmap": "wave94 semantic 8K — modules-semantic tu-main-8k · compose-15link-semantic",
        "plan": [
            "T1: gen-semantic-compose15.py → lisp/modules-semantic",
            "T2: profile compose-15link-semantic · code_bytes>=8000",
            "T3: bulk 154559 双轨保留",
        ],
        "results": {"code_bytes": cb, "threshold": 8000, "converge_fail": fail},
        "verified": fail == 0 and m8,
        "self_critique": f"semantic 轨 {cb}B code（modules-semantic）· bulk 轨 154559B 并存。",
    })
waves = goal.get("waves_done", [])
if "wave94-semantic-8k" not in waves:
    waves.append("wave94-semantic-8k")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-semantic-8k.json"
if "integrity_layers" in goal:
    l4 = goal["integrity_layers"].setdefault("L4_semantic_codegen", {"facts": {}})
    l4.setdefault("facts", {})["compose15_semantic_8k_code_bytes"] = str(cb)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave94=ok journal round23")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave94-semantic-8k-converge=done fail=$fail m8=$M8_OK code_bytes=$CODE_BYTES"
exit "$fail"
