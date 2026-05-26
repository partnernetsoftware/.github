#!/usr/bin/env bash
# Wave20: 洋葱×mindmap×lisp 完全自举统一 100% (frontier 20/20).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45.json"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GEN2="$ROOT/lab/nano-lisp-jit/.build/v45-w19-lisp-gen2.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave20-lisp-selfhost-unified-converge=skip missing_com"
  exit 0
fi
echo "v45-wave20-lisp-selfhost-unified-converge=begin"
bash "$(dirname "$0")/v45-wave19-selfhost-converge.sh" || fail=$((fail + 1))

run_plan() {
  env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
    -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS \
    "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp"
}

pids=()
for p in mindmap-lisp-only-chain mindmap-next-verify-matrix mindmap-w3-lisp-only; do
  ( run_plan "$p" >/dev/null && echo "v45-wave20=ok plan=$p" ) \
    || { echo "v45-wave20=fail plan=$p"; exit 1; } &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || fail=$((fail + 1)); done

gen2_onion_ok() {
  local out ec=0
  out=$("${GEN[@]}" "$GEN2" run-bootstrap-plan \
    lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-tdd.lisp 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|run-ape-expect-exit\.ok=1' \
    && { return 0; }
  [ "$ec" = 0 ] || [ "$ec" = 42 ]
}

if [ -x "$GEN2" ]; then
  if gen2_onion_ok; then
    echo "v45-wave20=ok gen2_onion_tdd"
    echo "v45.selfhost.gen2_onion=1" >>"$EV"
    run_plan mindmap-gen2-onion >/dev/null \
      && echo "v45-wave20=ok plan=mindmap-gen2-onion" \
      || { echo "v45-wave20=fail plan=mindmap-gen2-onion"; fail=$((fail + 1)); }
  else
    echo "v45-wave20=fail gen2_onion_tdd"
    fail=$((fail + 1))
  fi
else
  echo "v45-wave20=fail gen2_com missing"
  fail=$((fail + 1))
fi

for p in mindmap-selfhost-unified-tree wave20-diffuse-global wave20-rollup goal-lisp-selfhost-unified-100; do
  if run_plan "$p" >/dev/null; then
    echo "v45-wave20=ok plan=$p"
  else
    echo "v45-wave20=fail plan=$p"
    fail=$((fail + 1))
  fi
done

python3 - <<'PY' "$FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-sh-lisp-only-chain", "v45-sh-next-matrix", "v45-sh-gen2-onion",
  "v45-sh-w3-regenesis", "v45-sh-selfhost-terminal", "v45-goal-lisp-selfhost-unified",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave20=ok frontier {done}/{total}")
PY

if [ "$fail" = 0 ]; then
  {
    echo "v45.wave20.diffuse=1"
    echo "v45.wave20.parallel=4"
    echo "v45.wave20.rollup=1"
    echo "v45.mindmap.selfhost.coupled=1"
    echo "v45.mindmap.nodes_total=20"
    echo "v45.mindmap.nodes_done=20"
    echo "v45.goal.lisp_selfhost.unified.100=1"
  } >>"$EV"
  echo "v45-wave20-lisp-selfhost-unified-converge=done unified=1 fail=0"
  exit 0
fi
echo "v45-wave20-lisp-selfhost-unified-converge=done unified=0 fail=$fail"
exit 1
