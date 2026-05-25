#!/usr/bin/env bash
# 清洗 + 反思锚点：重跑 wave21 收敛、rollup evidence、打印 DP stats.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
echo "v45-cleanup-reflect=begin"
bash "$(dirname "$0")/v45-evidence-canonical.sh"
if [ -x "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com" ]; then
  bash "$(dirname "$0")/v45-wave21-onion-tdd-tree-mindmap-100-converge.sh" || true
fi
bash "$(dirname "$0")/v45-evidence-canonical.sh"
python3 "$ROOT/lab/nano-lisp-jit/tools/mindmap-dp-v45.py" stats || true
{
  echo "v45.cleanup.reflect=1"
  echo "v45.cleanup.canonical=1"
} >>"$EV"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  "$COM" run-bootstrap-plan \
    "$ROOT/lab/nano-lisp-jit/samples/bootstrap-v45-cleanup-reflect.lisp" >/dev/null 2>&1 \
    && echo "v45-cleanup-reflect=ok plan=cleanup-reflect" \
    || echo "v45-cleanup-reflect=warn plan=cleanup-reflect"
fi
echo "v45-cleanup-reflect=keys"
grep -E '^v45\.(goal\.|mindmap\.nodes|selfhost\.100)' "$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence.canonical" 2>/dev/null || true
echo "v45-cleanup-reflect=done"
