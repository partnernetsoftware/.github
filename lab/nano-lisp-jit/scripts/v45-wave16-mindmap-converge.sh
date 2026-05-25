#!/usr/bin/env bash
# Wave16: 洋葱×mindmap 四轨并发 + 树耦合.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45.json"
cd "$ROOT"
fail=0
echo "v45-wave16-mindmap-converge=begin"
bash "$(dirname "$0")/v45-wave15-tier5-100-converge.sh" || fail=$((fail + 1))

python3 "$ROOT/lab/nano-lisp-jit/tools/mindmap-dp-v45.py" ready || true

COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  pids=()
  for p in mindmap-verify-smoke mindmap-com-lbin mindmap-ir-exit mindmap-onion-ring; do
    (
      if env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
        -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS \
        "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp" >/dev/null; then
        echo "v45-wave16-mindmap-converge=ok plan=$p"
      else
        echo "v45-wave16-mindmap-converge=fail plan=$p"
        exit 1
      fi
    ) &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || fail=$((fail + 1)); done
  for p in mindmap-onion-tree wave16-diffuse-global wave16-rollup; do
    env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
      -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS \
      "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp" >/dev/null \
      && echo "v45-wave16-mindmap-converge=ok plan=$p" \
      || { echo "v45-wave16-mindmap-converge=fail plan=$p"; fail=$((fail + 1)); }
  done
fi

# 回写 frontier：L1 四节点 done
python3 - <<'PY' "$FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
done_set = {
    "v45-mindmap-verify-smoke", "v45-mindmap-com-lbin",
    "v45-mindmap-ir-exit", "v45-mindmap-onion-ring", "v45-mindmap-onion-tree",
}
for n in data["nodes"]:
    if n["id"] in done_set:
        n["status"] = "done"
p.write_text(json.dumps(data, indent=2) + "\n")
print("v45-wave16-mindmap-converge=ok frontier_updated")
PY

{
  echo "v45.wave16.diffuse=1"
  echo "v45.wave16.parallel=4"
  echo "v45.wave16.rollup=1"
  echo "v45.mindmap.diffuse=1"
  echo "v45.mindmap.parallel=4"
  echo "v45.mindmap.tree.coupled=1"
  echo "v45.onion.tree.mindmap=1"
} >>"$EV"
echo "v45-wave16-mindmap-converge=done fail=$fail"
exit $fail
