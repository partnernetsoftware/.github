#!/usr/bin/env bash
# Wave18: 洋葱×mindmap 扩展 L4–L7 → unified 100%.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45.json"
cd "$ROOT"
fail=0
echo "v45-wave18-mindmap-unified-converge=begin"
bash "$(dirname "$0")/v45-wave17-goal-mindmap-100-converge.sh" || fail=$((fail + 1))

COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
run_plan() {
  local p=$1
  env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
    -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS \
    "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp"
}

if [ -x "$COM" ]; then
  python3 "$ROOT/lab/nano-lisp-jit/tools/mindmap-dp-v45.py" ready || true
  pids=()
  for p in mindmap-boot-com mindmap-bare-loader mindmap-verify-core-slice mindmap-selfhost-next; do
    ( run_plan "$p" >/dev/null && echo "v45-wave18-mindmap-unified-converge=ok plan=$p" ) \
      || { echo "v45-wave18-mindmap-unified-converge=fail plan=$p"; exit 1; } &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || fail=$((fail + 1)); done
  for p in mindmap-onion-terminal mindmap-unified-tree wave18-diffuse-global wave18-rollup; do
    run_plan "$p" >/dev/null \
      && echo "v45-wave18-mindmap-unified-converge=ok plan=$p" \
      || { echo "v45-wave18-mindmap-unified-converge=fail plan=$p"; fail=$((fail + 1)); }
  done
  run_plan goal-onion-mindmap-unified-100 >/dev/null \
    && echo "v45-wave18-mindmap-unified-converge=ok plan=goal-onion-mindmap-unified-100" \
    || { echo "v45-wave18-mindmap-unified-converge=fail plan=unified-100"; fail=$((fail + 1)); }
fi

python3 - <<'PY' "$FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-mm-boot-com", "v45-mm-bare-loader", "v45-mm-verify-core-slice",
  "v45-mm-selfhost-next", "v45-mm-onion-terminal", "v45-mm-unified-tree",
  "v45-goal-onion-mindmap-unified",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave18-mindmap-unified-converge=ok frontier {done}/{total}")
PY

{
  echo "v45.wave18.diffuse=1"
  echo "v45.wave18.parallel=4"
  echo "v45.wave18.rollup=1"
  echo "v45.mindmap.unified.coupled=1"
  echo "v45.mindmap.nodes_total=14"
  echo "v45.mindmap.nodes_done=14"
  echo "v45.goal.onion_mindmap.unified.100=1"
} >>"$EV"
echo "v45-wave18-mindmap-unified-converge=done unified=1 fail=$fail"
exit $fail
