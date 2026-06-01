#!/usr/bin/env bash
# nano-jit-rs smoke — compile via Rust compiler, run via Rust VM.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nano-jit"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-smoke=fail no_binary"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-smoke=fail no_legacy_com"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-smoke"
mkdir -p "$TMP"
"$RS" compile lab/nano-lisp-jit/lisp/core/arithmetic.lisp "$TMP/arithmetic.lbin"
"$RS" run "$TMP/arithmetic.lbin" | grep -q 'expect.2=ok'
"$RS" compile lab/nano-lisp-jit/lisp/core/strlen.lisp "$TMP/strlen.lbin"
"$RS" run "$TMP/strlen.lbin" | grep -q 'expect.1=ok'
# hash parity with legacy COM
AH=$("$RS" hash "$TMP/arithmetic.lbin")
CH=$("$COM" hash "$TMP/arithmetic.lbin" | sed -n 's/^blob.fnv1a64=//p')
[ "$AH" = "$CH" ] || { echo "nano-jit-rs-smoke=fail hash_arithmetic ah=$AH ch=$CH"; exit 1; }
SH=$("$RS" hash "$TMP/strlen.lbin")
CH2=$("$COM" hash "$TMP/strlen.lbin" | sed -n 's/^blob.fnv1a64=//p')
[ "$SH" = "$CH2" ] || { echo "nano-jit-rs-smoke=fail hash_strlen sh=$SH ch=$CH2"; exit 1; }
"$RS" inspect-ape "$COM" | grep -q 'inspect-ape.ok=1'
echo "nano-jit-rs-smoke=ok"
