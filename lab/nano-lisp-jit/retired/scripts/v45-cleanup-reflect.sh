#!/usr/bin/env bash
# 清洗 + 反思锚点：canonical + wave64 快收敛.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
echo "v45-cleanup-reflect=begin"
bash "$(dirname "$0")/v45-evidence-canonical.sh"
if [ -x "$ROOT/lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com" ] \
  || [ -x "$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com" ]; then
  if [ -x "$(dirname "$0")/v45-wave64-archive-c-factory-retire-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave64-archive-c-factory-retire-converge.sh" || true
  elif [ -x "$ROOT/lab/nano-lisp-jit/retired/scripts/v45-wave63-nano-lisp-com-native-bootstrap-converge.sh" ]; then
    bash "$ROOT/lab/nano-lisp-jit/retired/scripts/v45-wave63-nano-lisp-com-native-bootstrap-converge.sh" || true
  elif [ -x "$ROOT/lab/nano-lisp-jit/retired/scripts/v45-wave62-nano-lisp-com-host-only-converge.sh" ]; then
    bash "$ROOT/lab/nano-lisp-jit/retired/scripts/v45-wave62-nano-lisp-com-host-only-converge.sh" || true
  elif [ -x "$ROOT/lab/nano-lisp-jit/retired/scripts/v45-wave61-physical-honest-terminal-converge.sh" ]; then
    bash "$ROOT/lab/nano-lisp-jit/retired/scripts/v45-wave61-physical-honest-terminal-converge.sh" || true
  elif [ -x "$(dirname "$0")/v45-wave60-ci-shell-retire-converge.sh" ]; then
    bash "$(dirname "$0")/v45-wave60-ci-shell-retire-converge.sh" || true
  fi
fi
bash "$(dirname "$0")/v45-evidence-canonical.sh"
{
  echo "v45.cleanup.reflect=1"
  echo "v45.cleanup.canonical=1"
} >>"$EV"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
if [ ! -x "$COM" ]; then
  COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
fi
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
