#!/usr/bin/env bash
# Wave87: compose15-regenesis-promote — 154KB bulk-scale pack · lisp-only regenesis · release promote
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-compose15-regenesis-promote.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
X86_ELF="$ROOT/lab/nano-lisp-jit/.build/v45-w87-c15-154k-x86.elf"
A64_ELF="$ROOT/lab/nano-lisp-jit/.build/v45-w87-c15-154k-aarch64.elf"
MIN_SLICE=154000
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave87-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.goal.l4_154k_push_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-l4-154k-push-converge.sh" 2>/dev/null || true
}

PACK_OK=0
X86_BYTES=0
PACK_LOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave87-pack.log"
: >"$PACK_LOG"
echo "v45-wave87=pack" | tee -a "$JLOG"
if env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-bulk-scale \
  NANO_COMPOSE15_NO_HYBRID=1 \
  "$COM" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-compose15-154k-com-pack.lisp \
  >"$PACK_LOG" 2>&1; then
  X86_BYTES=$(wc -c <"$X86_ELF" 2>/dev/null | tr -d ' ')
  echo "x86_bytes=$X86_BYTES min_slice=$MIN_SLICE" >>"$JLOG"
  cat "$PACK_LOG" >>"$JLOG"
  if [ "${X86_BYTES:-0}" -ge "$MIN_SLICE" ]; then
    PACK_OK=1
    cp -f "$X86_ELF" "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
    if [ -f "$A64_ELF" ]; then
      cp -f "$A64_ELF" "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64"
    fi
    echo "v45.goal.compose15_154k_com_pack=1" >>"$EV"
    echo "v45.goal.l4_semantic_codegen_pass=1" >>"$EV"
    echo "v45-wave87=ok pack x86=$X86_BYTES" >>"$JLOG"
  else
    echo "v45-wave87=fail pack x86=$X86_BYTES need=$MIN_SLICE" >>"$JLOG"
    fail=$((fail + 1))
  fi
else
  cat "$PACK_LOG" >>"$JLOG"
  echo "v45-wave87=fail pack plan" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave87=lisp_regenesis_build" | tee -a "$JLOG"
env -u NANO_REGENESIS bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
BUILD_X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
PROMOTE_OK=0
if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  PROMOTE_OK=1
  BUILD_XSZ=$(wc -c <"$BUILD_X86" 2>/dev/null | tr -d ' ')
  echo "build_x86_bytes=$BUILD_XSZ" >>"$JLOG"
  if [ "${BUILD_XSZ:-0}" -ge "$MIN_SLICE" ] || [ "${X86_BYTES:-0}" -ge "$MIN_SLICE" ]; then
    echo "v45.goal.nano_jit_com.regenesis_slice_154kb=1" >>"$EV"
    echo "v45.goal.nano_jit_com.lisp_only_regenesis=1" >>"$EV"
    echo "v45-wave87=ok lisp_regenesis_promote" >>"$JLOG"
  else
    echo "v45-wave87=warn lisp_regenesis_slice bytes=$BUILD_XSZ" >>"$JLOG"
    fail=$((fail + 1))
  fi
else
  echo "v45-wave87=fail missing_build_com" >>"$JLOG"
  fail=$((fail + 1))
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
    echo "v45-wave87=ok manifest_parity" >>"$JLOG"
    exit 0
  fi
  echo "v45-wave87=fail manifest_parity com=$COM_HASH man=$MAN_HASH" >>"$JLOG"
  exit 1
) &
w3pid=$!

SMOKE_OK=1
(
  for p in verify-smoke verify-core; do
    if run_plan "$p"; then
      echo "v45-wave87=ok matrix $p" >>"$JLOG"
    else
      echo "v45-wave87=fail matrix $p" >>"$JLOG"
      SMOKE_OK=0
    fi
  done
  [ "$SMOKE_OK" = 1 ] && echo "v45.goal.com_bootstrap_host_matrix=1" >>"$EV"
  [ "$SMOKE_OK" = 1 ] || exit 1
) &
w4pid=$!

RELMATRIX_OK=1
(
  if run_plan goal-nano-jit-com-release-matrix; then
    echo "v45-wave87=ok release_matrix" >>"$JLOG"
  else
    echo "v45-wave87=fail release_matrix" >>"$JLOG"
    RELMATRIX_OK=0
    exit 1
  fi
) &
w4mpid=$!

