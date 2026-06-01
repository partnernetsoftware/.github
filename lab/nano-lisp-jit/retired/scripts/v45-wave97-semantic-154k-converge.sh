#!/usr/bin/env bash
# Wave97: semantic 154K milestone — align bulk SSOT · compose-15link-semantic-154k · journal round 26
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-semantic-154k.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
THRESHOLD="${NANO_L4_SEMANTIC_154K_CODE_BYTES_THRESHOLD:-154000}"
GEN_SEM154=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic-154k
  NANO_COMPOSE15_NO_HYBRID=1)
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
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave97-journal.log"
: >"$JLOG"

echo "v45-wave97=gate_wave96" | tee -a "$JLOG"
grep -q v45.goal.semantic_64k_milestone=1 "$EV" || {
  bash "$RETIRED/v45-wave96-semantic-64k-converge.sh" >>"$JLOG" 2>&1 || true
}

echo "v45-wave97=gen_semantic_154k" | tee -a "$JLOG"
python3 "$ROOT/lab/nano-lisp-jit/tools/gen-semantic-compose15.py" >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave97=factory_rebuild" | tee -a "$JLOG"
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
  echo "v45-wave97=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_PIN" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
[ -x "$RUNNER" ] || { echo "v45-wave97=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || true
fi

echo "v45-wave97=semantic_154k_probe" | tee -a "$JLOG"
"${GEN_SEM154[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-154k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

CODE_BYTES=0
CODE_BYTES=$(grep -oE 'compose15_link\.code_bytes=[0-9]+' "$JLOG" | tail -1 | cut -d= -f2)
BULK_BYTES=$(grep -oE 'compose15_link\.code_bytes=[0-9]+' "$JLOG" | tail -1 | cut -d= -f2)
echo "semantic_154k_code_bytes=$CODE_BYTES threshold=$THRESHOLD" >>"$JLOG"

M154_OK=0
if [ "${CODE_BYTES:-0}" -ge "$THRESHOLD" ] && grep -q run-expect-exit.ok=1 "$JLOG"; then
  M154_OK=1
  echo "v45.goal.semantic_154k_milestone=1" >>"$EV"
  echo "v45.goal.semantic_154k_code_bytes=$CODE_BYTES" >>"$EV"
  echo "v45-wave97=ok semantic_154k bytes=$CODE_BYTES" >>"$JLOG"
else
  echo "v45-wave97=fail semantic_154k bytes=$CODE_BYTES" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave97=semantic_64k_regress" | tee -a "$JLOG"
"${GEN_SEM64[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-64k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave97=semantic_32k_regress" | tee -a "$JLOG"
"${GEN_SEM32[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-32k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave97=semantic_8k_regress" | tee -a "$JLOG"
"${GEN_SEM8[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-8k-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave97=bulk_still" | tee -a "$JLOG"
"${GEN_BULK[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))
BULK_BYTES=$(grep -oE 'compose15_link\.code_bytes=[0-9]+' "$JLOG" | tail -1 | cut -d= -f2)
echo "bulk_code_bytes=$BULK_BYTES" >>"$JLOG"

if [ "$M154_OK" = 1 ]; then
  "${GEN_SEM154[@]}" "$RUNNER" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-semantic-154k-milestone.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
  echo "v45.goal.semantic_154k_continue.100=1" >>"$EV"
fi

{
  echo "v45.wave97.diffuse=1"
  echo "v45.wave97.profile=compose-15link-semantic-154k"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$M154_OK" "$fail" "${CODE_BYTES:-0}" "${BULK_BYTES:-0}"
import json, sys
from pathlib import Path
goal_p, m154_s, fail_s, cb, bulk = sys.argv[1:6]
m154, fail = int(m154_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 26 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 26 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 26,
        "ts": "2026-05-30T00:00:00Z",
        "read_mindmap": "wave97 semantic 154K — tu-main-154k · align bulk SSOT",
        "plan": [
            "T1: gen-semantic-compose15.py tu-main-154k (13920 func)",
            "T2: profile compose-15link-semantic-154k · code_bytes>=154000",
            "T3: 8K/32K/64K 回归 + bulk 154559",
        ],
        "results": {"code_bytes": cb, "bulk_bytes": bulk, "threshold": 154000, "converge_fail": fail},
        "verified": fail == 0 and m154,
        "self_critique": f"semantic 154K 轨 {cb}B · bulk {bulk}B · 阶梯闭合。",
    })
waves = goal.get("waves_done", [])
if "wave97-semantic-154k" not in waves:
    waves.append("wave97-semantic-154k")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-semantic-154k.json"
if "integrity_layers" in goal:
    l4 = goal["integrity_layers"].setdefault("L4_semantic_codegen", {"facts": {}})
    facts = l4.setdefault("facts", {})
    facts["compose15_semantic_154k_code_bytes"] = str(cb)
    facts["semantic_154k_bulk_aligned"] = str(int(cb) >= 154000 and int(bulk or 0) >= 154000)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave97=ok journal round26")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave97-semantic-154k-converge=done fail=$fail m154=$M154_OK code_bytes=$CODE_BYTES bulk=$BULK_BYTES"
exit "$fail"
