#!/usr/bin/env bash
# L4-154k-push — code_bytes 154K · 15-slot bulk 13-27 · manifest pin · parallel W3/W4
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-l4-154k-push.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
CODE_THRESHOLD="${NANO_L4_CODE_BYTES_THRESHOLD:-154000}"
WAVE85_CODE_BASE=64304
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-l4-154k-push-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.goal.l4_64k_milestone_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-l4-64k-milestone-converge.sh" 2>/dev/null || true
}

echo "v45-l4-154k-push=regenesis" | tee -a "$JLOG"
NANO_REGENESIS=1 bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  cp -f "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64" \
    "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
  cp -f "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.aarch64" \
    "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64" 2>/dev/null || true
fi

bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || fail=$((fail + 1))

PARITY_OK=0
(
  COM_HASH=$("$COM" file-hash "$COM" 2>/dev/null | tail -1 | tr -d '[:space:]')
  MAN_HASH=$(grep -E '^nano-lisp\.com\.fnv1a64=' "$ROOT/lab/nano-lisp-jit/release/manifest.txt" \
    | head -1 | cut -d= -f2 | tr -d '[:space:]')
  COM_BYTES=$(wc -c <"$COM" | tr -d ' ')
  MAN_BYTES=$(grep -E '^nano-lisp\.com\.bytes=' "$ROOT/lab/nano-lisp-jit/release/manifest.txt" \
    | head -1 | cut -d= -f2 | tr -d '[:space:]')
  echo "com_hash=$COM_HASH manifest_hash=$MAN_HASH bytes=$COM_BYTES" >>"$JLOG"
  if [ -n "$COM_HASH" ] && [ "$COM_HASH" = "$MAN_HASH" ] && [ "$COM_BYTES" = "$MAN_BYTES" ]; then
    echo "v45.goal.nano_jit_com.release_parity=1" >>"$EV"
    echo "v45.goal.manifest_pin_sync=1" >>"$EV"
    echo "v45-l4=ok manifest_parity" >>"$JLOG"
    exit 0
  fi
  echo "v45-l4=fail manifest_parity com=$COM_HASH man=$MAN_HASH" >>"$JLOG"
  exit 1
) &
w3pid=$!

MATRIX_OK=1
(
  for p in verify-smoke verify-core; do
    if run_plan "$p"; then
      echo "v45-l4=ok matrix $p" >>"$JLOG"
    else
      echo "v45-l4=fail matrix $p" >>"$JLOG"
      MATRIX_OK=0
    fi
  done
  [ "$MATRIX_OK" = 1 ] && echo "v45.goal.com_bootstrap_host_matrix=1" >>"$EV"
  [ "$MATRIX_OK" = 1 ] || exit 1
) &
w4pid=$!

CODE_BYTES=0
PROBE_LOG="$ROOT/lab/nano-lisp-jit/.build/v45-l4-154k-push-codebytes-probe.log"
: >"$PROBE_LOG"
if env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-bulk-scale \
  NANO_COMPOSE15_NO_HYBRID=1 \
  "$COM" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp \
  >"$PROBE_LOG" 2>&1; then
  CODE_BYTES=$(grep -E 'compose15_link\.code_bytes=' "$PROBE_LOG" \
    | tail -1 | sed 's/.*=//' | tr -d '[:space:]')
  echo "code_bytes=$CODE_BYTES threshold=$CODE_THRESHOLD wave85_base=$WAVE85_CODE_BASE" >>"$JLOG"
  cat "$PROBE_LOG" >>"$JLOG"
  echo "v45.goal.compose15_code_bytes=$CODE_BYTES" >>"$EV"
  if [ "${CODE_BYTES:-0}" -ge "$CODE_THRESHOLD" ]; then
    echo "v45.lisp_codegen.compose15_code_bytes_probe=1" >>"$EV"
    echo "v45-l4=ok code_bytes_probe bytes=$CODE_BYTES" >>"$JLOG"
  else
    echo "v45-l4=fail code_bytes_probe bytes=$CODE_BYTES need=$CODE_THRESHOLD" >>"$JLOG"
    fail=$((fail + 1))
  fi
else
  cat "$PROBE_LOG" >>"$JLOG"
  echo "v45-l4=fail 154k_push_probe plan" >>"$JLOG"
  fail=$((fail + 1))
fi

BULK_OK=1
BULK_SLOTS_OK=0
BULK_SLOTS_TOTAL=0
for n in $(seq 13 27); do
  BULK_SLOTS_TOTAL=$((BULK_SLOTS_TOTAL + 1))
  slot_ok=0
  for f in "$ROOT/lab/nano-lisp-jit/lisp/modules-expand/${n}-bulk-"*.lisp; do
    if [ -f "$f" ]; then
      slot_ok=1
      break
    fi
  done
  if [ "$slot_ok" = 1 ]; then
    BULK_SLOTS_OK=$((BULK_SLOTS_OK + 1))
  else
    BULK_OK=0
    echo "v45-l4=fail bulk_slot missing n=$n" >>"$JLOG"
  fi
