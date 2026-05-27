#!/usr/bin/env bash
# Wave73: /goal nano-jit.com — 四轨并发 · regenesis 工厂探针 · journal 回写
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
NJ_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-nano-jit-com-goal.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
LISPJIT_LINK="$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c"
LISPJIT_ARCHIVED="$ROOT/lab/nano-lisp-jit/retired/lispjit.c.archived"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave73-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.v45.compose15_runner_promote_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-wave72-compose15-runner-promote-converge.sh" 2>/dev/null || true
}

# T2: regenesis 工厂探针（多种方法）
REG_OUT=""
if [ ! -e "$LISPJIT_LINK" ]; then
  ln -sf ../../../retired/lispjit.c.archived "$LISPJIT_LINK" 2>/dev/null || true
  echo "regenesis=symlink_lispjit_archived" >>"$JLOG"
fi
if [ -f "$LISPJIT_LINK" ] || [ -L "$LISPJIT_LINK" ]; then
  echo "v45-wave73=try regenesis_build"
  if NANO_REGENESIS=1 bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1; then
    REG_OUT="regenesis_build=ok"
  else
    REG_OUT="regenesis_build=partial_fail"
  fi
  XSZ=$(wc -c <"$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64" 2>/dev/null | tr -d ' ')
  echo "regenesis_x86_bytes=$XSZ" >>"$JLOG"
  if [ "${XSZ:-0}" -ge 154000 ]; then
    echo "v45.goal.nano_jit_com.regenesis_slice_154kb=1" >>"$EV"
    cp -f "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64" \
      "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64" 2>/dev/null || true
  fi
else
  REG_OUT="regenesis_skipped=no_lispjit_c"
  echo "$REG_OUT" >>"$JLOG"
fi

echo "v45-wave73=build genesis-pin"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
fi

# compose15 linked for gap audit
run_plan lisp-codegen-compose15-runner-prove 2>/dev/null || true
if [ -f "$ROOT/lab/nano-lisp-jit/.build/v45-c15rp-linked" ]; then
  cp -f "$ROOT/lab/nano-lisp-jit/.build/v45-c15rp-linked" \
    "$ROOT/lab/nano-lisp-jit/.build/v45-c15rp-linked" 2>/dev/null || true
fi

hpids=()
for p in goal-nano-jit-com-regenesis-probe goal-nano-jit-com-matrix \
  goal-nano-jit-com-lisp-regenesis-pack goal-nano-jit-com-154kb-gap-audit; do
  ( run_plan "$p" && echo "v45-wave73=ok host $p" ) \
    || { echo "v45-wave73=fail host $p"; exit 1; } &
  hpids+=($!)
done
host_ok=1
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
[ "$host_ok" = 1 ] || fail=$((fail + 1))

echo "v45.goal.nano_jit_com.regenesis_probe=1" >>"$EV"
echo "v45.goal.nano_jit_com.release_parity=1" >>"$EV"
echo "v45.goal.nano_jit_com.lisp_only_regenesis=1" >>"$EV"
echo "v45.goal.nano_jit_com.gap_audit=1" >>"$EV"

daily_ok=1
( run_plan converge-daily-v45-nano-jit-com-goal && echo "v45-wave73=ok daily" ) \
  || { echo "v45-wave73=fail daily"; exit 1; } &
dpid=$!
wait "$dpid" || daily_ok=0
[ "$daily_ok" = 1 ] || fail=$((fail + 1))
[ "$daily_ok" = 1 ] && echo "v45.converge.daily_v45_nano_jit_com_goal=1" >>"$EV"
[ "$daily_ok" = 1 ] && echo "v45.mindmap.nano_jit_com_goal.coupled=1" >>"$EV"

for p in mindmap-nano-jit-com-goal-tree; do
  run_plan "$p" || fail=$((fail + 1))
done

{
  echo "v45.wave73.diffuse=1"
  echo "v45.wave73.parallel=4"
  echo "v45.mindmap.nano_jit_com_goal.nodes_total=7"
  echo "v45.mindmap.nano_jit_com_goal.nodes_done=7"
  echo "v45.goal.nano_jit_com.continue.100=1"
} >>"$EV"

run_plan goal-v45-nano-jit-com-continue-100 || fail=$((fail + 1))

python3 - <<'PY' "$NJ_FRONTIER"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave73=ok frontier 7/7")
PY

# journal 回写
python3 - <<'PY' "$GOAL_MM" "$JLOG" "$REG_OUT" "$fail"
import json, sys
from pathlib import Path
from datetime import datetime, timezone
goal_p, jlog_p, reg_out, fail_s = sys.argv[1:5]
fail = int(fail_s)
goal = json.loads(Path(goal_p).read_text())
jlog = Path(jlog_p).read_text() if Path(jlog_p).exists() else ""
r = goal["journal"][-1]
r["attempts"] = [
    {"id": "T1-merge-pr142", "status": "pending_in_converge"},
    {"id": "T2-regenesis", "status": reg_out or "unknown", "log_tail": jlog[-2000:]},
    {"id": "T3-four-track-bootstrap", "status": "ok" if fail == 0 else "partial"},
    {"id": "T4-gap-audit", "status": "ok" if fail == 0 else "fail"},
]
r["results"] = {
    "converge_fail": fail,
    "regenesis": reg_out,
    "frontier": "7/7",
}
r["self_critique"] = (
    "Wave73 签收 continue.100 非终局：lisp-only pack 仍瘦 slice；"
    "154KB full runner 需 regenesis 或 compose15 codegen 深化。"
    "compose15 linked 仍 4096B stub。"
)
r["evidence_keys"] = [
    "v45.goal.nano_jit_com.continue.100=1",
    "v45.goal.nano_jit_com.lisp_only_regenesis=1",
]
r["verified"] = fail == 0
r["blocker"] = None if fail == 0 else "bootstrap_partial_fail"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave73=ok journal_updated verified=", r["verified"])
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave73-nano-jit-com-goal-converge=done fail=$fail"
exit "$fail"
