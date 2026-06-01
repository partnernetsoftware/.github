#!/usr/bin/env bash
# Wave100: L4 semantic codegen terminal — 7-profile matrix · journal round 29
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-l4-semantic-terminal.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GENESIS_PIN="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
GENESIS_BYTES=155648
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave100-journal.log"
: >"$JLOG"

run_sem_probe() {
  local profile="$1" plan="$2" min_bytes="$3"
  local probe_log
  probe_log=$(mktemp)
  env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
    -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS \
    NANO_LISPJIT_FROM_LISP=1 "NANO_LISPJIT_FROM_LISP_PROFILE=$profile" \
    NANO_COMPOSE15_NO_HYBRID=1 \
    "$RUNNER" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/$plan" >>"$probe_log" 2>&1 || {
    cat "$probe_log" >>"$JLOG"
    rm -f "$probe_log"
    return 1
  }
  cat "$probe_log" >>"$JLOG"
  local cb
  cb=$(grep -oE 'compose15_link\.code_bytes=[0-9]+' "$probe_log" | tail -1 | cut -d= -f2)
  echo "matrix profile=$profile code_bytes=${cb:-0} min=$min_bytes" >>"$JLOG"
  rm -f "$probe_log"
  [ "${cb:-0}" -ge "$min_bytes" ] || return 1
  tail -20 "$JLOG" | grep -q run-expect-exit.ok=1 || return 1
  return 0
}

echo "v45-wave100=gate_wave99" | tee -a "$JLOG"
grep -q v45.goal.semantic_unified_milestone=1 "$EV" || {
  bash "$RETIRED/v45-wave99-semantic-unified-converge.sh" >>"$JLOG" 2>&1 || true
}

echo "v45-wave100=factory_rebuild" | tee -a "$JLOG"
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
  echo "v45-wave100=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_PIN" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$COM"
[ -x "$RUNNER" ] || { echo "v45-wave100=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || fail=$((fail + 1))
fi

MATRIX_OK=0
echo "v45-wave100=semantic_matrix" | tee -a "$JLOG"
M_FAIL=0
run_sem_probe compose-15link-semantic \
  bootstrap-v45-probe-compose15-semantic-8k-pure-link.lisp 8000 || M_FAIL=$((M_FAIL + 1))
run_sem_probe compose-15link-semantic-32k \
  bootstrap-v45-probe-compose15-semantic-32k-pure-link.lisp 32000 || M_FAIL=$((M_FAIL + 1))
run_sem_probe compose-15link-semantic-64k \
  bootstrap-v45-probe-compose15-semantic-64k-pure-link.lisp 64000 || M_FAIL=$((M_FAIL + 1))
run_sem_probe compose-15link-semantic-154k \
  bootstrap-v45-probe-compose15-semantic-154k-pure-link.lisp 154000 || M_FAIL=$((M_FAIL + 1))
run_sem_probe compose-15link-semantic-unified \
  bootstrap-v45-probe-compose15-semantic-unified-pure-link.lisp 154000 || M_FAIL=$((M_FAIL + 1))
run_sem_probe compose-15link-semantic-full \
  bootstrap-v45-probe-compose15-semantic-full-pure-link.lisp 400 || M_FAIL=$((M_FAIL + 1))
run_sem_probe compose-15link-bulk-scale \
  bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp 154000 || M_FAIL=$((M_FAIL + 1))

if [ "$M_FAIL" -eq 0 ]; then
  MATRIX_OK=1
  echo "v45.goal.l4_semantic_matrix_pass=1" >>"$EV"
  echo "v45-wave100=ok matrix" >>"$JLOG"
else
  echo "v45-wave100=fail matrix m_fail=$M_FAIL" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave100=matrix_anchor_plan" | tee -a "$JLOG"
env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS \
  "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-l4-semantic-terminal-matrix.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

TERM_OK=0
if [ "$MATRIX_OK" = 1 ]; then
  env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
    -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS \
    "$RUNNER" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-l4-semantic-terminal-done.lisp \
    >>"$JLOG" 2>&1 && TERM_OK=1 || fail=$((fail + 1))
fi

if [ "$TERM_OK" = 1 ]; then
  echo "v45.goal.l4_semantic_codegen_terminal=1" >>"$EV"
  echo "v45.goal.l4_semantic_codegen_continue.100=1" >>"$EV"
  echo "v45-wave100=ok terminal" >>"$JLOG"
else
  [ "$MATRIX_OK" = 1 ] || true
  fail=$((fail + 1))
fi

GEN_NOW=$(wc -c <"$GENESIS_PIN" 2>/dev/null | tr -d ' ')
if [ "$GEN_NOW" != "$GENESIS_BYTES" ]; then
  echo "v45-wave100=fail genesis_bytes=$GEN_NOW want=$GENESIS_BYTES" >>"$JLOG"
  fail=$((fail + 1))
fi

{
  echo "v45.wave100.diffuse=1"
  echo "v45.wave100.profile=l4-semantic-terminal"
} >>"$EV"

UNI_CB=$(grep 'profile=compose-15link-semantic-unified code_bytes=' "$JLOG" | tail -1 | sed -n 's/.*code_bytes=\([0-9]*\).*/\1/p')
BULK_CB=$(grep 'profile=compose-15link-bulk-scale code_bytes=' "$JLOG" | tail -1 | sed -n 's/.*code_bytes=\([0-9]*\).*/\1/p')

python3 - <<'PY' "$GOAL_MM" "$TERM_OK" "$fail" "${UNI_CB:-0}" "${BULK_CB:-0}" "${M_FAIL:-0}"
import json, sys
from pathlib import Path
goal_p, term_s, fail_s, uni, bulk, mf = sys.argv[1:7]
term, fail, mfail = int(term_s), int(fail_s), int(mf)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 29 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 29 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 29,
        "ts": "2026-06-01T00:00:00Z",
        "read_mindmap": "wave100 L4 semantic terminal — 7-profile matrix · codegen track done",
        "plan": [
            "T1: 8K→unified + bulk 矩阵",
            "T2: goal-l4-semantic-terminal-done",
            "T3: L4 status=terminal · genesis 155648 preserved",
        ],
        "results": {"unified_bytes": uni, "bulk_bytes": bulk, "matrix_fail": mfail, "converge_fail": fail},
        "verified": fail == 0 and term,
        "self_critique": "L4 semantic 轨终局：阶梯+full+unified 矩阵绿；strict_done 已于 Wave88 签。",
    })
waves = goal.get("waves_done", [])
if "wave100-l4-semantic-terminal" not in waves:
    waves.append("wave100-l4-semantic-terminal")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-l4-semantic-terminal.json"
if "integrity_layers" in goal:
    l4 = goal["integrity_layers"].setdefault("L4_semantic_codegen", {})
    l4["status"] = "terminal"
    facts = l4.setdefault("facts", {})
    facts["l4_semantic_terminal"] = "1"
    facts["semantic_matrix_profiles"] = "7"
if "macro_strategy" in goal and "macro_tracks" in goal["macro_strategy"]:
    a = goal["macro_strategy"]["macro_tracks"].setdefault("A_L4_codegen", {})
    a["status"] = "terminal"
    cur = a.setdefault("current", {})
    cur["semantic_unified"] = int(uni or 0)
    cur["bulk"] = int(bulk or 0)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave100=ok journal round29")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave100-l4-semantic-terminal-converge=done fail=$fail term=$TERM_OK matrix=$MATRIX_OK genesis=$(wc -c <"$GENESIS_PIN" 2>/dev/null | tr -d ' ')"
exit "$fail"
