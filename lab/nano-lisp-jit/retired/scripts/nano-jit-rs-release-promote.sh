#!/usr/bin/env bash
# Promote Rust-built nanolisp.com (+ bare .ape) into lab/nano-lisp-jit/release/.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
ARM="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64"
REL="$ROOT/lab/nano-lisp-jit/release"
COM_OUT="$REL/nanolisp.com"
APE_OUT="$REL/nanolisp.ape"
SLIM_OUT="$REL/nanolisp-slim.com"
X86_PIN="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
A64_PIN="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64"
MAN="$REL/manifest.txt"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nanolisp.release-promote=fail no_binary"; exit 1; }
[ -f "$X86" ] || { echo "nanolisp.release-promote=fail no_x86"; exit 1; }
[ -f "$ARM" ] || { echo "nanolisp.release-promote=fail no_aarch64"; exit 1; }
mkdir -p "$REL"

TMP="$ROOT/lab/nano-lisp-jit/.build/nanolisp-release-promote"
mkdir -p "$TMP"
"$RS" pack-ape "$TMP/nanolisp.com" "$X86" "$ARM" >/dev/null
"$RS" pack-ape-bare "$TMP/nanolisp.ape" "$X86" "$ARM" >/dev/null
install -m 755 "$TMP/nanolisp.com" "$COM_OUT"
install -m 755 "$TMP/nanolisp.ape" "$APE_OUT"

if [ -f "$X86_PIN" ] && [ -f "$A64_PIN" ]; then
  "$RS" pack-ape "$TMP/nanolisp-slim.com" "$X86_PIN" "$A64_PIN" >/dev/null
  install -m 755 "$TMP/nanolisp-slim.com" "$SLIM_OUT"
fi

COM_BYTES=$(wc -c <"$COM_OUT" | tr -d ' ')
COM_HASH=$("$RS" hash "$COM_OUT")
APE_BYTES=$(wc -c <"$APE_OUT" | tr -d ' ')
APE_HASH=$("$RS" hash "$APE_OUT")
SLIM_BYTES=""
SLIM_HASH=""
if [ -f "$SLIM_OUT" ]; then
  SLIM_BYTES=$(wc -c <"$SLIM_OUT" | tr -d ' ')
  SLIM_HASH=$("$RS" hash "$SLIM_OUT")
fi

LEGACY_BYTES=""
LEGACY_HASH=""
NEXT_BYTES=""
NEXT_HASH=""
if [ -f "$REL/nano-lisp.com" ]; then
  LEGACY_BYTES=$(wc -c <"$REL/nano-lisp.com" | tr -d ' ')
  LEGACY_HASH=$("$RS" hash "$REL/nano-lisp.com")
fi
if [ -f "$REL/v45-selfhost-next.com" ]; then
  NEXT_BYTES=$(wc -c <"$REL/v45-selfhost-next.com" | tr -d ' ')
  NEXT_HASH=$("$RS" hash "$REL/v45-selfhost-next.com")
fi

{
  echo "# fnv1a64 and byte size for pinned release .com artifacts"
  echo
  if [ -n "$LEGACY_BYTES" ]; then
    echo "nano-lisp.com.bytes=$LEGACY_BYTES"
    echo "nano-lisp.com.fnv1a64=$LEGACY_HASH"
    echo "v45-selfhost-next.com.bytes=${NEXT_BYTES:-$LEGACY_BYTES}"
    echo "v45-selfhost-next.com.fnv1a64=${NEXT_HASH:-$LEGACY_HASH}"
    echo
  fi
  echo "nanolisp.com.bytes=$COM_BYTES"
  echo "nanolisp.com.fnv1a64=$COM_HASH"
  echo "nanolisp.com.engine=rust"
  echo "nanolisp.ape.bytes=$APE_BYTES"
  echo "nanolisp.ape.fnv1a64=$APE_HASH"
  if [ -n "$SLIM_BYTES" ]; then
    echo "nanolisp-slim.com.bytes=$SLIM_BYTES"
    echo "nanolisp-slim.com.fnv1a64=$SLIM_HASH"
    echo "nanolisp-slim.com.engine=rust-genesis-pin"
  fi
} >"$MAN"

echo "nanolisp.release-promote=ok"
echo "nanolisp.release-promote.com=$COM_OUT bytes=$COM_BYTES fnv1a64=$COM_HASH"
echo "nanolisp.release-promote.ape=$APE_OUT bytes=$APE_BYTES fnv1a64=$APE_HASH"
if [ -n "$SLIM_BYTES" ]; then
  echo "nanolisp.release-promote.slim=$SLIM_OUT bytes=$SLIM_BYTES fnv1a64=$SLIM_HASH"
fi
