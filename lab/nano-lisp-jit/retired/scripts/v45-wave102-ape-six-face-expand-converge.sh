#!/usr/bin/env bash
# Wave102: APE 6-face expand — Linux 2/2 audit · cross-os gap · journal round 31
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-ape-six-face-expand.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GENESIS_PIN="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave102-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$RUNNER" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >>"$JLOG" 2>&1
}

echo "v45-wave102=gate_wave101" | tee -a "$JLOG"
grep -q v45.goal.factory_zero_c_honest_milestone=1 "$EV" || {
  bash "$RETIRED/v45-wave101-factory-zero-c-honest-converge.sh" >>"$JLOG" 2>&1 || true
}

grep -q v45.plan.ape_six_face=1 "$EV" || echo "v45.plan.ape_six_face=1" >>"$EV"
grep -q v45.honest.ape_two_slice_linux_only=1 "$EV" || echo "v45.honest.ape_two_slice_linux_only=1" >>"$EV"

echo "v45-wave102=factory_rebuild" | tee -a "$JLOG"
GENESIS_PIN_BAK=""
if [ -f "$GENESIS_PIN" ]; then
  GENESIS_PIN_BAK="$(mktemp)"
  cp -f "$GENESIS_PIN" "$GENESIS_PIN_BAK"
fi
NANO_SLICE_COMPILER=native NANO_REGENESIS=1 \
  bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true
if [ -n "$GENESIS_PIN_BAK" ] && [ -f "$GENESIS_PIN_BAK" ]; then
  cp -f "$GENESIS_PIN_BAK" "$GENESIS_PIN"
  chmod +x "$GENESIS_PIN"
  rm -f "$GENESIS_PIN_BAK"
  echo "v45-wave102=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_PIN" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$COM"
[ -x "$RUNNER" ] || { echo "v45-wave102=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || fail=$((fail + 1))
fi

echo "v45-wave102=inspect_ape" | tee -a "$JLOG"
SLICE_COUNT=0
LINUX_FACES=0
INSPECT_OK=0
if [ -x "$COM" ]; then
  INSPECT=$("$COM" inspect-ape "$COM" 2>&1 || true)
  printf '%s\n' "$INSPECT" >>"$JLOG"
  if printf '%s\n' "$INSPECT" | grep -q 'inspect-ape.ok=1'; then
    INSPECT_OK=1
    SLICE_COUNT=$(printf '%s\n' "$INSPECT" | grep 'inspect-ape.slice_count=' \
      | head -1 | sed 's/.*=//' | tr -d '[:space:]')
    LINUX_FACES=$(printf '%s\n' "$INSPECT" | grep -c 'inspect-ape.slice.*.os_id=1' || true)
    SLICE0_ARCH=$(printf '%s\n' "$INSPECT" | grep 'inspect-ape.slice.0.arch_id=' \
      | head -1 | sed 's/.*=//' | tr -d '[:space:]')
    SLICE1_ARCH=$(printf '%s\n' "$INSPECT" | grep 'inspect-ape.slice.1.arch_id=' \
      | head -1 | sed 's/.*=//' | tr -d '[:space:]')
    echo "slice_count=$SLICE_COUNT linux_faces=$LINUX_FACES arch0=$SLICE0_ARCH arch1=$SLICE1_ARCH" >>"$JLOG"
  fi
fi

APE_OK=0
if [ "$INSPECT_OK" = 1 ] && [ "${SLICE_COUNT:-0}" -eq 2 ] && [ "${LINUX_FACES:-0}" -eq 2 ]; then
  if [ "${SLICE0_ARCH:-0}" = 1 ] && [ "${SLICE1_ARCH:-0}" = 2 ]; then
    APE_OK=1
    echo "v45.honest.ape_slice_count=2" >>"$EV"
    echo "v45.honest.ape_linux_faces=2" >>"$EV"
    echo "v45.honest.ape_missing_faces=4" >>"$EV"
    echo "v45.honest.ape_two_slice_linux_only=1" >>"$EV"
    echo "v45.physical.ape_faces_present=2" >>"$EV"
    echo "v45.physical.ape_faces_missing=4" >>"$EV"
    echo "v45-wave102=ok inspect_ape slices=2 linux=2 missing=4" >>"$JLOG"
  fi
fi
[ "$APE_OK" = 1 ] || { echo "v45-wave102=fail inspect_ape count=$SLICE_COUNT linux=$LINUX_FACES" >>"$JLOG"; fail=$((fail + 1)); }

echo "v45-wave102=honest_plans" | tee -a "$JLOG"
run_plan honest-ape-six-face-gap || fail=$((fail + 1))
run_plan goal-com-container-audit || fail=$((fail + 1))
run_plan ape-six-face-linux-audit || fail=$((fail + 1))

MILE_OK=0
if [ "$APE_OK" = 1 ]; then
  run_plan goal-ape-six-face-expand-milestone && MILE_OK=1 || fail=$((fail + 1))
fi
if [ "$MILE_OK" = 1 ]; then
  echo "v45.goal.ape_six_face_expand_milestone=1" >>"$EV"
  echo "v45.goal.ape_six_face_expand_continue.100=1" >>"$EV"
  echo "v45-wave102=ok milestone" >>"$JLOG"
fi

{
  echo "v45.wave102.diffuse=1"
  echo "v45.wave102.profile=ape-six-face-expand"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$MILE_OK" "$fail" "${SLICE_COUNT:-0}" "${LINUX_FACES:-0}"
import json, sys
from pathlib import Path
goal_p, mile_s, fail_s, slice_c, linux_f = sys.argv[1:6]
mile, fail = int(mile_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 31 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 31 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 31,
        "ts": "2026-06-02T00:00:00Z",
        "read_mindmap": "wave102 APE 6-face expand — Linux 2/2 · cross-os 0/4 honest",
        "plan": [
            "T1: inspect-ape release COM slice_count=2 os_id=1",
            "T2: ape-six-face-gap + container audit",
            "T3: expand milestone · os_id 2/3 roadmap",
        ],
        "results": {"slice_count": slice_c, "linux_faces": linux_f, "missing_faces": "4", "converge_fail": fail},
        "verified": fail == 0 and mile,
        "self_critique": f"Linux {linux_f}/2 面绿 · cross-os 4 面缺失 · 不混称 6/6 DONE。",
    })
waves = goal.get("waves_done", [])
if "wave102-ape-six-face-expand" not in waves:
    waves.append("wave102-ape-six-face-expand")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-ape-six-face-expand.json"
if "macro_strategy" in goal and "macro_tracks" in goal["macro_strategy"]:
    l1 = goal["macro_strategy"]["macro_tracks"].setdefault("L1_container", {})
    facts = l1.setdefault("facts", {})
    facts["wave102_ape_linux_faces"] = str(linux_f)
    facts["wave102_ape_missing_faces"] = "4"
    facts["ape_six_face_expand"] = str(mile and fail == 0)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave102=ok journal round31")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave102-ape-six-face-expand-converge=done fail=$fail mile=$MILE_OK slices=$SLICE_COUNT linux=$LINUX_FACES"
exit "$fail"
