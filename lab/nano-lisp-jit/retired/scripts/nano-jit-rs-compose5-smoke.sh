#!/usr/bin/env bash
# nanolisp compose-5link smoke — 5 TU obj compile + link → exit 42 (bootstrap L4+).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
CORE="$ROOT/lab/nano-lisp-jit/lisp/core"
MODS="$ROOT/lab/nano-lisp-jit/lisp/modules"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-compose5-smoke=fail no_binary"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-compose5-smoke=fail no_legacy_com"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-compose5-smoke"
mkdir -p "$TMP"

CALLEE_O="$TMP/callee.o"
MAIN_O="$TMP/main.o"
EXTRA_O="$TMP/extra.o"
CORE_O="$TMP/core.o"
MF_O="$TMP/mf.o"
LINKED="$TMP/compose5-linked.elf"

"$RS" compile-elf64-obj-code "$CORE/lisp-tu-callee.lisp" "$CALLEE_O" nano_tu_callee >/dev/null
"$RS" compile-elf64-obj-code "$CORE/lisp-tu-main.lisp" "$MAIN_O" nano_tu_main >/dev/null
"$RS" compile-elf64-obj-code "$MODS/01-runtime-extra.lisp" "$EXTRA_O" nano_lispjit_extra >/dev/null
"$RS" compile-elf64-obj-code "$MODS/00-runtime-core.lisp" "$CORE_O" nano_mod_core >/dev/null
"$RS" compile-elf64-obj-code "$CORE/multi-func.lisp" "$MF_O" nano_mf_mod >/dev/null

"$RS" link-elf64-exe "$LINKED" nano_tu_main \
  "$MAIN_O" "$CALLEE_O" "$EXTRA_O" "$CORE_O" "$MF_O" >/dev/null

log=$("$RS" run-expect-exit "$LINKED" 42 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-compose5-smoke=fail run"
  echo "$log"
  exit 1
}

rs_bytes=$("$RS" link-elf64-exe "$TMP/compose5-linked2.elf" nano_tu_main \
  "$MAIN_O" "$CALLEE_O" "$EXTRA_O" "$CORE_O" "$MF_O" 2>&1 | sed -n 's/^link.code.bytes=//p')

com_callee="$TMP/callee-com.o"
com_main="$TMP/main-com.o"
com_extra="$TMP/extra-com.o"
com_core="$TMP/core-com.o"
com_mf="$TMP/mf-com.o"
"$COM" compile-elf64-obj-code "$CORE/lisp-tu-callee.lisp" "$com_callee" nano_tu_callee >/dev/null
"$COM" compile-elf64-obj-code "$CORE/lisp-tu-main.lisp" "$com_main" nano_tu_main >/dev/null
"$COM" compile-elf64-obj-code "$MODS/01-runtime-extra.lisp" "$com_extra" nano_lispjit_extra >/dev/null
"$COM" compile-elf64-obj-code "$MODS/00-runtime-core.lisp" "$com_core" nano_mod_core >/dev/null
"$COM" compile-elf64-obj-code "$CORE/multi-func.lisp" "$com_mf" nano_mf_mod >/dev/null
com_bytes=$("$COM" link-elf64-exe "$TMP/compose5-com.elf" nano_tu_main \
  "$com_main" "$com_callee" "$com_extra" "$com_core" "$com_mf" 2>&1 | sed -n 's/^link.code.bytes=//p')

[ "$rs_bytes" = "$com_bytes" ] || {
  echo "nano-jit-rs-compose5-smoke=fail code_bytes rs=$rs_bytes com=$com_bytes"
  exit 1
}

echo "nano-jit-rs-compose5-smoke=ok link.code.bytes=$rs_bytes"
