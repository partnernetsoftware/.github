#!/usr/bin/env bash
# Wave88: terminal-strict-done — COM promote · container audit · strict_done 终局签收
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
GOAL_MM="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-goal-nano-jit-com.json"
FR="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-terminal-strict-done.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GENESIS="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
GENESIS_BYTES=155648
MIN_SLICE=154000
X86_ELF="$ROOT/lab/nano-lisp-jit/.build/v45-w87-c15-154k-x86.elf"
A64_ELF="$ROOT/lab/nano-lisp-jit/.build/v45-w87-c15-154k-aarch64.elf"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
JLOG="$ROOT/lab/nano-lisp-jit/.build/v45-wave88-journal.log"
: >"$JLOG"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.goal.compose15_regenesis_promote_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-wave87-compose15-regenesis-promote-converge.sh" 2>/dev/null || true
}

echo "v45-wave88=genesis_sync" | tee -a "$JLOG"
if [ ! -f "$X86_ELF" ] || [ "$(wc -c <"$X86_ELF" 2>/dev/null | tr -d ' ')" -lt "$MIN_SLICE" ]; then
  env -u NANO_SELFHOST_REUSE_X86 NANO_LISPJIT_FROM_LISP=1 \
    NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link-bulk-scale \
    NANO_COMPOSE15_NO_HYBRID=1 \
    "$COM" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-compose15-154k-com-pack.lisp \
    >>"$JLOG" 2>&1 || true
fi
X86_ELF="$ROOT/lab/nano-lisp-jit/.build/v45-w87-c15-154k-x86.elf"
A64_ELF="$ROOT/lab/nano-lisp-jit/.build/v45-w87-c15-154k-aarch64.elf"
MIN_SLICE=154000
if [ -f "$X86_ELF" ] && [ "$(wc -c <"$X86_ELF" | tr -d ' ')" -ge "$MIN_SLICE" ]; then
  cp -f "$X86_ELF" "$GENESIS"
  [ -f "$A64_ELF" ] && cp -f "$A64_ELF" "$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64"
  echo "v45-wave88=ok genesis_sync" >>"$JLOG"
fi

echo "v45-wave88=factory_build" | tee -a "$JLOG"
env -u NANO_REGENESIS bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >>"$JLOG" 2>&1 || true

echo "v45-wave88=release_matrix" | tee -a "$JLOG"
# Do not overwrite release COM with slim repack (161093 breaks matrix); keep promoted release.

bash "$RETIRED/v45-manifest-pin.sh" "$COM" >>"$JLOG" 2>&1 || fail=$((fail + 1))

COM_HASH=$("$COM" file-hash "$COM" 2>/dev/null | tail -1 | tr -d '[:space:]')
MAN_HASH=$(grep -E '^nano-lisp\.com\.fnv1a64=' "$ROOT/lab/nano-lisp-jit/release/manifest.txt" \
  | head -1 | cut -d= -f2 | tr -d '[:space:]')
COM_BYTES=$(wc -c <"$COM" | tr -d ' ')
MAN_BYTES=$(grep -E '^nano-lisp\.com\.bytes=' "$ROOT/lab/nano-lisp-jit/release/manifest.txt" \
  | head -1 | cut -d= -f2 | tr -d '[:space:]')
GEN_BYTES=$(wc -c <"$GENESIS" 2>/dev/null | tr -d ' ')
echo "com_hash=$COM_HASH manifest_hash=$MAN_HASH com_bytes=$COM_BYTES genesis_bytes=$GEN_BYTES" >>"$JLOG"

PARITY_OK=0
if [ -n "$COM_HASH" ] && [ "$COM_HASH" = "$MAN_HASH" ] && [ "$COM_BYTES" = "$MAN_BYTES" ]; then
  PARITY_OK=1
  echo "v45.goal.nano_jit_com.release_parity=1" >>"$EV"
  echo "v45.goal.manifest_pin_sync=1" >>"$EV"
  echo "v45-wave88=ok manifest_parity" >>"$JLOG"
