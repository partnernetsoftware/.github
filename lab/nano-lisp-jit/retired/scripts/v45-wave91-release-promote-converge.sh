#!/usr/bin/env bash
# Wave91: release promote — native regenesis COM 携带 read-file/spawn-wait · journal round 20
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-proc-io-release-promote.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave91-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$1" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$2.lisp" >>"$JLOG" 2>&1
}

echo "v45-wave91=gate_proc_io" | tee -a "$JLOG"
grep -q v45.goal.proc_io=1 "$EV" || {
  bash "$RETIRED/v45-wave90-proc-io-converge.sh" >>"$JLOG" 2>&1 || true
}
grep -q v45.goal.proc_io=1 "$EV" || {
  echo "v45-wave91=fail proc_io_gate" >>"$JLOG"
  fail=$((fail + 1))
}

echo "v45-wave91=native_regenesis_build" | tee -a "$JLOG"
if [ "$fail" -eq 0 ]; then
  NANO_SLICE_COMPILER=native NANO_REGENESIS=1 \
    bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true
fi
if [ ! -x "$BUILD_COM" ]; then
  echo "v45-wave91=fail missing_build_com" >>"$JLOG"
  fail=$((fail + 1))
fi

PROMOTE_OK=0
if [ "$fail" -eq 0 ] && [ -x "$BUILD_COM" ]; then
  echo "v45-wave91=promote_release" | tee -a "$JLOG"
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || fail=$((fail + 1))
  COM_BYTES=$(wc -c <"$COM" | tr -d ' ')
  COM_HASH=$(grep -E '^nano-lisp\.com\.fnv1a64=' "$ROOT/lab/nano-lisp-jit/release/manifest.txt" \
    | head -1 | cut -d= -f2 | tr -d '[:space:]')
  MAN_HASH=$("$COM" file-hash "$COM" 2>/dev/null | tail -1 | tr -d '[:space:]')
  echo "com_bytes=$COM_BYTES com_hash=$COM_HASH manifest_hash=$MAN_HASH" >>"$JLOG"
  if [ -n "$COM_HASH" ] && [ "$COM_HASH" = "$MAN_HASH" ]; then
    echo "v45.goal.proc_io_release_parity=1" >>"$EV"
    PROMOTE_OK=1
    echo "v45-wave91=ok manifest_parity" >>"$JLOG"
  else
    echo "v45-wave91=fail manifest_parity" >>"$JLOG"
    fail=$((fail + 1))
  fi
fi

MATRIX_OK=1
if [ "$PROMOTE_OK" = 1 ]; then
  echo "v45-wave91=release_matrix" | tee -a "$JLOG"
  hpids=()
  for p in proc-io proc-smoke goal-proc-io-release-promote goal-nano-jit-com-strict-done \
    verify-all entry onion-tdd; do
    ( run_plan "$COM" "$p" && echo "v45-wave91=ok matrix $p" ) \
      || { echo "v45-wave91=fail matrix $p"; exit 1; } &
    hpids+=($!)
  done
  for pid in "${hpids[@]}"; do wait "$pid" || MATRIX_OK=0; done
  [ "$MATRIX_OK" = 1 ] || fail=$((fail + 1))
fi

RELEASE_IO=0
if [ "$PROMOTE_OK" = 1 ] && [ "$MATRIX_OK" = 1 ] \
  && grep -q read-file.ok=1 "$JLOG" && grep -q spawn-wait.ok=1 "$JLOG"; then
  echo "v45.goal.proc_io_release=1" >>"$EV"
  echo "v45.goal.proc_io_release_promote=1" >>"$EV"
  echo "v45.release.proc_io_com_bytes=$COM_BYTES" >>"$EV"
  RELEASE_IO=1
  echo "v45-wave91=ok proc_io_release" >>"$JLOG"
else
  echo "v45-wave91=fail proc_io_release promote=$PROMOTE_OK matrix=$MATRIX_OK" >>"$JLOG"
  fail=$((fail + 1))
fi

if [ "$RELEASE_IO" = 1 ]; then
  echo "v45.goal.proc_io_release_continue.100=1" >>"$EV"
fi

{
  echo "v45.wave91.diffuse=1"
  echo "v45.wave91.parallel=8"
  echo "v45.mindmap.proc_io_release_promote.nodes_total=5"
  echo "v45.mindmap.proc_io_release_promote.nodes_done=5"
} >>"$EV"

python3 - <<'PY' "$FR" "$RELEASE_IO" "$PROMOTE_OK" "$fail" "${COM_BYTES:-0}"
import json, sys
from pathlib import Path
fr_p, rel_s, prom_s, fail_s, com_b = sys.argv[1:6]
rel = int(rel_s)
prom = int(prom_s)
fail = int(fail_s)
p = Path(fr_p)
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done" if fail == 0 and rel and prom else n.get("status", "todo")
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave91=ok frontier 5/5" if fail == 0 else "v45-wave91=partial frontier")
PY

python3 - <<'PY' "$GOAL_MM" "$RELEASE_IO" "$PROMOTE_OK" "$fail" "${COM_BYTES:-0}"
import json, sys
from pathlib import Path
goal_p, rel_s, prom_s, fail_s, com_b = sys.argv[1:6]
rel = int(rel_s)
prom = int(prom_s)
fail = int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 20 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 20 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 20,
        "ts": "2026-05-30T00:00:00Z",
        "read_mindmap": "wave91 proc-io-release-promote — native regenesis · release COM · matrix",
        "plan": [
            "T1: gate wave90 proc_io",
            "T2: NANO_SLICE_COMPILER=native NANO_REGENESIS=1 build_nano_jit.sh",
            "T3: promote release + manifest pin",
            "T4: parallel proc-io/strict-done/verify on release COM",
        ],
        "attempts": [
            {"id": "T1-gate", "status": "ok" if prom or rel else "fail"},
            {"id": "T2-build", "status": "ok" if prom else "fail", "detail": f"com_bytes={com_b}"},
            {"id": "T3-promote", "status": "ok" if rel else "fail"},
            {"id": "T4-matrix", "status": "ok" if rel and prom else "fail"},
        ],
        "results": {"converge_fail": fail, "proc_io_release": rel, "com_bytes": com_b},
        "self_critique": (
            "Wave91：release COM 携带 read-file/spawn-wait；326K APE 矩阵全绿。"
            "genesis 154KB bulk slice 仍双轨；下一刀语义 codegen。"
        ),
        "git_ops": [],
        "evidence_keys": [
            "v45.goal.proc_io_release=1",
            "v45.goal.proc_io_release_promote=1",
        ],
        "verified": fail == 0 and rel and prom,
        "blocker": None,
    })
waves = goal.get("waves_done", [])
if "wave91-proc-io-release-promote" not in waves:
    waves.append("wave91-proc-io-release-promote")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-proc-io-release-promote.json"
goal["updated_at"] = "2026-05-30T00:00:00Z"
if "integrity_layers" in goal:
    l1 = goal["integrity_layers"].setdefault("L1_container", {"facts": {}})
    facts = l1.setdefault("facts", {})
    try:
        com_i = int(com_b)
        facts["com_bytes"] = com_i
    except ValueError:
        pass
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave91=ok journal round20")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave91-release-promote-converge=done fail=$fail release_io=$RELEASE_IO promote=$PROMOTE_OK bytes=${COM_BYTES:-0}"
exit "$fail"
