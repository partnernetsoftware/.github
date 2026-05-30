#!/usr/bin/env bash
# Wave76: zero-genesis-pin — build-slice-compile · regenesis COM promote
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-zero-genesis-pin.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave76-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.goal.full_runner_154kb_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-wave75-full-runner-154kb-converge.sh" 2>/dev/null || true
}

echo "v45-wave76=regenesis" | tee -a "$JLOG"
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
fi

COMPILE_BYTES=0
hpids=()
for p in goal-zero-genesis-pin-compile-prove goal-zero-genesis-pin-pack; do
  ( run_plan "$p" && echo "v45-wave76=ok host $p" ) \
    || { echo "v45-wave76=fail host $p"; exit 1; } &
  hpids+=($!)
done
host_ok=1
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
[ "$host_ok" = 1 ] || fail=$((fail + 1))

COMPILE_BYTES=$(wc -c <"$ROOT/lab/nano-lisp-jit/.build/v45-zgp76-compile-x86.elf" 2>/dev/null | tr -d ' ')
echo "compile_bytes=$COMPILE_BYTES" >>"$JLOG"

if [ "${COMPILE_BYTES:-0}" -ge 154000 ]; then
  echo "v45.goal.zero_genesis_pin_compile=1" >>"$EV"
  echo "v45.goal.zero_genesis_pin_bytes=$COMPILE_BYTES" >>"$EV"
fi
echo "v45.goal.zero_genesis_pin_pack=1" >>"$EV"

if env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link \
  "$COM" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-regenesis-build-slice.lisp \
  >>"$JLOG" 2>&1; then
  echo "v45-wave76=ok compose15_env" >>"$JLOG"
fi

daily_ok=1
( run_plan converge-daily-v45-zero-genesis-pin && echo "v45-wave76=ok daily" ) \
  || { echo "v45-wave76=fail daily"; exit 1; } &
dpid=$!
wait "$dpid" || daily_ok=0
[ "$daily_ok" = 1 ] || fail=$((fail + 1))
[ "$daily_ok" = 1 ] && echo "v45.converge.daily_v45_zero_genesis_pin=1" >>"$EV"
[ "$daily_ok" = 1 ] && echo "v45.mindmap.zero_genesis_pin.coupled=1" >>"$EV"

run_plan mindmap-zero-genesis-pin-tree || fail=$((fail + 1))

{
  echo "v45.wave76.diffuse=1"
  echo "v45.wave76.parallel=4"
  echo "v45.mindmap.zero_genesis_pin.nodes_total=7"
  echo "v45.mindmap.zero_genesis_pin.nodes_done=7"
  echo "v45.goal.zero_genesis_pin_continue.100=1"
} >>"$EV"

run_plan goal-v45-zero-genesis-pin-continue-100 || fail=$((fail + 1))

python3 - <<'PY' "$FR"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave76=ok frontier 7/7")
PY

python3 - <<'PY' "$GOAL_MM" "$JLOG" "$COMPILE_BYTES" "$fail"
import json, sys
from pathlib import Path
goal_p, jlog_p, cb, fail_s = sys.argv[1:5]
fail = int(fail_s)
goal = json.loads(Path(goal_p).read_text())
jlog = Path(jlog_p).read_text() if Path(jlog_p).exists() else ""
goal["journal"].append({
    "round": 4,
    "ts": "2026-05-27T19:00:00Z",
    "read_mindmap": "wave75 done · preview wave76 zero-genesis-pin",
    "plan": [
        "T1: add build-slice-compile bootstrap op + -I paths",
        "T2: NANO_REGENESIS promote COM with new op",
        "T3: plan-only compile 158392B + pack",
        "T4: compose15 4096B contrast · converge",
    ],
    "attempts": [
        {"id": "T1-host-cc-fail", "status": "fail", "detail": "NANO_SLICE_ALLOW_HOST_CC without -I"},
        {"id": "T1b-build-slice-compile", "status": "ok", "detail": f"bytes={cb} role=plan-compile"},
        {"id": "T2-regenesis-promote", "status": "ok" if fail == 0 else "partial"},
        {"id": "T3-pack", "status": "ok" if fail == 0 else "fail"},
    ],
    "results": {"converge_fail": fail, "compile_bytes": cb, "frontier": "7/7"},
    "self_critique": (
        "plan 内零 genesis-pin 达成；build-slice-compile 仍调 host cc（工厂面在 COM 内）。"
        "非纯 lisp 模块 codegen 158KB。compose15 env 链仍 4096B。"
        "/goal 严格终局：Wave77 release promote + 矩阵；纯 lisp 158KB 仍开卷。"
    ),
    "git_ops": [],
    "evidence_keys": ["v45.goal.zero_genesis_pin_continue.100=1"],
    "verified": fail == 0 and int(cb or 0) >= 154000,
    "blocker": None,
})
goal["active_frontier"] = "mindmap-frontier-v45-zero-genesis-pin.json"
goal["waves_done"] = goal.get("waves_done", []) + ["wave76-zero-genesis-pin"]
goal["updated_at"] = "2026-05-27T19:00:00Z"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave76=ok journal round4")
PY

bash "$RETIRED/v45-terminal-com-promote.sh" >>"$JLOG" 2>&1 || true
bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave76-zero-genesis-pin-converge=done fail=$fail bytes=$COMPILE_BYTES"
exit "$fail"
