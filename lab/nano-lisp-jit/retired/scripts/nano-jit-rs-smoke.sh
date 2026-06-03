#!/usr/bin/env bash
# nano-jit-rs smoke — Rust compile .lisp -> .lbin, run bytecode, hash parity vs C COM.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
CORE="$ROOT/lab/nano-lisp-jit/lisp/core"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-smoke=fail no_binary"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-smoke=fail no_legacy_com"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-smoke"
mkdir -p "$TMP"

# bootstrap-smoke core programs (compile + run + hash parity)
CASES=(
  arithmetic
  arithmetic-i64
  control-flow
  strlen
  typed-values
  ptr-values
  const-ptr-load-u8
  libc-smoke
)

for name in "${CASES[@]}"; do
  src="$CORE/$name.lisp"
  rs_out="$TMP/$name.lbin"
  com_out="$TMP/$name.com.lbin"
  "$RS" compile "$src" "$rs_out"
  "$COM" compile "$src" "$com_out"
  rh=$("$RS" hash "$rs_out")
  ch=$("$COM" hash "$com_out" | sed -n 's/^blob.fnv1a64=//p')
  [ "$rh" = "$ch" ] || { echo "nano-jit-rs-smoke=fail hash_$name rh=$rh ch=$ch"; exit 1; }
  "$RS" run "$rs_out" >/dev/null
done

# spot-check expect anchors
"$RS" run "$TMP/arithmetic.lbin" | grep -q 'expect.2=ok'
"$RS" run "$TMP/strlen.lbin" | grep -q 'expect.1=ok'
"$RS" resolve-quiet "$TMP/strlen.lbin" >/dev/null
"$RS" resolve-quiet "$TMP/libc-smoke.lbin" >/dev/null
"$RS" inspect-ape "$COM" | grep -q 'inspect-ape.ok=1'
echo "nano-jit-rs-smoke=ok"
