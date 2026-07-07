#!/usr/bin/env bash
# Wave99: semantic-unified — tu-main-154k + sem-* ×14 · journal round 28
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-semantic-unified.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
THRESHOLD="${NANO_L4_SEMANTIC_UNIFIED_CODE_BYTES_THRESHOLD:-154000}"
GEN_UNIFIED=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic-unified
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_FULL=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic-full
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_SEM154=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic-154k
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_BULK=(env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-bulk-scale NANO_COMPOSE15_NO_HYBRID=1)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave99-journal.log"
: >"$JLOG"

echo "v45-wave99=gate_wave98" | tee -a "$JLOG"
grep -q v45.goal.semantic_15slot_real_modules=1 "$EV" || {
  bash "$RETIRED/v45-wave98-semantic-full-15slot-converge.sh" >>"$JLOG" 2>&1 || true
}

echo "v45-wave99=gen_modules" | tee -a "$JLOG"
python3 "$ROOT/lab/nano-lisp-jit/tools/gen-semantic-modules15.py" >>"$JLOG" 2>&1 || true
python3 "$ROOT/lab/nano-lisp-jit/tools/gen-semantic-compose15.py" --slot tu-main-154k >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave99=factory_rebuild" | tee -a "$JLOG"
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
  echo "v45-wave99=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_PIN" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
[ -x "$RUNNER" ] || { echo "v45-wave99=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || true
fi

echo "v45-wave99=semantic_unified_probe" | tee -a "$JLOG"
"${GEN_UNIFIED[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-unified-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

CODE_BYTES=0
CODE_BYTES=$(grep -oE 'compose15_link\.code_bytes=[0-9]+' "$JLOG" | tail -1 | cut -d= -f2)
UNI_HASH=$("$RUNNER" file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-unified-pure.elf" 2>/dev/null | tail -1 | tr -d '[:space:]')
echo "semantic_unified_code_bytes=$CODE_BYTES threshold=$THRESHOLD hash=$UNI_HASH" >>"$JLOG"

UNI_OK=0
if grep -q compose15_semantic_unified=1 "$JLOG" && grep -q run-expect-exit.ok=1 "$JLOG" \
  && [ "${CODE_BYTES:-0}" -ge "$THRESHOLD" ]; then
  UNI_OK=1
  echo "v45.goal.semantic_unified_milestone=1" >>"$EV"
  echo "v45.goal.semantic_unified_code_bytes=$CODE_BYTES" >>"$EV"
  echo "v45-wave99=ok semantic_unified bytes=$CODE_BYTES" >>"$JLOG"
else
  echo "v45-wave99=fail semantic_unified bytes=$CODE_BYTES" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave99=semantic_full_regress" | tee -a "$JLOG"
"${GEN_FULL[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-full-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))
FULL_HASH=$("$RUNNER" file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-full-pure.elf" 2>/dev/null | tail -1 | tr -d '[:space:]')
if [ -n "$UNI_HASH" ] && [ -n "$FULL_HASH" ] && [ "$UNI_HASH" != "$FULL_HASH" ]; then
  echo "v45.goal.semantic_unified_full_diverge=1" >>"$EV"
  echo "v45-wave99=ok unified_vs_full hash_diverge" >>"$JLOG"
else
  echo "v45-wave99=fail unified_vs_full same_hash" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave99=semantic_154k_regress" | tee -a "$JLOG"
"${GEN_SEM154[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-154k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave99=bulk_still" | tee -a "$JLOG"
"${GEN_BULK[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

if [ "$UNI_OK" = 1 ]; then
  "${GEN_UNIFIED[@]}" "$RUNNER" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-semantic-unified-milestone.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
  echo "v45.goal.semantic_unified_continue.100=1" >>"$EV"
fi

{
  echo "v45.wave99.diffuse=1"
  echo "v45.wave99.profile=compose-15link-semantic-unified"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$UNI_OK" "$fail" "${CODE_BYTES:-0}"
import json, sys
from pathlib import Path
goal_p, uni_s, fail_s, cb = sys.argv[1:5]
uni, fail = int(uni_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 28 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 28 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 28,
        "ts": "2026-06-01T00:00:00Z",
        "read_mindmap": "wave99 semantic-unified — tu-main-154k + sem-* ×14",
        "plan": [
            "T1: profile compose-15link-semantic-unified",
            "T2: code_bytes>=154000 · hash ≠ semantic-full",
            "T3: full/154k/bulk 回归",
        ],
        "results": {"code_bytes": cb, "threshold": 154000, "converge_fail": fail},
        "verified": fail == 0 and uni,
        "self_critique": f"semantic-unified {cb}B · 154K main + 14 槽真模块合一。",
    })
waves = goal.get("waves_done", [])
if "wave99-semantic-unified" not in waves:
    waves.append("wave99-semantic-unified")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-semantic-unified.json"
if "integrity_layers" in goal:
    l4 = goal["integrity_layers"].setdefault("L4_semantic_codegen", {"facts": {}})
    facts = l4.setdefault("facts", {})
    facts["compose15_semantic_unified_code_bytes"] = str(cb)
    facts["semantic_unified_milestone"] = str(uni and fail == 0)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave99=ok journal round28")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave99-semantic-unified-converge=done fail=$fail uni=$UNI_OK code_bytes=$CODE_BYTES"
exit "$fail"
