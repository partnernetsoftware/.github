#!/usr/bin/env bash
# nano-jit-rs AOT smoke — emit/aot ELF64 + run-expect-exit vs C COM reference.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nano-jit"
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

echo "nano-jit-rs-aot-smoke=ok"
