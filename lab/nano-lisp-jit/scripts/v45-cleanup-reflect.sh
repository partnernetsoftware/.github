#!/usr/bin/env bash
# 清洗 + 反思锚点：canonical + wave51 快收敛 + DP stats.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
echo "v45-cleanup-reflect=begin"
bash "$(dirname "$0")/v45-evidence-canonical.sh"
if [ -x "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com" ]; then
  if [ -x "$(dirname "$0")/v45-wave56-zero-cpysh-target-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave56-zero-cpysh-target-converge.sh" || true
  elif [ -x "$(dirname "$0")/v45-wave55-tools-py-plan-only-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave53-lispjit-154kb-codegen-expand-converge.sh" || true
  elif [ -x "$(dirname "$0")/v45-wave52-physical-zero-cpysh-continue-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave52-physical-zero-cpysh-continue-converge.sh" || true
  elif [ -x "$(dirname "$0")/v45-wave51-v45-terminal-complete-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave51-v45-terminal-complete-converge.sh" || true
  elif [ -x "$(dirname "$0")/v45-wave48-lisp-com-bootstrap-terminal-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave48-lisp-com-bootstrap-terminal-converge.sh" || true
  fi
fi
bash "$(dirname "$0")/v45-evidence-canonical.sh"
NANO_V45_FRONTIER=mindmap-frontier-v45-zero-cpysh-target.json \
  python3 "$ROOT/lab/nano-lisp-jit/tools/mindmap-dp-v45.py" stats || true
{
  echo "v45.cleanup.reflect=1"
  echo "v45.cleanup.canonical=1"
} >>"$EV"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  "$COM" run-bootstrap-plan \
    "$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-cleanup-reflect.lisp" >/dev/null 2>&1 \
    && echo "v45-cleanup-reflect=ok plan=cleanup-reflect" \
    || echo "v45-cleanup-reflect=warn plan=cleanup-reflect"
fi
echo "v45-cleanup-reflect=keys"
grep -E '^v45\.(goal\.|v45\.v45_terminal|v45\.v45\.)' \
  "$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence.canonical" 2>/dev/null || true
echo "v45-cleanup-reflect=done"
