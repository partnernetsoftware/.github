#!/usr/bin/env bash
# Wave105: factory build lisp-only path — plan regenesis · C seed honest · journal round 34
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-factory-build-lisp-only.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GENESIS_PIN="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
LO_COM="$ROOT/lab/nano-lisp-jit/.build/v45-w105-factory-lo.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave105-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$RUNNER" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >>"$JLOG" 2>&1
}

echo "v45-wave105=gate_wave104" | tee -a "$JLOG"
grep -q v45.goal.ape_six_face_probe_milestone=1 "$EV" || {
  bash "$RETIRED/v45-wave104-ape-six-face-probe-converge.sh" >>"$JLOG" 2>&1 || true
}

echo "v45-wave105=factory_rebuild" | tee -a "$JLOG"
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
  echo "v45-wave105=genesis_pin_preserved bytes=$(wc -c <"$GENESIS_PIN" | tr -d ' ')" >>"$JLOG"
fi
RUNNER="$BUILD_COM"
[ -x "$RUNNER" ] || RUNNER="$COM"
[ -x "$RUNNER" ] || { echo "v45-wave105=fail no_runner"; fail=$((fail + 1)); }

if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  chmod +x "$COM" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
  bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || fail=$((fail + 1))
fi

echo "v45-wave105=lisp_only_path" | tee -a "$JLOG"
PATH_OK=0
if [ -x "$ROOT/lab/nano-lisp-jit/build_nano_jit_lisp_only.sh" ]; then
  bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_lisp_only.sh" >>"$JLOG" 2>&1 || true
  if [ -f "$LO_COM" ] && [ -x "$RUNNER" ]; then
    INSPECT=$("$RUNNER" inspect-ape "$LO_COM" 2>&1 || true)
    printf '%s\n' "$INSPECT" >>"$JLOG"
    if printf '%s\n' "$INSPECT" | grep -q 'inspect-ape.ok=1'; then
      PATH_OK=1
      echo "v45.factory.build_lisp_only_path=1" >>"$EV"
      echo "v45.honest.factory_c_seed_remains=1" >>"$EV"
      echo "v45.selfhost.plan_no_c=1" >>"$EV"
      LO_BYTES=$(wc -c <"$LO_COM" | tr -d ' ')
      echo "v45.physical.factory_lo_com_bytes=$LO_BYTES" >>"$EV"
      echo "v45-wave105=ok lisp_only_path bytes=$LO_BYTES" >>"$JLOG"
    fi
  fi
fi
[ "$PATH_OK" = 1 ] || { echo "v45-wave105=fail lisp_only_path" >>"$JLOG"; fail=$((fail + 1)); }

echo "v45-wave105=semantic_smoke" | tee -a "$JLOG"
env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS \
  NANO_LISPJIT_FROM_LISP=1 NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-semantic-unified \
  NANO_COMPOSE15_NO_HYBRID=1 \
  "$RUNNER" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-unified-pure-link.lisp \
  >>"$JLOG" 2>&1 || fail=$((fail + 1))

echo "v45-wave105=audit_plans" | tee -a "$JLOG"
run_plan factory-physical-honest-closure || fail=$((fail + 1))
run_plan factory-build-lisp-only-path-audit || fail=$((fail + 1))

MILE_OK=0
if [ "$PATH_OK" = 1 ]; then
  run_plan goal-factory-build-lisp-only-milestone && MILE_OK=1 || fail=$((fail + 1))
fi
if [ "$MILE_OK" = 1 ]; then
  echo "v45.goal.factory_build_lisp_only_milestone=1" >>"$EV"
  echo "v45.goal.factory_build_lisp_only_continue.100=1" >>"$EV"
  echo "v45-wave105=ok milestone" >>"$JLOG"
fi

{
  echo "v45.wave105.diffuse=1"
  echo "v45.wave105.profile=factory-build-lisp-only"
} >>"$EV"

python3 - <<'PY' "$GOAL_MM" "$MILE_OK" "$fail" "$LO_COM"
import json, sys
from pathlib import Path
goal_p, mile_s, fail_s, lo_com = sys.argv[1:5]
mile, fail = int(mile_s), int(fail_s)
lo_bytes = Path(lo_com).stat().st_size if Path(lo_com).is_file() else 0
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 34 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 34 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
        "round": 34,
        "ts": "2026-06-05T00:00:00Z",
        "read_mindmap": "wave105 factory build lisp-only — plan regenesis · C seed honest",
        "plan": [
            "T1: build_nano_jit_lisp_only.sh wrapper",
            "T2: factory-build-lisp-only-regenesis plan",
            "T3: semantic-unified smoke + factory closure",
        ],
        "results": {"factory_lo_bytes": lo_bytes, "converge_fail": fail},
        "verified": fail == 0 and mile,
        "self_critique": f"plan regenesis OK({lo_bytes}B) · build_nano_jit C 种子仍在 · 非工厂 zero C DONE。",
    })
waves = goal.get("waves_done", [])
if "wave105-factory-build-lisp-only" not in waves:
    waves.append("wave105-factory-build-lisp-only")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-factory-build-lisp-only.json"
if "macro_strategy" in goal and "macro_tracks" in goal["macro_strategy"]:
    e = goal["macro_strategy"]["macro_tracks"].setdefault("E_bootstrap_boundary", {})
    facts = e.setdefault("facts", {})
    facts["wave105_factory_lo_bytes"] = str(lo_bytes)
    facts["factory_build_lisp_only"] = str(mile and fail == 0)
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave105=ok journal round34")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave105-factory-build-lisp-only-converge=done fail=$fail mile=$MILE_OK"
exit "$fail"
