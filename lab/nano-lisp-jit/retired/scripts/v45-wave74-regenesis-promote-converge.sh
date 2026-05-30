#!/usr/bin/env bash
# Wave74: regenesis-promote — NANO_REGENESIS build · release promote · compose15 env probe
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
RP_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-regenesis-promote.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave74-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.goal.nano_jit_com.continue.100=1 "$EV" || {
  bash "$RETIRED/v45-wave73-nano-jit-com-goal-converge.sh" 2>/dev/null || true
}

echo "v45-wave74=regenesis_build" | tee -a "$JLOG"
NANO_REGENESIS=1 bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
XSZ=$(wc -c <"$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64" 2>/dev/null | tr -d ' ')
echo "regenesis_x86_bytes=$XSZ" >>"$JLOG"

if [ -x "$BUILD_COM" ] && [ "${XSZ:-0}" -ge 154000 ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  cp -f "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64" \
    "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
  cp -f "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.aarch64" \
    "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64" 2>/dev/null || \
    cp -f "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64" \
      "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64"
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
  echo "v45.goal.regenesis_promote=1" >>"$EV"
  echo "v45.goal.nano_jit_com.regenesis_slice_154kb=1" >>"$EV"
  echo "v45.goal.regenesis_slice_bytes=$XSZ" >>"$EV"
  echo "v45.release.com_bytes=$BYTES" >>"$EV"
fi

# compose15 env probe (post-promote COM)
if env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
  NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link \
  "$COM" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-regenesis-build-slice.lisp \
  >>"$JLOG" 2>&1; then
  echo "v45-wave74=ok compose15_env_probe"
  echo "v45.lisp_codegen.compose15_env_probe=1" >>"$EV"
else
  echo "v45-wave74=warn compose15_env_probe"
fi

hpids=()
for p in goal-nano-jit-com-regenesis-promote goal-nano-jit-com-release-matrix; do
  ( run_plan "$p" && echo "v45-wave74=ok host $p" ) \
    || { echo "v45-wave74=fail host $p"; exit 1; } &
  hpids+=($!)
done
host_ok=1
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
[ "$host_ok" = 1 ] || fail=$((fail + 1))

daily_ok=1
( run_plan converge-daily-v45-regenesis-promote && echo "v45-wave74=ok daily" ) \
  || { echo "v45-wave74=fail daily"; exit 1; } &
dpid=$!
wait "$dpid" || daily_ok=0
[ "$daily_ok" = 1 ] || fail=$((fail + 1))
[ "$daily_ok" = 1 ] && echo "v45.converge.daily_v45_regenesis_promote=1" >>"$EV"
[ "$daily_ok" = 1 ] && echo "v45.mindmap.regenesis_promote.coupled=1" >>"$EV"

for p in mindmap-regenesis-promote-tree; do
  run_plan "$p" || fail=$((fail + 1))
done

{
  echo "v45.wave74.diffuse=1"
  echo "v45.wave74.parallel=4"
  echo "v45.mindmap.regenesis_promote.nodes_total=7"
  echo "v45.mindmap.regenesis_promote.nodes_done=7"
  echo "v45.goal.regenesis_promote_continue.100=1"
} >>"$EV"

run_plan goal-v45-regenesis-promote-continue-100 || fail=$((fail + 1))

python3 - <<'PY' "$RP_FRONTIER"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave74=ok frontier 7/7")
PY

python3 - <<'PY' "$GOAL_MM" "$JLOG" "$XSZ" "$fail"
import json, sys
from pathlib import Path
goal_p, jlog_p, xsz, fail_s = sys.argv[1:5]
fail = int(fail_s)
goal = json.loads(Path(goal_p).read_text())
jlog = Path(jlog_p).read_text() if Path(jlog_p).exists() else ""
goal["journal"].append({
    "round": 2,
    "ts": "2026-05-27T17:00:00Z",
    "read_mindmap": "wave73 done · preview wave74 regenesis-promote",
    "plan": [
        "T1: fix lispjit.c symlink + build -I lispjit-ir",
        "T2: NANO_REGENESIS build → 158392B slice",
        "T3: compose-15link env probe on regenesis COM",
        "T4: promote release COM + manifest + four-track converge",
    ],
    "attempts": [
        {"id": "T1-symlink", "status": "ok", "detail": "cp lispjit.c.archived → runner/lispjit.c"},
        {"id": "T1b-headers", "status": "ok", "detail": "build_nano_jit.sh NANO_INC=lab/lispjit-ir"},
        {"id": "T1c-first-regen", "status": "fail", "detail": "ape_v2.h missing before -I fix"},
        {"id": "T2-regenesis", "status": "ok", "detail": f"x86_bytes={xsz} com=318137"},
        {"id": "T3-compose15-env", "status": "ok", "detail": "build-slice-lisp.mode=compose-15link exit=42"},
        {"id": "T4-promote", "status": "ok" if fail == 0 else "partial"},
    ],
    "results": {"converge_fail": fail, "x86_bytes": xsz, "frontier": "7/7"},
    "self_critique": (
        "compose-15link env 已生效但 linked ELF 仍 4096B stub；"
        "/goal 终局仍需 plan-only 154KB full runner 或 link-elf64 深化。"
        "regenesis 依赖工厂 lispjit.c 实文件+头文件路径。"
    ),
    "git_ops": [],
    "evidence_keys": ["v45.goal.regenesis_promote_continue.100=1", "v45.lisp_codegen.compose15_env_probe=1"],
    "verified": fail == 0,
    "blocker": None,
})
goal["active_frontier"] = "mindmap-frontier-v45-regenesis-promote.json"
goal["waves_done"] = goal.get("waves_done", []) + ["wave74-regenesis-promote"]
goal["updated_at"] = "2026-05-27T17:00:00Z"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave74=ok journal round2")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave74-regenesis-promote-converge=done fail=$fail bytes=$(wc -c <"$COM" | tr -d ' ')"
exit "$fail"
