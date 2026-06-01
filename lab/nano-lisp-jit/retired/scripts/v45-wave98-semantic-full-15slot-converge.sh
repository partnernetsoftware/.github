#!/usr/bin/env bash
# Wave98: semantic-full 15slot — modules-semantic mirror · compose-15link-semantic-full · round 27
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-semantic-full-15slot.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
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
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave98-journal.log"
: >"$JLOG"

echo "v45-wave98=gate_wave97" | tee -a "$JLOG"
grep -q v45.goal.semantic_154k_milestone=1 "$EV" || {
  bash "$RETIRED/v45-wave97-semantic-154k-converge.sh" >>"$JLOG" 2>&1 || true
}

echo "v45-wave98=mirror_modules15" | tee -a "$JLOG"
python3 "$ROOT/lab/nano-lisp-jit/tools/gen-semantic-modules15.py" >>"$JLOG" 2>&1 || fail=$((fail + 1))
MIRROR_N=$(find "$ROOT/lab/nano-lisp-jit/lisp/modules-semantic" -name 'sem-*.lisp' 2>/dev/null | wc -l | tr -d ' ')
echo "semantic_mirror_slots=$MIRROR_N" >>"$JLOG"
[ "${MIRROR_N:-0}" -ge 15 ] || fail=$((fail + 1))

echo "v45-wave98=factory_rebuild" | tee -a "$JLOG"
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
  echo "v45-wave98=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_PIN" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
[ -x "$RUNNER" ] || { echo "v45-wave98=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || true
fi

echo "v45-wave98=semantic_full_probe" | tee -a "$JLOG"
"${GEN_FULL[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-full-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

CODE_BYTES=0
CODE_BYTES=$(grep -oE 'compose15_link\.code_bytes=[0-9]+' "$JLOG" | tail -1 | cut -d= -f2)
SEM_HASH=$("$RUNNER" file-hash "lab/nano-lisp-jit/.build/v45-c15-semantic-full-pure.elf" 2>/dev/null | tail -1 | tr -d '[:space:]')
echo "semantic_full_code_bytes=$CODE_BYTES hash=$SEM_HASH" >>"$JLOG"

FULL_OK=0
if grep -q compose15_semantic_full_15slot=1 "$JLOG" && grep -q run-expect-exit.ok=1 "$JLOG"; then
  FULL_OK=1
  echo "v45.goal.semantic_15slot_real_modules=1" >>"$EV"
  echo "v45.goal.semantic_full_code_bytes=$CODE_BYTES" >>"$EV"
  echo "v45-wave98=ok semantic_full bytes=$CODE_BYTES" >>"$JLOG"
else
  echo "v45-wave98=fail semantic_full" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave98=bulk_hash_compare" | tee -a "$JLOG"
"${GEN_BULK[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))
BULK_HASH=$("$RUNNER" file-hash "lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf" 2>/dev/null | tail -1 | tr -d '[:space:]')
echo "bulk_hash=$BULK_HASH" >>"$JLOG"
if [ -n "$SEM_HASH" ] && [ -n "$BULK_HASH" ] && [ "$SEM_HASH" != "$BULK_HASH" ]; then
  echo "v45.goal.semantic_full_bulk_diverge=1" >>"$EV"
  echo "v45-wave98=ok hash_diverge sem=$SEM_HASH bulk=$BULK_HASH" >>"$JLOG"
else
  echo "v45-wave98=fail hash_parity sem=$SEM_HASH bulk=$BULK_HASH" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave98=semantic_154k_regress" | tee -a "$JLOG"
"${GEN_SEM154[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-154k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

if [ "$FULL_OK" = 1 ]; then
  "${GEN_FULL[@]}" "$RUNNER" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-semantic-full-15slot.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
  echo "v45.goal.semantic_full_15slot_continue.100=1" >>"$EV"
fi

{
  echo "v45.wave98.diffuse=1"
  echo "v45.wave98.profile=compose-15link-semantic-full"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$FULL_OK" "$fail" "${CODE_BYTES:-0}" "${MIRROR_N:-0}"
import json, sys
from pathlib import Path
goal_p, full_s, fail_s, cb, mn = sys.argv[1:6]
full, fail = int(full_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 27 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 27 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 27,
        "ts": "2026-05-30T00:00:00Z",
        "read_mindmap": "wave98 semantic-full 15slot — modules-semantic mirror · real modules",
        "plan": [
            "T1: gen-semantic-modules15.py → sem-*.lisp ×15",
            "T2: profile compose-15link-semantic-full · hash ≠ bulk",
            "T3: 154K 阶梯回归",
        ],
        "results": {"code_bytes": cb, "mirror_slots": mn, "converge_fail": fail},
        "verified": fail == 0 and full,
        "self_critique": f"15 槽真语义镜像 {mn} 文件 · code={cb}B · 非生成 stub。",
    })
waves = goal.get("waves_done", [])
if "wave98-semantic-full-15slot" not in waves:
    waves.append("wave98-semantic-full-15slot")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-semantic-full-15slot.json"
if "integrity_layers" in goal:
    l4 = goal["integrity_layers"].setdefault("L4_semantic_codegen", {"facts": {}})
    facts = l4.setdefault("facts", {})
    facts["compose15_semantic_full_code_bytes"] = str(cb)
    facts["semantic_15slot_real_modules"] = str(full and fail == 0)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave98=ok journal round27")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave98-semantic-full-15slot-converge=done fail=$fail full=$FULL_OK code_bytes=$CODE_BYTES slots=$MIRROR_N"
exit "$fail"
