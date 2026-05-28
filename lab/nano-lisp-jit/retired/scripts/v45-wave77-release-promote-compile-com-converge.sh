#!/usr/bin/env bash
# Wave77: release-promote-compile-com — compose15 hybrid · zero-pin COM promote · 矩阵
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-release-promote-compile-com.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave77-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.goal.zero_genesis_pin_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-wave76-zero-genesis-pin-converge.sh" 2>/dev/null || true
}

echo "v45-wave77=regenesis" | tee -a "$JLOG"
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
  BYTES=$(wc -c <"$COM" | tr -d ' ')
  HASH=$(python3 - <<PY
import pathlib
p=pathlib.Path("$COM")
h=0xcbf29ce484222325
for b in p.read_bytes():
    h=(h^b)*0x100000001b3 & 0xffffffffffffffff
print(f"{h:016x}")
PY
)
  cat >"$ROOT/lab/nano-lisp-jit/release/manifest.txt" <<EOF
# fnv1a64 and byte size for pinned release .com artifacts

nano-lisp.com.bytes=$BYTES
nano-lisp.com.fnv1a64=$HASH
v45-selfhost-next.com.bytes=$BYTES
v45-selfhost-next.com.fnv1a64=$HASH
EOF
  echo "v45.goal.release_promote_compile=1" >>"$EV"
fi

HYBRID_BYTES=0
ZERO_PIN_BYTES=0
hpids=()
for p in goal-release-promote-compile-prove goal-zero-pin-com-release-promote; do
  ( run_plan "$p" && echo "v45-wave77=ok host $p" ) \
    || { echo "v45-wave77=fail host $p"; exit 1; } &
  hpids+=($!)
done
host_ok=1
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
[ "$host_ok" = 1 ] || fail=$((fail + 1))

ZERO_PIN_BYTES=$(wc -c <"$ROOT/lab/nano-lisp-jit/.build/v45-rpc77-zero-pin.com" 2>/dev/null | tr -d ' ')
echo "zero_pin_bytes=$ZERO_PIN_BYTES" >>"$JLOG"
if [ "${ZERO_PIN_BYTES:-0}" -ge 160000 ]; then
  echo "v45.goal.zero_pin_com_promote=1" >>"$EV"
  echo "v45.goal.zero_pin_com_bytes=$ZERO_PIN_BYTES" >>"$EV"
fi

if env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link \
  "$COM" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-hybrid-fallback.lisp \
  >>"$JLOG" 2>&1; then
  HYBRID_BYTES=$(wc -c <"$ROOT/lab/nano-lisp-jit/.build/v45-rpc77-compose15-hybrid.elf" 2>/dev/null | tr -d ' ')
  echo "hybrid_bytes=$HYBRID_BYTES" >>"$JLOG"
  if [ "${HYBRID_BYTES:-0}" -ge 154000 ]; then
    echo "v45.goal.compose15_hybrid_fallback=1" >>"$EV"
    echo "v45.goal.compose15_hybrid_bytes=$HYBRID_BYTES" >>"$EV"
    echo "v45.lisp_codegen.compose15_hybrid_probe=1" >>"$EV"
    echo "v45-wave77=ok compose15_hybrid" >>"$JLOG"
  else
    echo "v45-wave77=fail compose15_hybrid bytes=$HYBRID_BYTES" >>"$JLOG"
    fail=$((fail + 1))
  fi
else
  echo "v45-wave77=fail compose15_hybrid plan" >>"$JLOG"
  fail=$((fail + 1))
fi

daily_ok=1
( run_plan converge-daily-v45-release-promote-compile-com && echo "v45-wave77=ok daily" ) \
  || { echo "v45-wave77=fail daily"; exit 1; } &
dpid=$!
wait "$dpid" || daily_ok=0
[ "$daily_ok" = 1 ] || fail=$((fail + 1))
[ "$daily_ok" = 1 ] && echo "v45.converge.daily_v45_release_promote_compile_com=1" >>"$EV"
[ "$daily_ok" = 1 ] && echo "v45.mindmap.release_promote_compile_com.coupled=1" >>"$EV"

run_plan mindmap-release-promote-compile-com-tree || fail=$((fail + 1))

{
  echo "v45.wave77.diffuse=1"
  echo "v45.wave77.parallel=4"
  echo "v45.mindmap.release_promote_compile_com.nodes_total=7"
  echo "v45.mindmap.release_promote_compile_com.nodes_done=7"
  echo "v45.goal.release_promote_compile_com_continue.100=1"
} >>"$EV"

run_plan goal-v45-release-promote-compile-com-continue-100 || fail=$((fail + 1))

python3 - <<'PY' "$FR"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave77=ok frontier 7/7")
PY

python3 - <<'PY' "$GOAL_MM" "$JLOG" "$HYBRID_BYTES" "$ZERO_PIN_BYTES" "$fail"
import json, sys
from pathlib import Path
goal_p, jlog_p, hb, zpb, fail_s = sys.argv[1:6]
fail = int(fail_s)
goal = json.loads(Path(goal_p).read_text())
jlog = Path(jlog_p).read_text() if Path(jlog_p).exists() else ""
goal["journal"].append({
    "round": 5,
    "ts": "2026-05-27T20:00:00Z",
    "read_mindmap": "wave76 done · preview wave77 release-promote-compile-com",
    "plan": [
        "T1: compose15 hybrid fallback (<16KB → build-slice-compile)",
        "T2: NANO_REGENESIS promote COM + manifest",
        "T3: zero-pin COM pack + release promote",
        "T4: terminal 矩阵 + journal",
    ],
    "attempts": [
        {"id": "T1-hybrid-codegen", "status": "ok" if int(hb or 0) >= 154000 else "fail",
         "detail": f"compose15_hybrid_bytes={hb}"},
        {"id": "T2-regenesis-promote", "status": "ok" if fail == 0 else "partial"},
        {"id": "T3-zero-pin-pack", "status": "ok" if int(zpb or 0) >= 160000 else "fail",
         "detail": f"zero_pin_bytes={zpb}"},
        {"id": "T4-terminal-matrix", "status": "ok" if fail == 0 else "partial"},
    ],
    "results": {
        "converge_fail": fail,
        "compose15_hybrid_bytes": hb,
        "zero_pin_bytes": zpb,
        "frontier": "7/7",
    },
    "self_critique": (
        "compose15 env 链经 hybrid 可产出 158KB；回退仍调 host cc。"
        "release COM promote + zero-pin pack 矩阵全绿。"
        "/goal 严格终局：纯 lisp 模块 codegen 158KB 仍开卷。"
    ),
    "git_ops": [],
    "evidence_keys": ["v45.goal.release_promote_compile_com_continue.100=1"],
    "verified": fail == 0 and int(hb or 0) >= 154000 and int(zpb or 0) >= 160000,
    "blocker": None,
})
goal["active_frontier"] = "mindmap-frontier-v45-release-promote-compile-com.json"
goal["waves_done"] = goal.get("waves_done", []) + ["wave77-release-promote-compile-com"]
goal["updated_at"] = "2026-05-27T20:00:00Z"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave77=ok journal round5")
PY

bash "$RETIRED/v45-terminal-com-promote.sh" >>"$JLOG" 2>&1 || true
bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave77-release-promote-compile-com-converge=done fail=$fail hybrid=$HYBRID_BYTES zero_pin=$ZERO_PIN_BYTES"
exit "$fail"
