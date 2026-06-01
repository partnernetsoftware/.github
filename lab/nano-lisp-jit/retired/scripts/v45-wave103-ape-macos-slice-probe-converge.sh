#!/usr/bin/env bash
# Wave103: macOS os_id=2 slice probe — 4-row APE · placeholder · journal round 32
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-ape-macos-slice-probe.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GENESIS_X86="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
GENESIS_A64="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64"
PROBE_COM="$ROOT/lab/nano-lisp-jit/.build/v45-w103-ape-macos-probe.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave103-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$RUNNER" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >>"$JLOG" 2>&1
}

echo "v45-wave103=gate_wave102" | tee -a "$JLOG"
grep -q v45.goal.ape_six_face_expand_milestone=1 "$EV" || {
  bash "$RETIRED/v45-wave102-ape-six-face-expand-converge.sh" >>"$JLOG" 2>&1 || true
}

echo "v45-wave103=factory_rebuild" | tee -a "$JLOG"
GENESIS_PIN_BAK=""
if [ -f "$GENESIS_X86" ]; then
  GENESIS_PIN_BAK="$(mktemp)"
  cp -f "$GENESIS_X86" "$GENESIS_PIN_BAK"
fi
NANO_SLICE_COMPILER=native NANO_REGENESIS=1 \
  bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true
if [ -n "$GENESIS_PIN_BAK" ] && [ -f "$GENESIS_PIN_BAK" ]; then
  cp -f "$GENESIS_PIN_BAK" "$GENESIS_X86"
  chmod +x "$GENESIS_X86"
  rm -f "$GENESIS_PIN_BAK"
  echo "v45-wave103=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_X86" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$COM"
[ -x "$RUNNER" ] || { echo "v45-wave103=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || fail=$((fail + 1))
fi

echo "v45-wave103=gen_macos_probe" | tee -a "$JLOG"
PROBE_OK=0
MACOS_ROWS=0
SLICE_COUNT=0
if [ -f "$GENESIS_X86" ] && [ -f "$GENESIS_A64" ]; then
  python3 "$ROOT/lab/nano-lisp-jit/tools/gen-ape-macos-osid-probe.py" \
    "$GENESIS_X86" "$GENESIS_A64" "$PROBE_COM" >>"$JLOG" 2>&1 || true
  if [ -f "$PROBE_COM" ] && [ -x "$RUNNER" ]; then
    INSPECT=$("$RUNNER" inspect-ape "$PROBE_COM" 2>&1 || true)
    printf '%s\n' "$INSPECT" >>"$JLOG"
    if printf '%s\n' "$INSPECT" | grep -q 'inspect-ape.ok=1'; then
      SLICE_COUNT=$(printf '%s\n' "$INSPECT" | grep 'inspect-ape.slice_count=' \
        | head -1 | sed 's/.*=//' | tr -d '[:space:]')
      MACOS_ROWS=$(printf '%s\n' "$INSPECT" | grep -c 'inspect-ape.slice.*.os_id=2' || true)
      if [ "${SLICE_COUNT:-0}" -eq 4 ] && [ "${MACOS_ROWS:-0}" -eq 2 ]; then
        PROBE_OK=1
        echo "v45.probe.ape_macos_osid2=1" >>"$EV"
        echo "v45.probe.ape_macos_slice_count=2" >>"$EV"
        echo "v45.honest.ape_macos_probe_not_runtime=1" >>"$EV"
        echo "v45.physical.ape_probe_slice_count=4" >>"$EV"
        echo "v45-wave103=ok probe slices=4 macos_rows=2" >>"$JLOG"
      fi
    fi
  fi
fi
[ "$PROBE_OK" = 1 ] || { echo "v45-wave103=fail probe slices=$SLICE_COUNT macos=$MACOS_ROWS" >>"$JLOG"; fail=$((fail + 1)); }

echo "v45-wave103=audit_plans" | tee -a "$JLOG"
run_plan ape-macos-osid2-audit || fail=$((fail + 1))

MILE_OK=0
if [ "$PROBE_OK" = 1 ]; then
  run_plan goal-ape-macos-slice-probe-milestone && MILE_OK=1 || fail=$((fail + 1))
fi
if [ "$MILE_OK" = 1 ]; then
  echo "v45.goal.ape_macos_slice_probe_milestone=1" >>"$EV"
  echo "v45.goal.ape_macos_slice_probe_continue.100=1" >>"$EV"
  echo "v45-wave103=ok milestone" >>"$JLOG"
fi

{
  echo "v45.wave103.diffuse=1"
  echo "v45.wave103.profile=ape-macos-slice-probe"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$MILE_OK" "$fail" "${SLICE_COUNT:-0}" "${MACOS_ROWS:-0}"
import json, sys
from pathlib import Path
goal_p, mile_s, fail_s, slice_c, macos_r = sys.argv[1:6]
mile, fail = int(mile_s), int(fail_s)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 32 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 32 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 32,
        "ts": "2026-06-03T00:00:00Z",
        "read_mindmap": "wave103 macOS os_id=2 slice probe — 4-row table placeholder",
        "plan": [
            "T1: gen-ape-macos-osid-probe.py 4-row bare",
            "T2: inspect-ape os_id=2 rows · ape_v2 validate expand",
            "T3: macOS probe milestone · not runtime Mach-O",
        ],
        "results": {"slice_count": slice_c, "macos_rows": macos_r, "converge_fail": fail},
        "verified": fail == 0 and mile,
        "self_critique": f"4-row probe · macOS os_id=2 ×{macos_r} placeholder · 非 Mach-O runtime。",
    })
waves = goal.get("waves_done", [])
if "wave103-ape-macos-slice-probe" not in waves:
    waves.append("wave103-ape-macos-slice-probe")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-ape-macos-slice-probe.json"
if "macro_strategy" in goal and "macro_tracks" in goal["macro_strategy"]:
    l1 = goal["macro_strategy"]["macro_tracks"].setdefault("L1_container", {})
    facts = l1.setdefault("facts", {})
    facts["wave103_ape_probe_slices"] = str(slice_c)
    facts["wave103_macos_osid2_rows"] = str(macos_r)
    facts["ape_macos_slice_probe"] = str(mile and fail == 0)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave103=ok journal round32")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave103-ape-macos-slice-probe-converge=done fail=$fail mile=$MILE_OK slices=$SLICE_COUNT macos=$MACOS_ROWS"
exit "$fail"
