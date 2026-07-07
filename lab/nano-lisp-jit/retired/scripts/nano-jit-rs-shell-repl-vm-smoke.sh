#!/usr/bin/env bash
# nanolisp shell-repl VM smoke — nano read-line + libc:system loop in .lbin.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
READLINE_SRC="$ROOT/lab/nano-lisp-jit/lisp/shell/shell-readline-smoke.lisp"
READLINE_LBIN="$ROOT/lab/nano-lisp-jit/.build/v45-shell-readline-smoke.lbin"
REPL_SRC="$ROOT/lab/nano-lisp-jit/lisp/shell/shell-repl.lisp"
REPL_LBIN="$ROOT/lab/nano-lisp-jit/.build/v45-shell-repl.lbin"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-repl-vm-smoke=fail no_binary"; exit 1; }

"$RS" compile "$READLINE_SRC" "$READLINE_LBIN" >/dev/null
log=$(printf 'piped-line\n' | "$RS" run "$READLINE_LBIN" 2>&1) || true
echo "$log" | grep -q 'resolve.*nano:read-line' || {
  echo "nano-jit-rs-shell-repl-vm-smoke=fail readline_resolve"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'expect.*ok expected=1' || {
  echo "nano-jit-rs-shell-repl-vm-smoke=fail readline_run"
  echo "$log"
  exit 1
}

log=$(printf '%s\n' 'echo nanolisp-shell-repl-vm' exit | "$RS" shell-repl 2>&1) || true
echo "$log" | grep -q 'shell-repl.mode=vm-lbin' || {
  echo "nano-jit-rs-shell-repl-vm-smoke=fail repl_mode"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-repl-vm' || {
  echo "nano-jit-rs-shell-repl-vm-smoke=fail repl_echo"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-shell-repl-vm-smoke=ok"
