#!/usr/bin/env bash
# Pin release/manifest.txt nano-lisp.com* from COM file-hash (lispjit fnv1a64 basis).
# Preserves nanolisp.com / nanolisp.ape pins (Rust track) when present.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="${1:-$ROOT/lab/nano-lisp-jit/release/nano-lisp.com}"
MAN="$ROOT/lab/nano-lisp-jit/release/manifest.txt"
NEXT="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
if [ ! -x "$COM" ]; then
  echo "v45-manifest-pin=fail missing_com path=$COM"
  exit 1
fi
BYTES=$(wc -c <"$COM" | tr -d ' ')
HASH=$("$COM" file-hash "$COM" 2>/dev/null | tail -1 | tr -d '[:space:]')
if [ -z "$HASH" ] || [ "${#HASH}" -ne 16 ]; then
  echo "v45-manifest-pin=fail bad_hash hash=$HASH"
  exit 1
fi
NANO_EXTRA=()
if [ -f "$MAN" ]; then
  while IFS= read -r line; do
    case "$line" in
      nanolisp*) NANO_EXTRA+=("$line") ;;
    esac
  done <"$MAN"
fi
{
  echo "# fnv1a64 and byte size for pinned release .com artifacts"
  echo
  echo "nano-lisp.com.bytes=$BYTES"
  echo "nano-lisp.com.fnv1a64=$HASH"
  echo "v45-selfhost-next.com.bytes=$BYTES"
  echo "v45-selfhost-next.com.fnv1a64=$HASH"
  if [ "${#NANO_EXTRA[@]}" -gt 0 ]; then
    echo
    printf '%s\n' "${NANO_EXTRA[@]}"
  fi
} >"$MAN"
if [ -f "$NEXT" ]; then
  NEXT_BYTES=$(wc -c <"$NEXT" | tr -d ' ')
  if [ "$NEXT_BYTES" != "$BYTES" ]; then
    echo "v45-manifest-pin=warn next_bytes=$NEXT_BYTES com_bytes=$BYTES"
  fi
fi
echo "v45-manifest-pin=ok bytes=$BYTES fnv1a64=$HASH nanolisp_lines=${#NANO_EXTRA[@]}"
exit 0
