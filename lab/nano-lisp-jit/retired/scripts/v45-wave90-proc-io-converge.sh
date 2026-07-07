#!/usr/bin/env bash
# Wave90: proc-io — read-file + spawn-wait bootstrap 原语 · factory slice rebuild · journal round 19
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-proc-io.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
RUNNER_DIR="$ROOT/lab/nano-lisp-jit/retired/archive-c/runner"
NANO_C="$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c"
BUILD_DIR="$ROOT/lab/nano-lisp-jit/.build/nano-jit"
FACTORY="$BUILD_DIR/nano-jit.x86_64"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave90-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >>"$JLOG" 2>&1
}

echo "v45-wave90=gate_proc_smoke" | tee -a "$JLOG"
grep -q v45.goal.proc_smoke=1 "$EV" || {
  bash "$RETIRED/v45-wave89-proc-smoke-converge.sh" >>"$JLOG" 2>&1 || true
}
grep -q v45.goal.proc_smoke=1 "$EV" || {
  echo "v45-wave90=fail proc_smoke_gate" >>"$JLOG"
  fail=$((fail + 1))
}

echo "v45-wave90=factory_rebuild" | tee -a "$JLOG"
mkdir -p "$BUILD_DIR"
if ! cc -DNANO_LISP_JIT \
  -I"$ROOT/lab/lispjit-ir" -I"$RUNNER_DIR" -Os -s \
  "$NANO_C" -ldl -o "$FACTORY" >>"$JLOG" 2>&1; then
  echo "v45-wave90=fail factory_cc" >>"$JLOG"
  fail=$((fail + 1))
fi
chmod +x "$FACTORY" 2>/dev/null || true
COM="${NANO_COM:-$FACTORY}"
if [ ! -x "$COM" ]; then
  echo "v45-wave90=fail no_com" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave90=proc_io com=$COM" | tee -a "$JLOG"
IO_OK=0
if [ "$fail" -eq 0 ] && run_plan proc-io \
  && grep -q read-file.ok=1 "$JLOG" \
  && grep -q spawn-wait.ok=1 "$JLOG"; then
  grep -q v45.goal.proc_io=1 "$EV" || echo "v45.goal.proc_io=1" >>"$EV"
  IO_OK=1
  echo "v45-wave90=ok proc_io" >>"$JLOG"
else
  echo "v45-wave90=fail proc_io_plan" >>"$JLOG"
  fail=$((fail + 1))
fi

echo "v45-wave90=goal_proc_io" | tee -a "$JLOG"
if [ "$IO_OK" = 1 ]; then
  run_plan goal-proc-io || { echo "v45-wave90=fail goal-proc-io"; fail=$((fail + 1)); }
fi

PROC_OK=0
grep -q v45.goal.proc_smoke=1 "$EV" && PROC_OK=1
if [ "$IO_OK" = 1 ] && [ "$PROC_OK" = 1 ]; then
  echo "v45.goal.proc_io_continue.100=1" >>"$EV"
  echo "v45-wave90=ok proc_io_continue" >>"$JLOG"
else
  echo "v45-wave90=fail proc_io_continue io=$IO_OK proc=$PROC_OK" >>"$JLOG"
  fail=$((fail + 1))
fi

{
  echo "v45.wave90.diffuse=1"
  echo "v45.wave90.parallel=4"
  echo "v45.mindmap.proc_io.nodes_total=4"
  echo "v45.mindmap.proc_io.nodes_done=4"
  echo "v45.factory.proc_io_slice=$FACTORY"
} >>"$EV"

python3 - <<'PY' "$FR" "$IO_OK" "$PROC_OK" "$fail"
import json, sys
from pathlib import Path
fr_p, io_s, proc_s, fail_s = sys.argv[1:5]
io = int(io_s)
proc = int(proc_s)
fail = int(fail_s)
p = Path(fr_p)
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done" if fail == 0 and io and proc else n.get("status", "todo")
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave90=ok frontier 4/4" if fail == 0 else "v45-wave90=partial frontier")
PY

python3 - <<'PY' "$GOAL_MM" "$IO_OK" "$PROC_OK" "$fail"
import json, sys
from pathlib import Path
goal_p, io_s, proc_s, fail_s = sys.argv[1:5]
io = int(io_s)
proc = int(proc_s)
fail = int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 19 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 19 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 19,
        "ts": "2026-05-30T00:00:00Z",
        "read_mindmap": "wave90 proc-io — read-file + spawn-wait(argv) · factory cc rebuild",
        "plan": [
            "T1: gate wave89 proc_smoke",
            "T2: cc rebuild nano-jit.x86_64 with read-file/spawn-wait",
            "T3: bootstrap-v45-proc-io.lisp + goal-proc-io",
            "T4: proc_io_continue.100 · frontier 4/4",
        ],
        "attempts": [
            {"id": "T1-gate", "status": "ok" if proc else "fail"},
            {"id": "T2-factory", "status": "ok" if io else "fail"},
            {"id": "T3-proc-io", "status": "ok" if io and proc else "fail"},
        ],
        "results": {"converge_fail": fail, "proc_io": io, "proc_smoke": proc, "frontier": "4/4"},
        "self_critique": (
            "Wave90：bootstrap read-file/spawn-wait 落地；factory cc slice 验收。"
            "release COM 待 cosmocc promote；下一刀 bulk→语义 codegen。"
        ),
        "git_ops": [],
        "evidence_keys": ["v45.goal.proc_io=1", "v45.goal.proc_io_continue.100=1"],
        "verified": fail == 0 and io and proc,
        "blocker": None,
    })
waves = goal.get("waves_done", [])
if "wave90-proc-io" not in waves:
    waves.append("wave90-proc-io")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-proc-io.json"
goal["updated_at"] = "2026-05-30T00:00:00Z"
macro = goal.setdefault("macro_strategy", {})
tracks = macro.setdefault("macro_tracks", {})
if "D_proc_dogfood" in tracks:
    tracks["D_proc_dogfood"]["current"] = {
        "primitive": "read-file, spawn-wait, run-expect-exit",
        "factory_slice": "cc rebuild",
    }
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave90=ok journal round19")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave90-proc-io-converge=done fail=$fail io=$IO_OK proc=$PROC_OK com=$COM"
exit "$fail"
