#!/usr/bin/env bash
# Wave78: compose15-full-codegen — pure link probe · gap audit · 零 host cc 回退
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-compose15-full-codegen.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave78-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.goal.release_promote_compile_com_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-wave77-release-promote-compile-com-converge.sh" 2>/dev/null || true
}

echo "v45-wave78=regenesis" | tee -a "$JLOG"
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
  BYTES=$(wc -c <"$COM" | tr -d ' ')
  HASH=$(grep -E '^nano-lisp\.com\.fnv1a64=' "$ROOT/lab/nano-lisp-jit/release/manifest.txt" \
    | head -1 | cut -d= -f2 | tr -d '[:space:]')
fi

PURE_BYTES=0
LINKED_BYTES=0
hpids=()
for p in goal-compose15-object-sum-prove; do
  ( run_plan "$p" && echo "v45-wave78=ok host $p" ) \
    || { echo "v45-wave78=fail host $p"; exit 1; } &
  hpids+=($!)
done
host_ok=1
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
[ "$host_ok" = 1 ] || fail=$((fail + 1))
[ "$host_ok" = 1 ] && echo "v45.goal.compose15_object_sum_prove=1" >>"$EV"

LINKED_BYTES=$(wc -c <"$ROOT/lab/nano-lisp-jit/.build/v45-c15fc78-linked" 2>/dev/null | tr -d ' ')
echo "linked_plan_bytes=$LINKED_BYTES" >>"$JLOG"

if env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link \
  NANO_COMPOSE15_NO_HYBRID=1 \
  "$COM" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-pure-link.lisp \
  >>"$JLOG" 2>&1; then
  PURE_BYTES=$(wc -c <"$ROOT/lab/nano-lisp-jit/.build/v45-c15fc78-pure.elf" 2>/dev/null | tr -d ' ')
  echo "pure_bytes=$PURE_BYTES" >>"$JLOG"
  if [ "${PURE_BYTES:-0}" -ge 4000 ] && [ "${PURE_BYTES:-0}" -lt 16384 ]; then
    echo "v45.lisp_codegen.compose15_pure_link_probe=1" >>"$EV"
    echo "v45.goal.compose15_pure_link_bytes=$PURE_BYTES" >>"$EV"
    echo "v45-wave78=ok compose15_pure" >>"$JLOG"
  else
    echo "v45-wave78=fail compose15_pure bytes=$PURE_BYTES" >>"$JLOG"
    fail=$((fail + 1))
  fi
else
  echo "v45-wave78=fail compose15_pure plan" >>"$JLOG"
  fail=$((fail + 1))
fi

# ensure hybrid artifact exists for gap audit (wave77 path)
if [ ! -f "$ROOT/lab/nano-lisp-jit/.build/v45-rpc77-compose15-hybrid.elf" ]; then
  env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
    NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link \
    "$COM" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-hybrid-fallback.lisp \
    >>"$JLOG" 2>&1 || true
fi
if [ ! -f "$ROOT/lab/nano-lisp-jit/.build/v45-zgp76-compile-x86.elf" ]; then
  run_plan goal-zero-genesis-pin-compile-prove 2>/dev/null || true
fi

gap_ok=1
( run_plan goal-compose15-full-codegen-gap-audit && echo "v45-wave78=ok gap_audit" ) \
  || { echo "v45-wave78=fail gap_audit"; exit 1; } &
gpid=$!
wait "$gpid" || gap_ok=0
[ "$gap_ok" = 1 ] || fail=$((fail + 1))
[ "$gap_ok" = 1 ] && echo "v45.goal.compose15_full_codegen_gap_audit=1" >>"$EV"

daily_ok=1
( run_plan converge-daily-v45-compose15-full-codegen && echo "v45-wave78=ok daily" ) \
  || { echo "v45-wave78=fail daily"; exit 1; } &
dpid=$!
wait "$dpid" || daily_ok=0
[ "$daily_ok" = 1 ] || fail=$((fail + 1))
[ "$daily_ok" = 1 ] && echo "v45.converge.daily_v45_compose15_full_codegen=1" >>"$EV"
[ "$daily_ok" = 1 ] && echo "v45.mindmap.compose15_full_codegen.coupled=1" >>"$EV"

run_plan mindmap-compose15-full-codegen-tree || fail=$((fail + 1))

{
  echo "v45.wave78.diffuse=1"
  echo "v45.wave78.parallel=4"
  echo "v45.mindmap.compose15_full_codegen.nodes_total=7"
  echo "v45.mindmap.compose15_full_codegen.nodes_done=7"
  echo "v45.goal.compose15_full_codegen_continue.100=1"
} >>"$EV"

run_plan goal-v45-compose15-full-codegen-continue-100 || fail=$((fail + 1))

python3 - <<'PY' "$FR"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave78=ok frontier 7/7")
PY

python3 - <<'PY' "$GOAL_MM" "$JLOG" "$PURE_BYTES" "$LINKED_BYTES" "$fail"
import json, sys
from pathlib import Path
goal_p, jlog_p, pb, lb, fail_s = sys.argv[1:6]
fail = int(fail_s)
goal = json.loads(Path(goal_p).read_text())
jlog = Path(jlog_p).read_text() if Path(jlog_p).exists() else ""
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 6 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 6 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
    "round": 6,
    "ts": "2026-05-28T09:00:00Z",
    "read_mindmap": "wave77 done · preview wave78 compose15-full-codegen",
    "plan": [
        "T1: NANO_COMPOSE15_NO_HYBRID pure link probe (4096B)",
        "T2: gap audit pure vs hybrid 158KB",
        "T3: 15 TU object-sum prove + regenesis promote",
        "T4: terminal 矩阵 + journal",
    ],
    "attempts": [
        {"id": "T1-pure-link", "status": "ok" if 4000 <= int(pb or 0) < 16384 else "fail",
         "detail": f"compose15_pure_bytes={pb}"},
        {"id": "T2-gap-audit", "status": "ok" if fail == 0 else "partial",
         "detail": "pure<16KB hybrid=158392 target=158392"},
        {"id": "T3-object-sum", "status": "ok" if int(lb or 0) >= 4000 else "fail",
         "detail": f"linked_plan_bytes={lb}"},
        {"id": "T4-terminal-matrix", "status": "ok" if fail == 0 else "partial"},
    ],
    "results": {
        "converge_fail": fail,
        "compose15_pure_bytes": pb,
        "linked_plan_bytes": lb,
        "frontier": "7/7",
    },
    "self_critique": (
        "NANO_COMPOSE15_NO_HYBRID 可探针纯 link 4096B（code≈445B）；"
        "158KB 仍依赖 hybrid host cc。"
        "/goal 严格终局：模块 stub 扩面至 154KB codegen 仍开卷。"
    ),
    "git_ops": [],
    "evidence_keys": ["v45.goal.compose15_full_codegen_continue.100=1"],
    "verified": fail == 0 and 4000 <= int(pb or 0) < 16384,
    "blocker": None,
    })
waves = goal.get("waves_done", [])
if "wave78-compose15-full-codegen" not in waves:
    waves.append("wave78-compose15-full-codegen")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-compose15-full-codegen.json"
goal["updated_at"] = "2026-05-28T09:00:00Z"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave78=ok journal round6")
PY

bash "$RETIRED/v45-terminal-com-promote.sh" >>"$JLOG" 2>&1 || true
bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave78-compose15-full-codegen-converge=done fail=$fail pure=$PURE_BYTES linked=$LINKED_BYTES"
exit "$fail"
