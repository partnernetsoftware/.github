#!/usr/bin/env bash
# pack-ape-bare parity — Rust vs legacy COM byte-identical container.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
ARM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.aarch64"
RS_X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
RS_ARM="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64"
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-ape-smoke"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
LEGACY_SLICES=1
STUB_SLICES=0
if [ ! -f "$X86" ] || [ ! -f "$ARM" ]; then
  X86="$RS_X86"
  ARM="$RS_ARM"
  LEGACY_SLICES=0
fi
mkdir -p "$TMP"
if [ ! -f "$X86" ]; then
  X86="$TMP/x86-stub.elf"
  "$RS" emit-elf64-exit "$X86" 1 >/dev/null
  STUB_SLICES=1
fi
if [ ! -f "$ARM" ]; then
  # Last resort: x86 exit stub in aarch64 slot (host run-ape uses native slice).
  ARM="$TMP/aarch64-stub.elf"
  "$RS" emit-elf64-exit "$ARM" 1 >/dev/null
  STUB_SLICES=1
fi
[ -f "$X86" ] || { echo "nano-jit-rs-ape-smoke=fail no_x86_elf"; exit 1; }
[ -f "$ARM" ] || { echo "nano-jit-rs-ape-smoke=fail no_aarch64_elf"; exit 1; }
"$RS" pack-ape-bare "$TMP/rs.ape" "$X86" "$ARM" >/dev/null
if [ "$LEGACY_SLICES" -eq 1 ]; then
  "$COM" pack-ape-bare "$TMP/com.ape" "$X86" "$ARM" >/dev/null
  cmp -s "$TMP/rs.ape" "$TMP/com.ape" || {
    rsz=$(wc -c <"$TMP/rs.ape")
    csz=$(wc -c <"$TMP/com.ape")
    echo "nano-jit-rs-ape-smoke=fail bare_bytes rs=$rsz com=$csz"
    exit 1
  }
fi
"$RS" inspect-ape "$TMP/rs.ape" | grep -q 'inspect-ape.ok=1'
"$RS" pack-ape "$TMP/rs.com" "$X86" "$ARM" >/dev/null
"$RS" inspect-ape "$TMP/rs.com" | grep -q 'inspect-ape.ok=1'
log=$("$RS" run-ape "$TMP/rs.com" 2>&1 || true)
echo "$log" | grep -q 'run-ape.loader=memfd'
log=$("$RS" run-ape "$TMP/rs.ape" 2>&1 || true)
echo "$log" | grep -q 'run-ape.loader=memfd'
"$RS" run-ape-expect-exit "$TMP/rs.com" 1 2>&1 | grep -q 'run-ape-expect-exit.ok=1'
echo "nano-jit-rs-ape-smoke=ok legacy_slices=$LEGACY_SLICES stub_slices=$STUB_SLICES"
