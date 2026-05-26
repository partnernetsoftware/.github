#!/usr/bin/env bash
# 清洗 + 反思锚点：canonical + wave61 快收敛.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
echo "v45-cleanup-reflect=begin"
bash "$(dirname "$0")/v45-evidence-canonical.sh"
if [ -x "$ROOT/lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com" ] \
  || [ -x "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com" ]; then
  if [ -x "$(dirname "$0")/v45-wave61-physical-honest-terminal-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave61-physical-honest-terminal-converge.sh" || true
  elif [ -x "$(dirname "$0")/v45-wave60-ci-shell-retire-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave60-ci-shell-retire-converge.sh" || true
  elif [ -x "$(dirname "$0")/v45-wave58-host-sh-retire-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave58-host-sh-retire-converge.sh" || true
  elif [ -x "$(dirname "$0")/v45-wave57-lispjit-c-delete-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave57-lispjit-c-delete-converge.sh" || true
  elif [ -x "$(dirname "$0")/v45-wave56-zero-cpysh-target-converge.sh" ]; then
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
