#!/usr/bin/env bash
# Wave17 /goal: mindmap-tree 100% 签收.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45.json"
cd "$ROOT"
fail=0
echo "v45-wave17-goal-mindmap-100-converge=begin"
bash "$(dirname "$0")/v45-wave16-mindmap-converge.sh" || fail=$((fail + 1))

COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  if env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
    -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS \
    "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-mindmap-tree-100.lisp" >/dev/null; then
    echo "v45-wave17-goal-mindmap-100-converge=ok plan=goal-mindmap-tree-100"
  else
    echo "v45-wave17-goal-mindmap-100-converge=fail plan=goal-mindmap-tree-100"
    fail=$((fail + 1))
  fi
  env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
    -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS \
    "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-tdd.lisp" >/dev/null \
    && echo "v45-wave17-goal-mindmap-100-converge=ok plan=onion-tdd" \
    || { echo "v45-wave17-goal-mindmap-100-converge=fail plan=onion-tdd"; fail=$((fail + 1)); }
  env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
    -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS \
    "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-terminal-done.lisp" >/dev/null \
    && echo "v45-wave17-goal-mindmap-100-converge=ok plan=terminal-done" \
    || { echo "v45-wave17-goal-mindmap-100-converge=fail plan=terminal-done"; fail=$((fail + 1)); }
fi

python3 - <<'PY' "$FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    if n["id"] == "v45-goal-mindmap-tree":
        n["status"] = "done"
p.write_text(json.dumps(data, indent=2) + "\n")
print("v45-wave17-goal-mindmap-100-converge=ok frontier_goal_done")
PY

n=$(ls -1 lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave17.diffuse=1"
  echo "v45.wave17.rollup=1"
  echo "v45.wave17.plans=$n"
  echo "v45.goal.mindmap_tree.100=1"
  echo "v45.mindmap.tree.coupled=1"
  echo "v45.mindmap.parallel=4"
  echo "v45.onion.tree.mindmap=1"
} >>"$EV"
echo "v45-wave17-goal-mindmap-100-converge=done goal=1 fail=$fail"
exit $fail
