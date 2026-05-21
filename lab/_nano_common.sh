#!/usr/bin/env bash
# Shared helper for lab/* tools that consume nano-lisp-jit.
set -euo pipefail

_NANO_LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

repo_root() {
  cd "$_NANO_LAB_DIR/.." && pwd
}

nano_runner() {
  local root
  root="$(repo_root)"
  local runner="$root/lab/nano-lisp-jit/.build/nano-lisp-jit"
  if [ ! -x "$runner" ]; then
    echo "nano: building runner via lab/nano-lisp-jit/run.sh (first time)" >&2
    bash "$root/lab/nano-lisp-jit/run.sh" >/dev/null
  fi
  if [ ! -x "$runner" ]; then
    echo "nano: runner missing at $runner" >&2
    return 2
  fi
  printf '%s\n' "$runner"
}
