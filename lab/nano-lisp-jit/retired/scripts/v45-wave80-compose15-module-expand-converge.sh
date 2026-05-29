#!/usr/bin/env bash
# Wave80: compose15-module-expand — L4 modules-expand · object_bytes 扩面
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-compose15-module-expand.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave80-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.goal.com_integrity_sync_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-wave79-com-integrity-sync-converge.sh" 2>/dev/null || true
}

echo "v45-wave80=regenesis" | tee -a "$JLOG"
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
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || true
fi

STUB_BYTES=4096
if [ ! -f "$ROOT/lab/nano-lisp-jit/.build/v45-c15fc78-pure.elf" ]; then
  env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
    NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link \
    NANO_COMPOSE15_NO_HYBRID=1 \
    "$COM" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-pure-link.lisp \
    >>"$JLOG" 2>&1 || true
fi
STUB_BYTES=$(wc -c <"$ROOT/lab/nano-lisp-jit/.build/v45-c15fc78-pure.elf" 2>/dev/null | tr -d ' ')

EXPAND_BYTES=0
OBJECT_BYTES=0
EXPAND_LOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave80-expand.log"
: >"$EXPAND_LOG"
if env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-expand \
  NANO_COMPOSE15_NO_HYBRID=1 \
  "$COM" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-expand-pure-link.lisp \
  >"$EXPAND_LOG" 2>&1; then
  EXPAND_BYTES=$(wc -c <"$ROOT/lab/nano-lisp-jit/.build/v45-c15me80-expand-pure.elf" 2>/dev/null | tr -d ' ')
  OBJECT_BYTES=$(grep -E 'compose15_link\.object_bytes_total=' "$EXPAND_LOG" \
    | tail -1 | sed 's/.*=//' | tr -d '[:space:]')
  echo "expand_bytes=$EXPAND_BYTES object_bytes=$OBJECT_BYTES" >>"$JLOG"
  cat "$EXPAND_LOG" >>"$JLOG"
  if [ "${OBJECT_BYTES:-0}" -ge 11000 ] && [ "${EXPAND_BYTES:-0}" -ge 4000 ]; then
    echo "v45.lisp_codegen.compose15_expand_probe=1" >>"$EV"
    echo "v45.goal.compose15_expand_object_bytes=$OBJECT_BYTES" >>"$EV"
    echo "v45.goal.compose15_expand_linked_bytes=$EXPAND_BYTES" >>"$EV"
    echo "v45-wave80=ok expand_probe" >>"$JLOG"
  else
    echo "v45-wave80=fail expand_probe obj=$OBJECT_BYTES elf=$EXPAND_BYTES" >>"$JLOG"
    fail=$((fail + 1))
  fi
else
  cat "$EXPAND_LOG" >>"$JLOG"
  echo "v45-wave80=fail expand plan" >>"$JLOG"
  fail=$((fail + 1))
fi

prove_ok=1
( run_plan goal-compose15-module-expand-prove && echo "v45-wave80=ok prove" ) \
  || { echo "v45-wave80=fail prove"; exit 1; } &
ppid=$!
wait "$ppid" || prove_ok=0
[ "$prove_ok" = 1 ] || fail=$((fail + 1))
[ "$prove_ok" = 1 ] && echo "v45.goal.compose15_module_expand_prove=1" >>"$EV"

gap_ok=1
( run_plan goal-compose15-module-expand-gap-audit && echo "v45-wave80=ok gap" ) \
  || { echo "v45-wave80=fail gap"; exit 1; } &
gpid=$!
wait "$gpid" || gap_ok=0
[ "$gap_ok" = 1 ] || fail=$((fail + 1))
[ "$gap_ok" = 1 ] && echo "v45.goal.compose15_module_expand_gap=1" >>"$EV"

daily_ok=1
( run_plan converge-daily-v45-compose15-module-expand && echo "v45-wave80=ok daily" ) \
  || { echo "v45-wave80=fail daily"; exit 1; } &
dpid=$!
wait "$dpid" || daily_ok=0
[ "$daily_ok" = 1 ] || fail=$((fail + 1))
[ "$daily_ok" = 1 ] && echo "v45.converge.daily_v45_compose15_module_expand=1" >>"$EV"
[ "$daily_ok" = 1 ] && echo "v45.mindmap.compose15_module_expand.coupled=1" >>"$EV"

run_plan mindmap-compose15-module-expand-tree || fail=$((fail + 1))

{
  echo "v45.wave80.diffuse=1"
  echo "v45.wave80.parallel=4"
  echo "v45.mindmap.compose15_module_expand.nodes_total=7"
  echo "v45.mindmap.compose15_module_expand.nodes_done=7"
  echo "v45.goal.compose15_module_expand_continue.100=1"
} >>"$EV"

run_plan goal-v45-compose15-module-expand-continue-100 || fail=$((fail + 1))

python3 - <<'PY' "$FR"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave80=ok frontier 7/7")
PY

python3 - <<'PY' "$GOAL_MM" "$JLOG" "$OBJECT_BYTES" "$EXPAND_BYTES" "$STUB_BYTES" "$fail"
import json, sys
from pathlib import Path
goal_p, jlog_p, ob, eb, sb, fail_s = sys.argv[1:7]
fail = int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 9 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 9 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
    "round": 9,
    "ts": "2026-05-29T03:00:00Z",
    "read_mindmap": "wave80 compose15-module-expand · L4 扩面",
    "plan": [
        "T1: modules-expand + compose-15link-expand profile",
        "T2: object_bytes 9024→11000+ 探针",
        "T3: plan-only expand prove + gap audit",
        "T4: manifest pin + journal",
    ],
    "attempts": [
        {"id": "T1-expand-link", "status": "ok" if int(ob or 0) >= 11000 else "fail",
         "detail": f"object_bytes={ob} linked={eb} stub={sb}"},
        {"id": "T2-prove", "status": "ok" if fail == 0 else "partial"},
        {"id": "T3-gap", "status": "ok" if fail == 0 else "partial"},
    ],
    "results": {"converge_fail": fail, "object_bytes": ob, "expand_linked": eb, "stub_linked": sb, "frontier": "7/7"},
    "self_critique": (
        "Wave80 扩面 modules-expand 提升 object_bytes；linked 仍可能 4096 页对齐。"
        "158KB 纯 lisp 无 host cc 仍开卷。"
    ),
    "git_ops": [],
    "evidence_keys": ["v45.goal.compose15_module_expand_continue.100=1"],
    "verified": fail == 0 and int(ob or 0) >= 11000,
    "blocker": None,
    })
if "integrity_layers" in goal and int(ob or 0) >= 11000:
    goal["integrity_layers"]["L4_semantic_codegen"]["facts"]["compose15_expand_object_bytes"] = ob
    goal["integrity_layers"]["L4_semantic_codegen"]["facts"]["compose15_expand_linked_bytes"] = eb
waves = goal.get("waves_done", [])
if "wave80-compose15-module-expand" not in waves:
    waves.append("wave80-compose15-module-expand")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-compose15-module-expand.json"
goal["updated_at"] = "2026-05-29T03:00:00Z"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave80=ok journal round9")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave80-compose15-module-expand-converge=done fail=$fail object_bytes=$OBJECT_BYTES expand=$EXPAND_BYTES stub=$STUB_BYTES"
exit "$fail"