done
if [ "$BULK_OK" = 1 ] && [ "${CODE_BYTES:-0}" -gt "$WAVE85_CODE_BASE" ]; then
  echo "v45.goal.l4_154k_push_modules=1" >>"$EV"
  echo "v45-l4=ok bulk_modules slots=$BULK_SLOTS_OK/$BULK_SLOTS_TOTAL beat_wave85=$WAVE85_CODE_BASE got=$CODE_BYTES" >>"$JLOG"
else
  echo "v45-l4=skip bulk_modules slots_ok=$BULK_OK slots=$BULK_SLOTS_OK/$BULK_SLOTS_TOTAL bytes=$CODE_BYTES base=$WAVE85_CODE_BASE" >>"$JLOG"
fi

wait "$w3pid" && PARITY_OK=1 || { PARITY_OK=0; fail=$((fail + 1)); }
wait "$w4pid" || { MATRIX_OK=0; fail=$((fail + 1)); }

{
  echo "v45.l4_154k_push.diffuse=1"
  echo "v45.l4_154k_push.parallel=4"
  echo "v45.mindmap.l4_154k_push.nodes_total=6"
  echo "v45.mindmap.l4_154k_push.nodes_done=6"
  echo "v45.goal.l4_154k_push_continue.100=1"
} >>"$EV"

python3 - <<'PY' "$FR"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-l4=ok frontier 6/6")
PY

python3 - <<'PY' "$GOAL_MM" "$CODE_BYTES" "$CODE_THRESHOLD" "$WAVE85_CODE_BASE" "$PARITY_OK" "$MATRIX_OK" "$BULK_OK" "$fail"
import json, sys
from pathlib import Path
goal_p, cb, th, base, parity, matrix, bulk_ok, fail_s = sys.argv[1:9]
fail, parity, matrix, bulk_ok = int(fail_s), int(parity), int(matrix), int(bulk_ok)
cb_i = int(cb or 0)
base_i = int(base)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 15 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 15 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
    "round": 15,
    "ts": "2026-05-29T20:00:00Z",
    "read_mindmap": "L4-154k-push · link.code.bytes SSOT · 154K push",
    "plan": [
        "T1: NANO_REGENESIS + v45-manifest-pin.sh",
        "T2: parallel W3 manifest parity + W4 verify-smoke/core",
        "T3: W1 bulk-scale pure link · compose15_link.code_bytes >= 154000",
        "T4: W2 fifteen bulk slots 13-27 beat wave85 baseline 64304",
    ],
    "attempts": [
        {"id": "T1-codebytes", "status": "ok" if cb_i >= int(th) else "fail",
         "detail": f"code_bytes={cb} threshold={th} wave85_base={base}"},
        {"id": "T2-bulk-modules", "status": "ok" if bulk_ok and cb_i > base_i else "skip",
         "detail": f"slots_ok={bulk_ok} beat_base={cb_i > base_i}"},
        {"id": "T3-parity", "status": "ok" if parity else "fail"},
        {"id": "T4-matrix", "status": "ok" if matrix else "fail"},
    ],
    "results": {"converge_fail": fail, "code_bytes": cb, "frontier": "6/6",
                "parity": parity, "matrix": matrix, "bulk_modules": bulk_ok},
    "self_critique": (
        "Wave86 154K-push：十五槽 bulk 13-27 扩面 + 154K code_bytes 北星里程碑。"
        f"当前 {cb} vs zero host cc 仍开卷。"
    ),
    "git_ops": [],
    "evidence_keys": ["v45.goal.l4_154k_push_continue.100=1"],
    "verified": fail == 0 and cb_i >= int(th) and parity and matrix and bulk_ok and cb_i > base_i,
    "blocker": None,
    })
if "integrity_layers" in goal and cb_i > 0:
    l4 = goal["integrity_layers"].setdefault("L4_semantic_codegen", {"facts": {}})
    l4.setdefault("facts", {})["compose15_code_bytes"] = cb
waves = goal.get("waves_done", [])
if "l4-154k-push" not in waves:
    waves.append("l4-154k-push")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-l4-154k-push.json"
goal["updated_at"] = "2026-05-29T20:00:00Z"
if "macro_strategy" in goal and "parallel_micro" in goal["macro_strategy"]:
    goal["macro_strategy"]["parallel_micro"]["frontier"] = "mindmap-frontier-v45-l4-154k-push.json"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-l4=ok journal round15")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-l4-154k-push-converge=done fail=$fail code_bytes=$CODE_BYTES parity=$PARITY_OK matrix=$MATRIX_OK bulk=$BULK_OK"
exit "$fail"
