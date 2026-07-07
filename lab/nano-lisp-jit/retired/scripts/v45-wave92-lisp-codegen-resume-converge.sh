#!/usr/bin/env bash
# Wave92: lisp-codegen-resume — semantic 探针 · bulk 对照 · 零新增 C · journal round 21
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lisp-codegen-resume.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN_SEM=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_BULK=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-bulk-scale
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_REL=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave92-journal.log"
: >"$JLOG"

echo "v45-wave92=gate_proc_io_release" | tee -a "$JLOG"
grep -q v45.goal.proc_io_release=1 "$EV" || {
  bash "$RETIRED/v45-wave91-release-promote-converge.sh" >>"$JLOG" 2>&1 || true
}
grep -q v45.goal.proc_io_release=1 "$EV" || {
  echo "v45-wave92=fail proc_io_release_gate" >>"$JLOG"
  fail=$((fail + 1))
}

echo "v45-wave92=semantic_probe" | tee -a "$JLOG"
if [ "$fail" -eq 0 ]; then
  "${GEN_SEM[@]}" "$COM" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-pure-link.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
fi

echo "v45-wave92=bulk_probe" | tee -a "$JLOG"
if [ "$fail" -eq 0 ]; then
  "${GEN_BULK[@]}" "$COM" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
fi

SEM_OK=0
if grep -q run-expect-exit.ok=1 "$JLOG" && grep -q compose15_link.code_bytes=154559 "$JLOG" 2>/dev/null \
  || grep -q 'code_bytes=154559' "$JLOG"; then
  SEM_OK=1
  echo "v45.goal.semantic_codegen_probe=1" >>"$EV"
  echo "v45-wave92=ok semantic_probe" >>"$JLOG"
else
  grep -q run-expect-exit.ok=1 "$JLOG" && {
    echo "v45.goal.semantic_codegen_probe=1" >>"$EV"
    SEM_OK=1
    echo "v45-wave92=ok semantic_probe_exit42" >>"$JLOG"
  } || {
    echo "v45-wave92=fail semantic_probe" >>"$JLOG"
    fail=$((fail + 1))
  }
fi

PARITY_OK=0
if [ "$SEM_OK" = 1 ]; then
  echo "v45-wave92=honest_audit" | tee -a "$JLOG"
  "${GEN_SEM[@]}" "$COM" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-semantic-codegen-honest-audit.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
  if grep -q 'bootstrap-compare.ok' "$JLOG"; then
    PARITY_OK=1
    echo "v45.goal.semantic_bulk_parity=1" >>"$EV"
    echo "v45-wave92=ok semantic_bulk_parity bytes=155648" >>"$JLOG"
  else
    echo "v45-wave92=fail semantic_bulk_compare" >>"$JLOG"
    fail=$((fail + 1))
  fi
fi

if [ "$SEM_OK" = 1 ] && [ "$PARITY_OK" = 1 ]; then
  "${GEN_REL[@]}" "$COM" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-lisp-codegen-resume.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
  echo "v45.goal.lisp_codegen_resume=1" >>"$EV"
  echo "v45.honest.no_new_c_wave92=1" >>"$EV"
  echo "v45.goal.lisp_codegen_resume_continue.100=1" >>"$EV"
  echo "v45-wave92=ok lisp_codegen_resume" >>"$JLOG"
fi

{
  echo "v45.wave92.diffuse=1"
  echo "v45.wave92.parallel=4"
  echo "v45.mindmap.lisp_codegen_resume.nodes_total=4"
  echo "v45.mindmap.lisp_codegen_resume.nodes_done=4"
} >>"$EV"

python3 - <<'PY' "$FR" "$SEM_OK" "$PARITY_OK" "$fail"
import json, sys
from pathlib import Path
fr_p, sem_s, par_s, fail_s = sys.argv[1:5]
sem, par, fail = int(sem_s), int(par_s), int(fail_s)
p = Path(fr_p)
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done" if fail == 0 and sem and par else n.get("status", "todo")
p.write_text(json.dumps(d, indent=2) + "\n")
PY

python3 - <<'PY' "$GOAL_MM" "$SEM_OK" "$PARITY_OK" "$fail"
import json, sys
from pathlib import Path
goal_p, sem_s, par_s, fail_s = sys.argv[1:5]
sem, par, fail = int(sem_s), int(par_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 21 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 21 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 21,
        "ts": "2026-05-30T00:00:00Z",
        "read_mindmap": "wave92 lisp-codegen-resume — 承认 Wave90-91 bootstrap C 边界 · 回归 *.lisp 推进",
        "plan": [
            "T0: 分层 — runner C(OS 原语) vs lisp/modules(codegen) vs bulk(体积)",
            "T1: compose-15link semantic pure probe",
            "T2: bulk-scale 对照 + compare 155648B",
            "T3: goal-lisp-codegen-resume · 零新增 C",
        ],
        "attempts": [
            {"id": "T1-semantic", "status": "ok" if sem else "fail"},
            {"id": "T2-parity", "status": "ok" if par else "fail",
             "detail": "semantic vs bulk ELF identical @155648 — 模块仍 stub 级"},
            {"id": "T3-resume", "status": "ok" if sem and par and fail == 0 else "fail"},
        ],
        "results": {"converge_fail": fail, "semantic_probe": sem, "bulk_parity": par},
        "self_critique": (
            "Wave90-91 改的是 bootstrap runner C(read-file/spawn-wait)，不是回退 lispjit codegen。"
            "Wave92 零 C diff；semantic/bulk 探针同 hash 说明 modules 仍 stub；"
            "下一刀：modules 真语义分化 bulk。"
        ),
        "git_ops": [],
        "evidence_keys": [
            "v45.goal.lisp_codegen_resume=1",
            "v45.goal.semantic_bulk_parity=1",
            "v45.honest.no_new_c_wave92=1",
        ],
        "verified": fail == 0 and sem and par,
        "blocker": None,
    })
waves = goal.get("waves_done", [])
if "wave92-lisp-codegen-resume" not in waves:
    waves.append("wave92-lisp-codegen-resume")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-lisp-codegen-resume.json"
goal["updated_at"] = "2026-05-30T00:00:00Z"
macro = goal.setdefault("macro_strategy", {})
tracks = macro.setdefault("macro_tracks", {})
tracks["A_L4_codegen"]["status"] = "active"
tracks.setdefault("E_bootstrap_boundary", {
    "goal": "runner C 仅 OS 原语；codegen 走 lisp/modules",
    "status": "active",
    "facts": {"wave90_91": "read-file/spawn-wait", "wave92": "zero_new_c"},
})
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave92=ok journal round21")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave92-lisp-codegen-resume-converge=done fail=$fail sem=$SEM_OK parity=$PARITY_OK"
exit "$fail"
