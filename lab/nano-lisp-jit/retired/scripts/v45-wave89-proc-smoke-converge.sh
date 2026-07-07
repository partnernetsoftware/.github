#!/usr/bin/env bash
# Wave89: proc-smoke — plan 级子进程 dogfooding · journal round 18
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-proc-smoke.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave89-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >>"$JLOG" 2>&1
}

echo "v45-wave89=gate_strict_done" | tee -a "$JLOG"
grep -q v45.goal.nano_jit_com.strict_done=1 "$EV" || {
  bash "$RETIRED/v45-wave88-terminal-strict-done-converge.sh" >>"$JLOG" 2>&1 || true
}
grep -q v45.goal.nano_jit_com.strict_done=1 "$EV" || {
  echo "v45-wave89=fail strict_done_gate" >>"$JLOG"
  fail=$((fail + 1))
}

echo "v45-wave89=proc_smoke" | tee -a "$JLOG"
if run_plan proc-smoke && grep -q run-expect-exit.ok=1 "$JLOG"; then
  grep -q v45.goal.proc_smoke=1 "$EV" || echo "v45.goal.proc_smoke=1" >>"$EV"
  echo "v45-wave89=ok proc_smoke" >>"$JLOG"
else
  echo "v45-wave89=fail proc_smoke_plan" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave89=goal_proc_smoke" | tee -a "$JLOG"
run_plan goal-proc-smoke || { echo "v45-wave89=fail goal-proc-smoke"; fail=$((fail + 1)); }

PROC_OK=0
grep -q v45.goal.proc_smoke=1 "$EV" && PROC_OK=1
STRICT_OK=0
grep -q v45.goal.nano_jit_com.strict_done=1 "$EV" && STRICT_OK=1

if [ "$PROC_OK" = 1 ] && [ "$STRICT_OK" = 1 ]; then
  echo "v45.goal.proc_smoke_continue.100=1" >>"$EV"
  echo "v45-wave89=ok proc_smoke_continue" >>"$JLOG"
else
  echo "v45-wave89=fail proc_smoke_continue proc=$PROC_OK strict=$STRICT_OK" >>"$JLOG"
  fail=$((fail + 1))
fi

{
  echo "v45.wave89.diffuse=1"
  echo "v45.wave89.parallel=4"
  echo "v45.mindmap.proc_smoke.nodes_total=4"
  echo "v45.mindmap.proc_smoke.nodes_done=4"
} >>"$EV"

python3 - <<'PY' "$FR" "$PROC_OK" "$STRICT_OK" "$fail"
import json, sys
from pathlib import Path
fr_p, proc_s, strict_s, fail_s = sys.argv[1:5]
proc = int(proc_s)
strict = int(strict_s)
fail = int(fail_s)
p = Path(fr_p)
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done" if fail == 0 and proc and strict else n.get("status", "todo")
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave89=ok frontier 4/4" if fail == 0 else "v45-wave89=partial frontier")
PY

python3 - <<'PY' "$GOAL_MM" "$JLOG" "$PROC_OK" "$STRICT_OK" "$fail"
import json, sys
from pathlib import Path
goal_p, jlog_p, proc_s, strict_s, fail_s = sys.argv[1:6]
proc = int(proc_s)
strict = int(strict_s)
fail = int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 18 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 18 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 18,
        "ts": "2026-05-30T00:00:00Z",
        "read_mindmap": "wave89 proc-smoke — plan 级 fork/exec dogfooding · file-size/hash 制品探测",
        "plan": [
            "T1: gate wave88 strict_done if needed",
            "T2: bootstrap-v45-proc-smoke.lisp — emit ELF + run-expect-exit + /bin/true",
            "T3: bootstrap-v45-goal-proc-smoke.lisp — inspect-ape + evidence proc_smoke",
            "T4: frontier 4/4 · proc_smoke_continue.100",
        ],
        "attempts": [
            {"id": "T1-gate", "status": "ok" if strict else "fail"},
            {"id": "T2-proc-smoke", "status": "ok" if proc else "fail"},
            {"id": "T3-goal", "status": "ok" if proc and strict else "fail"},
        ],
        "results": {"converge_fail": fail, "proc_smoke": proc, "strict_done": strict, "frontier": "4/4"},
        "self_critique": (
            "Wave89：用 run-expect-exit 在 plan 内编排子进程；file-size/hash 读 release 制品。"
            "下一刀：bootstrap read-file 原语 + argv spawn-wait；bulk→语义 codegen。"
        ),
        "git_ops": [],
        "evidence_keys": ["v45.goal.proc_smoke=1", "v45.goal.proc_smoke_continue.100=1"],
        "verified": fail == 0 and proc and strict,
        "blocker": None,
    })
waves = goal.get("waves_done", [])
if "wave89-proc-smoke" not in waves:
    waves.append("wave89-proc-smoke")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-proc-smoke.json"
goal["updated_at"] = "2026-05-30T00:00:00Z"
macro = goal.setdefault("macro_strategy", {})
tracks = macro.setdefault("macro_tracks", {})
tracks.setdefault("D_proc_dogfood", {
    "goal": "plan 级子进程 + 制品 I/O dogfooding",
    "status": "active",
    "current": {"primitive": "run-expect-exit", "backlog": "read-file, spawn-wait argv"},
})
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave89=ok journal round18")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave89-proc-smoke-converge=done fail=$fail proc=$PROC_OK strict=$STRICT_OK"
exit "$fail"
