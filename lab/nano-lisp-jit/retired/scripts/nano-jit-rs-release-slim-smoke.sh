#!/usr/bin/env bash
# nanolisp slim release smoke — genesis-pin slices → APE (~161KiB pathfinder).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
REL="$ROOT/lab/nano-lisp-jit/release"
SLIM="$REL/nanolisp-slim.com"
MAN="$REL/manifest.txt"
X86_PIN="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
A64_PIN="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64"
MAX_BYTES=500000
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-release-slim-smoke=fail no_binary"; exit 1; }
[ -f "$X86_PIN" ] || { echo "nano-jit-rs-release-slim-smoke=fail no_x86_pin"; exit 1; }
[ -f "$A64_PIN" ] || { echo "nano-jit-rs-release-slim-smoke=fail no_a64_pin"; exit 1; }

bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-release-promote.sh" >/dev/null
[ -f "$SLIM" ] || { echo "nano-jit-rs-release-slim-smoke=fail no_slim"; exit 1; }

slim_bytes=$(wc -c <"$SLIM" | tr -d ' ')
[ "${slim_bytes:-0}" -lt "$MAX_BYTES" ] || {
  echo "nano-jit-rs-release-slim-smoke=fail too_large bytes=$slim_bytes max=$MAX_BYTES"
  exit 1
}

pin_bytes=$(grep '^nanolisp-slim.com.bytes=' "$MAN" | cut -d= -f2)
pin_hash=$(grep '^nanolisp-slim.com.fnv1a64=' "$MAN" | cut -d= -f2)
slim_hash=$("$RS" hash "$SLIM")
[ "$slim_bytes" = "$pin_bytes" ] || {
  echo "nano-jit-rs-release-slim-smoke=fail bytes slim=$slim_bytes pin=$pin_bytes"
  exit 1
}
[ "$slim_hash" = "$pin_hash" ] || {
  echo "nano-jit-rs-release-slim-smoke=fail hash slim=$slim_hash pin=$pin_hash"
  exit 1
}

log=$("$RS" inspect-ape "$SLIM" 2>&1)
echo "$log" | grep -q 'inspect-ape.ok=1' || {
  echo "nano-jit-rs-release-slim-smoke=fail inspect"
  echo "$log"
  exit 1
}

x86_pin_bytes=$(wc -c <"$X86_PIN" | tr -d ' ')
echo "$log" | grep -q "inspect-ape.slice.0.size=$x86_pin_bytes" || {
  echo "nano-jit-rs-release-slim-smoke=fail x86_slice expected=$x86_pin_bytes"
  echo "$log"
  exit 1
}

log=$("$RS" run-ape "$SLIM" 2>&1) || true
echo "$log" | grep -q 'run-ape.loader=memfd' || {
  echo "nano-jit-rs-release-slim-smoke=fail memfd"
  echo "$log"
  exit 1
}

legacy_bytes=$(wc -c <"$REL/nano-lisp.com" | tr -d ' ')
echo "nano-jit-rs-release-slim-smoke=ok slim.bytes=$slim_bytes legacy.c.bytes=$legacy_bytes"
