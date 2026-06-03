#!/usr/bin/env bash
# nanolisp lisp-tu link smoke — two .o TU → link-elf64-exe → exit 42 (bootstrap L4).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
CORE="$ROOT/lab/nano-lisp-jit/lisp/core"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-lisp-tu-link-smoke=fail no_binary"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-lisp-tu-link-smoke=fail no_legacy_com"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-lisp-tu-smoke"
mkdir -p "$TMP"

CALLEE="$CORE/lisp-tu-callee.lisp"
MAIN="$CORE/lisp-tu-main.lisp"
CALLEE_O="$TMP/lisp-tu-callee.o"
MAIN_O="$TMP/lisp-tu-main.o"
LINKED="$TMP/lisp-tu-linked.elf"

"$RS" compile-elf64-obj-code "$CALLEE" "$CALLEE_O" nano_tu_callee >/dev/null
"$RS" compile-elf64-obj-code "$MAIN" "$MAIN_O" nano_tu_main >/dev/null
"$RS" link-elf64-exe "$LINKED" nano_tu_main "$MAIN_O" "$CALLEE_O" >/dev/null
log=$("$RS" run-expect-exit "$LINKED" 42 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-lisp-tu-link-smoke=fail run"
  echo "$log"
  exit 1
}

rs_bytes=$("$RS" link-elf64-exe "$TMP/lisp-tu-linked2.elf" nano_tu_main "$MAIN_O" "$CALLEE_O" 2>&1 | sed -n 's/^link.code.bytes=//p')
com_callee="$TMP/lisp-tu-callee-com.o"
com_main="$TMP/lisp-tu-main-com.o"
"$COM" compile-elf64-obj-code "$CALLEE" "$com_callee" nano_tu_callee >/dev/null
"$COM" compile-elf64-obj-code "$MAIN" "$com_main" nano_tu_main >/dev/null
com_bytes=$("$COM" link-elf64-exe "$TMP/lisp-tu-com.elf" nano_tu_main "$com_main" "$com_callee" 2>&1 | sed -n 's/^link.code.bytes=//p')
[ "$rs_bytes" = "$com_bytes" ] || {
  echo "nano-jit-rs-lisp-tu-link-smoke=fail code_bytes rs=$rs_bytes com=$com_bytes"
  exit 1
}

echo "nano-jit-rs-lisp-tu-link-smoke=ok"
