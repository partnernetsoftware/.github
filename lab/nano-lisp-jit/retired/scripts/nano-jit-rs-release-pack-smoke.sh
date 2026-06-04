#!/usr/bin/env bash
# nanolisp release-pack smoke — Rust-built x86_64+aarch64 nanolisp → APE → memfd run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
ARM="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-release-pack-smoke=fail no_binary"; exit 1; }
[ -f "$X86" ] || { echo "nano-jit-rs-release-pack-smoke=fail no_x86"; exit 1; }
[ -f "$ARM" ] || { echo "nano-jit-rs-release-pack-smoke=fail no_aarch64"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-release-pack-smoke"
mkdir -p "$TMP"

BARE="$TMP/nanolisp-rs.ape"
STUB="$TMP/nanolisp-rs.com"
"$RS" pack-ape-bare "$BARE" "$X86" "$ARM" >/dev/null
"$RS" pack-ape "$STUB" "$X86" "$ARM" >/dev/null

log=$("$RS" inspect-ape "$BARE" 2>&1)
echo "$log" | grep -q 'inspect-ape.ok=1' || {
  echo "nano-jit-rs-release-pack-smoke=fail inspect_bare"
  echo "$log"
  exit 1
}

x86_size=$(wc -c <"$X86" | tr -d ' ')
echo "$log" | grep -q "inspect-ape.slice.0.size=$x86_size" || {
  echo "nano-jit-rs-release-pack-smoke=fail x86_size expected=$x86_size"
  echo "$log"
  exit 1
}

log=$("$RS" run-ape "$BARE" 2>&1) || true
echo "$log" | grep -q 'run-ape.loader=memfd' || {
  echo "nano-jit-rs-release-pack-smoke=fail memfd"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-ape.arch=x86_64' || {
  echo "nano-jit-rs-release-pack-smoke=fail arch"
  echo "$log"
  exit 1
}

# nanolisp with no args → embedded shell.lbin → exit 0
log=$("$RS" run-ape-expect-exit "$BARE" 0 2>&1) || true
echo "$log" | grep -q 'run-ape-expect-exit.ok=1' || {
  echo "nano-jit-rs-release-pack-smoke=fail run_exit"
  echo "$log"
  exit 1
}

log=$("$RS" run-ape "$STUB" 2>&1) || true
echo "$log" | grep -q 'run-ape.loader=memfd' || {
  echo "nano-jit-rs-release-pack-smoke=fail stub_memfd"
  echo "$log"
  exit 1
}

# NLCap abin tier wrapping Rust release APE
CAP="$TMP/nanolisp-release.nlcap"
LBIN="$TMP/version.lbin"
"$RS" compile "$ROOT/lab/nano-lisp-jit/lisp/core/arithmetic.lisp" "$LBIN" >/dev/null
"$RS" pack-capsule "$CAP" "$LBIN" --abin "$BARE" >/dev/null
log=$("$RS" run-capsule "$CAP" --tier abin --expect 0 2>&1) || true
echo "$log" | grep -q 'run-capsule.tier=abin' || {
  echo "nano-jit-rs-release-pack-smoke=fail nlcap_abin"
  echo "$log"
  exit 1
}

bare_bytes=$(wc -c <"$BARE" | tr -d ' ')
echo "nano-jit-rs-release-pack-smoke=ok bare.bytes=$bare_bytes x86.bytes=$x86_size"
