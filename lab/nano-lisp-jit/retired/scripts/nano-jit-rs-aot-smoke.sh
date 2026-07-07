#!/usr/bin/env bash
# nano-jit-rs AOT smoke — emit/aot ELF64 + run-expect-exit vs C COM reference.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
CORE="$ROOT/lab/nano-lisp-jit/lisp/core"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-aot-smoke=fail no_binary"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-aot-smoke=fail no_legacy_com"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-aot-smoke"
mkdir -p "$TMP"

run_case() {
  local name="$1" exit_code="$2"
  local lbin="$TMP/$name.lbin"
  local elf="$TMP/$name-rs.elf"
  "$RS" compile "$CORE/$name.lisp" "$lbin" >/dev/null
  "$RS" aot-elf64-code "$lbin" "$elf" >/dev/null
  log=$("$RS" run-expect-exit "$elf" "$exit_code" 2>&1) || true
  echo "$log" | grep -q 'run-expect-exit.ok=1' || {
    echo "nano-jit-rs-aot-smoke=fail case=$name exit=$exit_code"
    echo "$log"
    exit 1
  }
}

# emit-elf64-exit stub
STUB="$TMP/emit42.elf"
"$RS" emit-elf64-exit "$STUB" 42 >/dev/null
log=$("$RS" run-expect-exit "$STUB" 42 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1'

# constexpr aot-elf64-exit (control-flow)
CF="$TMP/control-flow.lbin"
"$RS" compile "$CORE/control-flow.lisp" "$CF" >/dev/null
"$RS" aot-elf64-exit "$CF" "$TMP/control-flow-exit.elf" >/dev/null
log=$("$RS" run-expect-exit "$TMP/control-flow-exit.elf" 1 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1'

run_case arithmetic 42
run_case control-flow 1
run_case arithmetic-bad 125

MF="$TMP/multi-func.elf"
"$RS" compile-elf64-exe "$CORE/multi-func.lisp" "$MF" nano_main >/dev/null
log=$("$RS" run-expect-exit "$MF" 43 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-aot-smoke=fail multi-func"
  echo "$log"
  exit 1
}

MFC="$TMP/multi-func-control-flow.elf"
"$RS" compile-elf64-exe "$CORE/multi-func-control-flow.lisp" "$MFC" nano_main >/dev/null
log=$("$RS" run-expect-exit "$MFC" 43 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-aot-smoke=fail multi-func-control-flow"
  echo "$log"
  exit 1
}
rs_mfc=$("$RS" compile-elf64-exe "$CORE/multi-func-control-flow.lisp" "$TMP/mfc2.elf" nano_main 2>&1 | sed -n 's/^link.code.bytes=//p')
com_mfc=$("$COM" compile-elf64-exe "$CORE/multi-func-control-flow.lisp" "$TMP/mfc-com.elf" nano_main 2>&1 | sed -n 's/^link.code.bytes=//p')
[ "$rs_mfc" = "$com_mfc" ] || {
  echo "nano-jit-rs-aot-smoke=fail mfc_code_bytes rs=$rs_mfc com=$com_mfc"
  exit 1
}

RO="$TMP/rodata-readonly.elf"
"$RS" compile-elf64-exe "$CORE/rodata-readonly.lisp" "$RO" nano_main >/dev/null
log=$("$RS" run-expect-exit "$RO" 0 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-aot-smoke=fail rodata-readonly"
  echo "$log"
  exit 1
}

# compile-elf64-code one-shot
CE="$TMP/compile-arith.elf"
"$RS" compile-elf64-code "$CORE/arithmetic.lisp" "$CE" >/dev/null
log=$("$RS" run-expect-exit "$CE" 42 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1'

# parity: RS aot code bytes vs COM on arithmetic
COM_ELF="$TMP/arithmetic-com.elf"
"$RS" compile "$CORE/arithmetic.lisp" "$TMP/arithmetic.lbin" >/dev/null
"$COM" aot-elf64-code "$TMP/arithmetic.lbin" "$COM_ELF" 2>/dev/null | grep -q 'aot.code.output'
rs_bytes=$("$RS" aot-elf64-code "$TMP/arithmetic.lbin" "$TMP/arithmetic-rs2.elf" 2>&1 | sed -n 's/^link.code.bytes=//p')
com_bytes=$("$COM" aot-elf64-code "$TMP/arithmetic.lbin" "$COM_ELF" 2>&1 | sed -n 's/^link.code.bytes=//p')
[ "$rs_bytes" = "$com_bytes" ] || {
  echo "nano-jit-rs-aot-smoke=fail code_bytes rs=$rs_bytes com=$com_bytes"
  exit 1
}

run_case const-ptr-load-u8 1

# const-ptr obj+link parity: .data section size vs C COM
"$RS" compile "$CORE/const-ptr-load-u8.lisp" "$TMP/const-ptr.lbin" >/dev/null
rs_data=$("$RS" aot-elf64-code "$TMP/const-ptr.lbin" "$TMP/const-ptr-rs.elf" 2>&1 | sed -n 's/^link.data.bytes=//p')
com_data=$("$COM" aot-elf64-code "$TMP/const-ptr.lbin" "$TMP/const-ptr-com.elf" 2>&1 | sed -n 's/^link.data.bytes=//p')
[ "$rs_data" = "$com_data" ] || {
  echo "nano-jit-rs-aot-smoke=fail data_bytes rs=$rs_data com=$com_data"
  exit 1
}

# obj-only compile + link (multi-func-control-flow)
MFC_OBJ="$TMP/multi-func-control-flow.o"
MFC_LINK="$TMP/multi-func-control-flow-linked.elf"
"$RS" compile-elf64-obj-code "$CORE/multi-func-control-flow.lisp" "$MFC_OBJ" nano_main >/dev/null
"$RS" link-elf64-exe "$MFC_LINK" nano_main "$MFC_OBJ" >/dev/null
log=$("$RS" run-expect-exit "$MFC_LINK" 43 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-aot-smoke=fail obj-link-mfc"
  echo "$log"
  exit 1
}

# aot-elf64-obj-code + link (arithmetic pure blob)
"$RS" compile "$CORE/arithmetic.lisp" "$TMP/arithmetic-obj.lbin" >/dev/null
ARITH_OBJ="$TMP/arithmetic.o"
"$RS" aot-elf64-obj-code "$TMP/arithmetic-obj.lbin" "$ARITH_OBJ" nano_main >/dev/null
ARITH_LINK="$TMP/arithmetic-linked.elf"
"$RS" link-elf64-exe "$ARITH_LINK" nano_main "$ARITH_OBJ" >/dev/null
log=$("$RS" run-expect-exit "$ARITH_LINK" 42 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-aot-smoke=fail obj-link-arithmetic"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-aot-smoke=ok"
