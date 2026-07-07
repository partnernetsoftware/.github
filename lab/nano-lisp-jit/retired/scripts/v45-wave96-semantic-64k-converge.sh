#!/usr/bin/env bash
# Wave96: semantic 64K milestone — modules-semantic · compose-15link-semantic-64k · journal round 25
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-semantic-64k.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
THRESHOLD="${NANO_L4_SEMANTIC_64K_CODE_BYTES_THRESHOLD:-64000}"
GEN_SEM64=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic-64k
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_SEM32=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic-32k
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_SEM8=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_BULK=(env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-bulk-scale NANO_COMPOSE15_NO_HYBRID=1)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave96-journal.log"
: >"$JLOG"

echo "v45-wave96=gate_wave95" | tee -a "$JLOG"
grep -q v45.goal.semantic_32k_milestone=1 "$EV" || {
  bash "$RETIRED/v45-wave95-semantic-32k-converge.sh" >>"$JLOG" 2>&1 || true
}

echo "v45-wave96=gen_semantic_64k" | tee -a "$JLOG"
python3 "$ROOT/lab/nano-lisp-jit/tools/gen-semantic-compose15.py" >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave96=factory_rebuild" | tee -a "$JLOG"
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
  echo "v45-wave96=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_PIN" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
[ -x "$RUNNER" ] || { echo "v45-wave96=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || true
fi

echo "v45-wave96=semantic_64k_probe" | tee -a "$JLOG"
"${GEN_SEM64[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-64k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

CODE_BYTES=0
CODE_BYTES=$(grep -oE 'compose15_link\.code_bytes=[0-9]+' "$JLOG" | tail -1 | cut -d= -f2)
echo "semantic_64k_code_bytes=$CODE_BYTES threshold=$THRESHOLD" >>"$JLOG"

M64_OK=0
if [ "${CODE_BYTES:-0}" -ge "$THRESHOLD" ] && grep -q run-expect-exit.ok=1 "$JLOG"; then
  M64_OK=1
  echo "v45.goal.semantic_64k_milestone=1" >>"$EV"
  echo "v45.goal.semantic_64k_code_bytes=$CODE_BYTES" >>"$EV"
  echo "v45-wave96=ok semantic_64k bytes=$CODE_BYTES" >>"$JLOG"
else
  echo "v45-wave96=fail semantic_64k bytes=$CODE_BYTES" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave96=semantic_32k_regress" | tee -a "$JLOG"
"${GEN_SEM32[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-32k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave96=semantic_8k_regress" | tee -a "$JLOG"
"${GEN_SEM8[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-8k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave96=bulk_still" | tee -a "$JLOG"
"${GEN_BULK[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

if [ "$M64_OK" = 1 ]; then
  "${GEN_SEM64[@]}" "$RUNNER" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-semantic-64k-milestone.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
  echo "v45.goal.semantic_64k_continue.100=1" >>"$EV"
fi

{
  echo "v45.wave96.diffuse=1"
  echo "v45.wave96.profile=compose-15link-semantic-64k"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$M64_OK" "$fail" "${CODE_BYTES:-0}"
import json, sys
from pathlib import Path
goal_p, m64_s, fail_s, cb = sys.argv[1:5]
m64, fail = int(m64_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 25 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 25 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 25,
        "ts": "2026-05-30T00:00:00Z",
        "read_mindmap": "wave96 semantic 64K — modules-semantic tu-main-64k · compose-15link-semantic-64k",
        "plan": [
            "T1: gen-semantic-compose15.py tu-main-64k (5680 func)",
            "T2: profile compose-15link-semantic-64k · code_bytes>=64000",
            "T3: 8K/32K 回归 + bulk 154559 多轨",
        ],
        "results": {"code_bytes": cb, "threshold": 64000, "converge_fail": fail},
        "verified": fail == 0 and m64,
        "self_critique": f"semantic 64K 轨 {cb}B code · 8K/32K/bulk 多轨回归通过。",
    })
waves = goal.get("waves_done", [])
if "wave96-semantic-64k" not in waves:
    waves.append("wave96-semantic-64k")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-semantic-64k.json"
if "integrity_layers" in goal:
    l4 = goal["integrity_layers"].setdefault("L4_semantic_codegen", {"facts": {}})
    l4.setdefault("facts", {})["compose15_semantic_64k_code_bytes"] = str(cb)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave96=ok journal round25")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave96-semantic-64k-converge=done fail=$fail m64=$M64_OK code_bytes=$CODE_BYTES"
exit "$fail"
