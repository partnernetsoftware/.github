#!/usr/bin/env bash
# nanolisp shell-fgets smoke — libc fgets(ptr,i32,stdin) from VM.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
SRC="$ROOT/lab/nano-lisp-jit/lisp/shell/shell-fgets-smoke.lisp"
LBIN="$ROOT/lab/nano-lisp-jit/.build/v45-shell-fgets-smoke.lbin"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-fgets-smoke=fail no_binary"; exit 1; }

"$RS" compile "$SRC" "$LBIN" >/dev/null
log=$(printf 'piped-fgets-line\n' | "$RS" run "$LBIN" 2>&1) || true
echo "$log" | grep -q 'resolve.*libc:fgets' || {
  echo "nano-jit-rs-shell-fgets-smoke=fail fgets_resolve"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'resolve.*libc:stdin' || {
  echo "nano-jit-rs-shell-fgets-smoke=fail stdin_resolve"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'expect.*ok expected=nonnull' || {
  echo "nano-jit-rs-shell-fgets-smoke=fail fgets_run"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-shell-fgets-smoke=ok"
