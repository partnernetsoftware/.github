#!/usr/bin/env bash
# Pin release/manifest.txt from COM file-hash (lispjit fnv1a64 basis).
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
cat >"$MAN" <<EOF
# fnv1a64 and byte size for pinned release .com artifacts

nano-lisp.com.bytes=$BYTES
nano-lisp.com.fnv1a64=$HASH
v45-selfhost-next.com.bytes=$BYTES
v45-selfhost-next.com.fnv1a64=$HASH
EOF
if [ -f "$NEXT" ]; then
  NEXT_BYTES=$(wc -c <"$NEXT" | tr -d ' ')
  if [ "$NEXT_BYTES" != "$BYTES" ]; then
    echo "v45-manifest-pin=warn next_bytes=$NEXT_BYTES com_bytes=$BYTES"
  fi
fi
echo "v45-manifest-pin=ok bytes=$BYTES fnv1a64=$HASH"
exit 0
