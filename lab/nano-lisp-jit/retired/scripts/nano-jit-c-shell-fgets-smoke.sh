#!/usr/bin/env bash
# C track shell-fgets smoke — libc fgets(ptr,i32,stdin) via host-cc NANO_LISP_JIT runner.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RUNNER_SRC="$ROOT/lab/nano-lisp-jit/archive/c/runner"
SRC="$ROOT/lab/nano-lisp-jit/lisp/shell/shell-fgets-smoke.lisp"
LBIN="$ROOT/lab/nano-lisp-jit/.build/v45-c-shell-fgets-smoke.lbin"
HOST_BIN="$ROOT/lab/nano-lisp-jit/.build/nano-lisp-jit-host-fgets"
cd "$ROOT"

echo "nano-jit-c-shell-fgets-smoke=begin"

if ! command -v cc >/dev/null 2>&1; then
  echo "nano-jit-c-shell-fgets-smoke=skip host_cc_missing"
  exit 0
fi

mkdir -p "$(dirname "$HOST_BIN")" "$(dirname "$LBIN")"
cc -DNANO_LISP_JIT \
  -I "$ROOT/lab/lispjit-ir" \
  -I "$RUNNER_SRC" \
  -Os -s "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" \
  -ldl -o "$HOST_BIN"
chmod +x "$HOST_BIN"

"$HOST_BIN" compile "$SRC" "$LBIN" >/dev/null
log=$(printf 'piped-fgets-line\n' | "$HOST_BIN" run "$LBIN" 2>&1) || true
echo "$log" | grep -q 'resolve.*libc:fgets' || {
  echo "nano-jit-c-shell-fgets-smoke=fail fgets_resolve"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'resolve.*libc:stdin' || {
  echo "nano-jit-c-shell-fgets-smoke=fail stdin_resolve"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'expect.*ok expected=nonnull' || {
  echo "nano-jit-c-shell-fgets-smoke=fail fgets_run"
  echo "$log"
  exit 1
}

echo "nano-jit-c-shell-fgets-smoke=ok"