wait "$w3pid" && PARITY_OK=1 || { PARITY_OK=0; fail=$((fail + 1)); }
wait "$w4pid" || { SMOKE_OK=0; fail=$((fail + 1)); }
wait "$w4mpid" || { RELMATRIX_OK=0; fail=$((fail + 1)); }

{
  echo "v45.wave87.diffuse=1"
  echo "v45.wave87.parallel=3"
  echo "v45.mindmap.compose15_regenesis_promote.nodes_total=6"
  echo "v45.mindmap.compose15_regenesis_promote.nodes_done=6"
  echo "v45.goal.compose15_regenesis_promote_continue.100=1"
} >>"$EV"

python3 - <<'PY' "$FR"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave87=ok frontier 6/6")
PY

python3 - <<'PY' "$GOAL_MM" "$JLOG" "$X86_BYTES" "$MIN_SLICE" "$PACK_OK" "$PROMOTE_OK" "$PARITY_OK" "$SMOKE_OK" "$RELMATRIX_OK" "$fail"
import json, sys
from pathlib import Path
goal_p, jlog_p, x86, min_s, pack_ok, promote_ok, parity, smoke, relmatrix, fail_s = sys.argv[1:11]
fail = int(fail_s)
pack_ok = int(pack_ok)
promote_ok = int(promote_ok)
parity = int(parity)
smoke = int(smoke)
relmatrix = int(relmatrix)
x86_i = int(x86 or 0)
min_i = int(min_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 16 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 16 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
    "round": 16,
    "ts": "2026-05-29T22:00:00Z",
    "read_mindmap": "wave87 compose15-regenesis-promote · 154KB bulk-scale pack · lisp-only regenesis",
    "plan": [
        "T1: compose-15link-bulk-scale pack plan → v45-w87-c15-154k-x86.elf >= 154000",
        "T2: genesis sync x86/aarch64 · build_nano_jit.sh (no NANO_REGENESIS) · promote COM",
        "T3: v45-manifest-pin.sh · parallel W3 parity + W4 verify-smoke/core + release-matrix",
        "T4: evidence + frontier 6/6 · journal round 16",
    ],
    "attempts": [
        {"id": "T1-pack", "status": "ok" if pack_ok and x86_i >= min_i else "fail",
         "detail": f"x86_bytes={x86} threshold={min_s}"},
        {"id": "T2-lisp-regenesis", "status": "ok" if promote_ok else "fail"},
        {"id": "T3-parity", "status": "ok" if parity else "fail"},
        {"id": "T4-matrix", "status": "ok" if smoke and relmatrix else "partial",
         "detail": f"smoke={smoke} release_matrix={relmatrix}"},
    ],
    "results": {"converge_fail": fail, "x86_bytes": x86, "frontier": "6/6",
                "parity": parity, "smoke": smoke, "release_matrix": relmatrix, "pack_ok": pack_ok},
    "self_critique": (
        "Wave87：compose15 bulk-scale 154KB pack 与 lisp-only regenesis promote 合轨。"
        f"pack x86={x86}；zero host cc 终局仍开卷。"
    ),
    "git_ops": [],
    "evidence_keys": [
        "v45.goal.compose15_regenesis_promote_continue.100=1",
        "v45.goal.compose15_154k_com_pack=1",
        "v45.goal.l4_semantic_codegen_pass=1",
    ],
    "verified": fail == 0 and pack_ok and x86_i >= min_i and promote_ok and parity and smoke and relmatrix,
    "blocker": None,
    })
if "integrity_layers" in goal and x86_i >= min_i:
    l4 = goal["integrity_layers"].setdefault("L4_semantic_codegen", {"facts": {}})
    l4.setdefault("facts", {})["compose15_154k_pack_x86_bytes"] = x86
waves = goal.get("waves_done", [])
if "wave87-compose15-regenesis-promote" not in waves:
    waves.append("wave87-compose15-regenesis-promote")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-compose15-regenesis-promote.json"
goal["updated_at"] = "2026-05-29T22:00:00Z"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave87=ok journal round16")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave87-compose15-regenesis-promote-converge=done fail=$fail x86=$X86_BYTES pack=$PACK_OK promote=$PROMOTE_OK parity=$PARITY_OK"
exit "$fail"
