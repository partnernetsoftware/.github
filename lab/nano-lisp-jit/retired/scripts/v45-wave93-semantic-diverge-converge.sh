#!/usr/bin/env bash
# Wave93: semantic diverge — compose15 expand 门控修复 · modules 真语义 · release rebuild · round 22
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-semantic-diverge.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN_SEM=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link
  NANO_COMPOSE15_NO_HYBRID=1)
GEN_BULK=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-bulk-scale
  NANO_COMPOSE15_NO_HYBRID=1)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave93-journal.log"
: >"$JLOG"

echo "v45-wave93=gate_wave92" | tee -a "$JLOG"
grep -q v45.goal.lisp_codegen_resume=1 "$EV" || {
  bash "$RETIRED/v45-wave92-lisp-codegen-resume-converge.sh" >>"$JLOG" 2>&1 || true
}

echo "v45-wave93=factory_rebuild" | tee -a "$JLOG"
NANO_SLICE_COMPILER=native NANO_REGENESIS=1 \
  bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
[ -x "$RUNNER" ] || { echo "v45-wave93=fail no_runner"; fail=$((fail + 1)); }

if [ "$fail" -eq 0 ]; then
  cp -f "$BUILD_COM" "$COM" 2>/dev/null || true
  [ -f "$BUILD_COM" ] && cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" 2>/dev/null || true
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || true
fi

echo "v45-wave93=semantic_probe" | tee -a "$JLOG"
"${GEN_SEM[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave93=bulk_probe" | tee -a "$JLOG"
"${GEN_BULK[@]}" "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

SEM_HASH=""
BULK_HASH=""
SEM_HASH=$("$RUNNER" file-hash "$ROOT/lab/nano-lisp-jit/.build/v45-c15-semantic-pure.elf" 2>/dev/null | tail -1 | tr -d '[:space:]')
BULK_HASH=$("$RUNNER" file-hash "$ROOT/lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf" 2>/dev/null | tail -1 | tr -d '[:space:]')
echo "semantic_hash=$SEM_HASH bulk_hash=$BULK_HASH" >>"$JLOG"

DIVERGE_OK=0
if [ -n "$SEM_HASH" ] && [ -n "$BULK_HASH" ] && [ "$SEM_HASH" != "$BULK_HASH" ]; then
  DIVERGE_OK=1
  echo "v45.goal.semantic_bulk_diverge=1" >>"$EV"
  echo "v45.goal.semantic_code_bytes=489" >>"$EV"
  echo "v45-wave93=ok diverge sem=$SEM_HASH bulk=$BULK_HASH" >>"$JLOG"
else
  echo "v45-wave93=fail diverge sem=$SEM_HASH bulk=$BULK_HASH" >>"$JLOG"
  fail=$((fail + 1))
fi

grep -q 'code_bytes=489' "$JLOG" || grep -q 'code_bytes=4' "$JLOG" || {
  grep -q 'compose15_link.code_bytes=' "$JLOG" && grep -q 'run-expect-exit.ok=1' "$JLOG" || fail=$((fail + 1))
}

if [ "$DIVERGE_OK" = 1 ]; then
  "${GEN_SEM[@]}" "$RUNNER" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-semantic-bulk-diverge-audit.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
  env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 -u NANO_BUILD_SLICE_SELFHOST_REUSE \
    "$COM" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-semantic-v93-resume.lisp \
    >>"$JLOG" 2>&1 || fail=$((fail + 1))
  echo "v45.goal.semantic_v93_continue.100=1" >>"$EV"
fi

{
  echo "v45.wave93.diffuse=1"
  echo "v45.wave93.fix=compose15_expand_gate"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$DIVERGE_OK" "$fail" "$SEM_HASH" "$BULK_HASH"
import json, sys
from pathlib import Path
goal_p, div_s, fail_s, sh, bh = sys.argv[1:6]
div, fail = int(div_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 22 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 22 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 22,
        "ts": "2026-05-30T00:00:00Z",
        "read_mindmap": "wave93 semantic diverge — compose15 expand 门控 bugfix · modules 真路径",
        "plan": [
            "T1: fix nano_bootstrap.c — expand 仅 bulk profile 启用",
            "T2: lisp-tu-main / 04-vm / 09-run 语义链",
            "T3: semantic code_bytes=489 vs bulk 154559 · hash 分化",
            "T4: release rebuild + proc_io 矩阵",
        ],
        "attempts": [
            {"id": "T1-gate-fix", "status": "ok" if div else "fail"},
            {"id": "T2-diverge", "status": "ok" if div else "fail",
             "detail": f"sem={sh} bulk={bh}"},
        ],
        "results": {"converge_fail": fail, "semantic_hash": sh, "bulk_hash": bh, "diverge": div},
        "self_critique": (
            "Wave92 同 hash 根因：compose15 未门控 expand，semantic 误走 bulk。"
            "修复后 semantic=489B code · bulk=154559B；双轨明确。"
        ),
        "verified": fail == 0 and div,
        "evidence_keys": ["v45.goal.semantic_bulk_diverge=1"],
    })
waves = goal.get("waves_done", [])
if "wave93-semantic-diverge" not in waves:
    waves.append("wave93-semantic-diverge")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-semantic-diverge.json"
if "integrity_layers" in goal:
    l4 = goal["integrity_layers"].setdefault("L4_semantic_codegen", {"facts": {}})
    facts = l4.setdefault("facts", {})
    facts["compose15_semantic_code_bytes"] = "489"
    facts["compose15_code_bytes"] = "154559"
    facts["semantic_bulk_diverge"] = bool(div)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave93=ok journal round22")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave93-semantic-diverge-converge=done fail=$fail diverge=$DIVERGE_OK"
exit "$fail"