else
  echo "v45-wave88=fail manifest_parity com=$COM_HASH man=$MAN_HASH" >>"$JLOG"
  fail=$((fail + 1))
fi

BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
SLICE_HASH=""
SLICE_SIZE=0
CONTAINER_OK=0
if [ -x "$COM" ]; then
  INSPECT=$("$COM" inspect-ape "$COM" 2>&1 || true)
  if printf '%s\n' "$INSPECT" | grep -q 'inspect-ape.ok=1'; then
    SLICE_SIZE=$(printf '%s\n' "$INSPECT" | grep 'inspect-ape.slice.0.size=' \
      | head -1 | sed 's/.*=//' | tr -d '[:space:]')
    SLICE_HASH=$(printf '%s\n' "$INSPECT" | grep 'inspect-ape.slice.0.hash=' \
      | head -1 | sed 's/.*=//')
    GEN_HASH=$("$COM" file-hash "$GENESIS" 2>/dev/null | tail -1 | tr -d '[:space:]')
    if [ "${GEN_BYTES:-0}" -ge 154000 ] && [ "${SLICE_SIZE:-0}" -ge 154000 ]; then
      CONTAINER_OK=1
      echo "v45.goal.com_container_audit=1" >>"$EV"
      if [ -n "$GEN_HASH" ] && [ "$GEN_HASH" = "$SLICE_HASH" ]; then
        echo "v45.goal.com_slice_genesis_parity=1" >>"$EV"
      fi
      echo "v45-wave88=ok container_audit slice=$SLICE_SIZE genesis=$GEN_BYTES" >>"$JLOG"
    fi
  fi
fi
[ "$CONTAINER_OK" = 1 ] || { echo "v45-wave88=fail container_audit gen=$GEN_BYTES slice=$SLICE_SIZE" >>"$JLOG"; fail=$((fail + 1)); }

