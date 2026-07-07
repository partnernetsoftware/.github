#!/usr/bin/env bash
# nanolisp shell-repl-fgets smoke — libc fgets REPL loop in .lbin (piped stdin).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
SRC="$ROOT/lab/nano-lisp-jit/lisp/shell/shell-repl-fgets.lisp"
LBIN="$ROOT/lab/nano-lisp-jit/.build/v45-shell-repl-fgets.lbin"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-repl-fgets-smoke=fail no_binary"; exit 1; }

"$RS" compile "$SRC" "$LBIN" >/dev/null
log=$(printf '%s\n' 'echo nanolisp-shell-repl-fgets' | "$RS" run "$LBIN" 2>&1) || true
echo "$log" | grep -q 'resolve.*libc:fgets' || {
  echo "nano-jit-rs-shell-repl-fgets-smoke=fail fgets_resolve"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'resolve.*libc:stdin' || {
  echo "nano-jit-rs-shell-repl-fgets-smoke=fail stdin_resolve"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-repl-fgets' || {
  echo "nano-jit-rs-shell-repl-fgets-smoke=fail repl_echo"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-shell-repl-fgets-smoke=ok"
