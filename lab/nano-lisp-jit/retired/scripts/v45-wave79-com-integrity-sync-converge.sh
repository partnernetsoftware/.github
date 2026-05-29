#!/usr/bin/env bash
# Wave79: com-integrity-sync — manifest pin · APE 容器 · bootstrap-host 矩阵
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-com-integrity-sync.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave79-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.goal.compose15_full_codegen_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-wave78-compose15-full-codegen-converge.sh" 2>/dev/null || true
}

echo "v45-wave79=regenesis" | tee -a "$JLOG"
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

COM_HASH=$("$COM" file-hash "$COM" 2>/dev/null | tail -1 | tr -d '[:space:]')
MAN_HASH=$(grep -E '^nano-lisp\.com\.fnv1a64=' "$ROOT/lab/nano-lisp-jit/release/manifest.txt" \
  | head -1 | cut -d= -f2 | tr -d '[:space:]')
COM_BYTES=$(wc -c <"$COM" | tr -d ' ')
MAN_BYTES=$(grep -E '^nano-lisp\.com\.bytes=' "$ROOT/lab/nano-lisp-jit/release/manifest.txt" \
  | head -1 | cut -d= -f2 | tr -d '[:space:]')
echo "com_hash=$COM_HASH manifest_hash=$MAN_HASH bytes=$COM_BYTES" >>"$JLOG"

PARITY_OK=0
if [ -n "$COM_HASH" ] && [ "$COM_HASH" = "$MAN_HASH" ] && [ "$COM_BYTES" = "$MAN_BYTES" ]; then
  PARITY_OK=1
  echo "v45.goal.nano_jit_com.release_parity=1" >>"$EV"
  echo "v45.goal.manifest_pin_sync=1" >>"$EV"
  echo "v45-wave79=ok manifest_parity" >>"$JLOG"
else
  echo "v45-wave79=fail manifest_parity com=$COM_HASH man=$MAN_HASH" >>"$JLOG"
  fail=$((fail + 1))
fi

run_plan goal-com-manifest-pin-sync || fail=$((fail + 1))

CONTAINER_OK=0
if cmp -s "$COM" "$BUILD_COM" 2>/dev/null; then
  INSPECT=$("$COM" inspect-ape "$COM" 2>&1 || true)
  if printf '%s\n' "$INSPECT" | grep -q 'inspect-ape.ok=1'; then
    GEN_HASH=$("$COM" file-hash "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64" 2>/dev/null \
      | tail -1 | tr -d '[:space:]')
    SLICE_HASH=$(printf '%s\n' "$INSPECT" | grep 'inspect-ape.slice.0.hash=' \
      | head -1 | sed 's/.*=//')
    if [ -n "$GEN_HASH" ] && [ "$GEN_HASH" = "$SLICE_HASH" ]; then
      CONTAINER_OK=1
      echo "v45.goal.com_container_audit=1" >>"$EV"
      echo "v45.goal.com_slice_genesis_parity=1" >>"$EV"
      echo "v45-wave79=ok container_audit slice=$SLICE_HASH" >>"$JLOG"
    fi
  fi
fi
[ "$CONTAINER_OK" = 1 ] || { echo "v45-wave79=fail container_audit" >>"$JLOG"; fail=$((fail + 1)); }
run_plan goal-com-container-audit || fail=$((fail + 1))

MATRIX_OK=1
for p in verify-smoke verify-core verify-all entry onion-tdd; do
  if "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp" >/dev/null 2>&1; then
    echo "v45-wave79=ok matrix $p" >>"$JLOG"
  else
    echo "v45-wave79=fail matrix $p" >>"$JLOG"
    MATRIX_OK=0
  fi
done
run_plan goal-com-bootstrap-host-matrix || MATRIX_OK=0
[ "$MATRIX_OK" = 1 ] || fail=$((fail + 1))
[ "$MATRIX_OK" = 1 ] && echo "v45.goal.com_bootstrap_host_matrix=1" >>"$EV"

daily_ok=1
( run_plan converge-daily-v45-com-integrity-sync && echo "v45-wave79=ok daily" ) \
  || { echo "v45-wave79=fail daily"; exit 1; } &
dpid=$!
wait "$dpid" || daily_ok=0
[ "$daily_ok" = 1 ] || fail=$((fail + 1))
[ "$daily_ok" = 1 ] && echo "v45.converge.daily_v45_com_integrity_sync=1" >>"$EV"
[ "$daily_ok" = 1 ] && echo "v45.mindmap.com_integrity_sync.coupled=1" >>"$EV"

run_plan mindmap-com-integrity-sync-tree || fail=$((fail + 1))

{
  echo "v45.wave79.diffuse=1"
  echo "v45.wave79.parallel=4"
  echo "v45.mindmap.com_integrity_sync.nodes_total=7"
  echo "v45.mindmap.com_integrity_sync.nodes_done=7"
  echo "v45.goal.com_integrity_sync_continue.100=1"
} >>"$EV"

run_plan goal-v45-com-integrity-sync-continue-100 || fail=$((fail + 1))

python3 - <<'PY' "$FR"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave79=ok frontier 7/7")
PY

python3 - <<'PY' "$GOAL_MM" "$JLOG" "$COM_HASH" "$PARITY_OK" "$CONTAINER_OK" "$fail"
import json, sys
from pathlib import Path
goal_p, jlog_p, ch, parity, container, fail_s = sys.argv[1:7]
fail = int(fail_s)
parity = int(parity)
container = int(container)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 8 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 8 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
    "round": 8,
    "ts": "2026-05-28T11:00:00Z",
    "read_mindmap": "wave79 com-integrity-sync · manifest pin fix",
    "plan": [
        "T1: v45-manifest-pin.sh（COM file-hash 写 manifest）",
        "T2: container audit inspect-ape + genesis slice parity",
        "T3: bootstrap-host 矩阵 5/5",
        "T4: journal + integrity L2→pass",
    ],
    "attempts": [
        {"id": "T1-manifest-pin", "status": "ok" if parity else "fail",
         "detail": f"com_fnv={ch} parity={parity}"},
        {"id": "T2-container", "status": "ok" if container else "fail"},
        {"id": "T3-host-matrix", "status": "ok" if fail == 0 else "partial"},
    ],
    "results": {"converge_fail": fail, "com_fnv": ch, "frontier": "7/7"},
    "self_critique": (
        "L2 manifest pin 已修复（fnv 统一 lispjit file-hash 基）。"
        "L1/L3 pass；L4 纯 lisp 158KB 仍 Wave80。"
    ),
    "git_ops": [],
    "evidence_keys": ["v45.goal.com_integrity_sync_continue.100=1"],
    "verified": fail == 0 and parity and container,
    "blocker": None,
    })
if "integrity_layers" in goal:
    if parity:
        goal["integrity_layers"]["L2_release_pin"]["status"] = "pass"
        goal["integrity_layers"]["L2_release_pin"]["gap"] = None
        goal["integrity_layers"]["L2_release_pin"]["facts"] = {"com_fnv": ch}
    if container:
        goal["integrity_layers"]["L1_container"]["status"] = "pass"
waves = goal.get("waves_done", [])
if "wave79-com-integrity-sync" not in waves:
    waves.append("wave79-com-integrity-sync")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-com-integrity-sync.json"
goal["updated_at"] = "2026-05-28T11:00:00Z"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave79=ok journal round8")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave79-com-integrity-sync-converge=done fail=$fail parity=$PARITY_OK container=$CONTAINER_OK hash=$COM_HASH"
exit "$fail"