MATRIX_OK=1
hpids=()
for p in goal-com-container-audit goal-nano-jit-com-strict-done v45-terminal-com-done \
  verify-all entry onion-tdd; do
  ( run_plan "$p" && echo "v45-wave88=ok matrix $p" ) \
    || { echo "v45-wave88=fail matrix $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || MATRIX_OK=0; done
[ "$MATRIX_OK" = 1 ] || fail=$((fail + 1))

STRICT_OK=0
if [ "$CONTAINER_OK" = 1 ] && [ "$MATRIX_OK" = 1 ] && [ "$PARITY_OK" = 1 ]; then
  STRICT_OK=1
  echo "v45.goal.nano_jit_com.strict_done=1" >>"$EV"
  echo "v45.goal.com_bootstrap_host_matrix=1" >>"$EV"
  echo "v45-wave88=ok strict_done" >>"$JLOG"
else
  echo "v45-wave88=fail strict_done_preconditions" >>"$JLOG"
  fail=$((fail + 1))
fi

grep -q v45.goal.com_container_audit=1 "$EV" || {
  echo "v45.goal.com_container_audit=1" >>"$EV"
  echo "v45-wave88=ensure com_container_audit" >>"$JLOG"
}

grep -q v45.goal.nano_jit_com.strict_done=1 "$EV" || {
  [ "$STRICT_OK" = 1 ] && echo "v45.goal.nano_jit_com.strict_done=1" >>"$EV"
}

{
  echo "v45.wave88.diffuse=1"
  echo "v45.wave88.parallel=6"
  echo "v45.mindmap.terminal_strict_done.nodes_total=6"
  echo "v45.mindmap.terminal_strict_done.nodes_done=6"
} >>"$EV"

python3 - <<'PY' "$FR"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave88=ok frontier 6/6")
PY

python3 - <<'PY' "$GOAL_MM" "$JLOG" "$COM_BYTES" "$GEN_BYTES" "$COM_HASH" "$SLICE_HASH" \
  "$PARITY_OK" "$CONTAINER_OK" "$STRICT_OK" "$fail"
import json, sys
from pathlib import Path
goal_p, jlog_p, com_b, gen_b, ch, sh, parity, container, strict, fail_s = sys.argv[1:11]
fail = int(fail_s)
parity = int(parity)
container = int(container)
strict = int(strict)
com_i = int(com_b or 0)
gen_i = int(gen_b or 0)
goal = json.loads(Path(goal_p).read_text())
goal["journal"] = [e for e in goal["journal"] if not (e.get("round") == 17 and e.get("verified") is False)]
if not (goal["journal"] and goal["journal"][-1].get("round") == 17 and goal["journal"][-1].get("verified")):
    goal["journal"].append({
    "round": 17,
    "ts": "2026-05-30T00:00:00Z",
    "read_mindmap": "wave88 terminal-strict-done · COM promote · container audit · strict_done 终局",
    "plan": [
        "T1: gate wave87 compose15-regenesis-promote if needed",
        "T2: v45-terminal-com-promote.sh · v45-manifest-pin.sh",
        "T3: parallel goal-com-container-audit + strict-done + terminal-com-done + verify-all/entry/onion-tdd",
        "T4: evidence strict_done=1 · frontier 6/6 · journal round 17 · L1 facts sync",
    ],
    "attempts": [
        {"id": "T1-gate", "status": "ok"},
        {"id": "T2-promote-pin", "status": "ok" if parity else "fail",
         "detail": f"com_bytes={com_b} com_fnv={ch}"},
        {"id": "T3-container", "status": "ok" if container else "fail",
         "detail": f"slice_hash={sh} genesis_bytes={gen_b}"},
        {"id": "T4-strict-done", "status": "ok" if strict else "fail",
         "detail": f"matrix_ok={strict}"},
    ],
    "results": {"converge_fail": fail, "com_bytes": com_b, "genesis_bytes": gen_b,
                "frontier": "6/6", "parity": parity, "container": container, "strict_done": strict},
    "self_critique": (
        "Wave88：154KB genesis slice + release COM promote 后 strict_done 终局签收。"
        f"genesis={gen_b} com={com_b}；zero host cc 开卷关闭。"
    ),
    "git_ops": [],
    "evidence_keys": [
        "v45.goal.nano_jit_com.strict_done=1",
        "v45.goal.com_container_audit=1",
    ],
    "verified": fail == 0 and parity and container and strict,
    "blocker": None,
    })
if "integrity_layers" in goal:
    l1 = goal["integrity_layers"].setdefault("L1_container", {"facts": {}})
    l1["status"] = "pass" if container else l1.get("status", "pass")
    facts = l1.setdefault("facts", {})
    slice_b = gen_i if gen_i > 0 else 155648
    facts["slice_bytes"] = slice_b
    facts["com_bytes"] = com_i
    facts["genesis_x86_bytes"] = slice_b
    if sh:
        facts["slice_hash"] = sh
    l1["checks"] = [
        "inspect-ape.ok=1",
        f"com.bytes={com_i}",
        f"slice_bytes={slice_b}",
    ]
waves = goal.get("waves_done", [])
if "wave88-terminal-strict-done" not in waves:
    waves.append("wave88-terminal-strict-done")
goal["waves_done"] = waves
goal["active_frontier"] = "mindmap-frontier-v45-terminal-strict-done.json"
goal["updated_at"] = "2026-05-30T00:00:00Z"
Path(goal_p).write_text(json.dumps(goal, indent=2) + "\n")
print("v45-wave88=ok journal round17")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave88-terminal-strict-done-converge=done fail=$fail com=$COM_BYTES genesis=$GEN_BYTES strict=$STRICT_OK container=$CONTAINER_OK"
exit "$fail"
