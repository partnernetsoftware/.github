#!/usr/bin/env bash
# nanolisp release promote smoke — rebuild .com/.ape must match release/ pins + memfd run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
REL="$ROOT/lab/nano-lisp-jit/release"
COM="$REL/nanolisp.com"
APE="$REL/nanolisp.ape"
MAN="$REL/manifest.txt"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-release-promote.sh" >/dev/null
[ -x "$COM" ] || { echo "nano-jit-rs-release-promote-smoke=fail no_com"; exit 1; }
[ -f "$APE" ] || { echo "nano-jit-rs-release-promote-smoke=fail no_ape"; exit 1; }
[ -f "$MAN" ] || { echo "nano-jit-rs-release-promote-smoke=fail no_manifest"; exit 1; }

pin_bytes=$(grep '^nanolisp.com.bytes=' "$MAN" | cut -d= -f2)
pin_hash=$(grep '^nanolisp.com.fnv1a64=' "$MAN" | cut -d= -f2)
com_bytes=$(wc -c <"$COM" | tr -d ' ')
com_hash=$("$RS" hash "$COM")
[ "$com_bytes" = "$pin_bytes" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail bytes com=$com_bytes pin=$pin_bytes"
  exit 1
}
[ "$com_hash" = "$pin_hash" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail hash com=$com_hash pin=$pin_hash"
  exit 1
}

TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-release-promote-smoke"
mkdir -p "$TMP"
X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
ARM="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64"
"$RS" pack-ape "$TMP/rebuild.com" "$X86" "$ARM" >/dev/null
cmp -s "$COM" "$TMP/rebuild.com" || {
  echo "nano-jit-rs-release-promote-smoke=fail rebuild_mismatch"
  exit 1
}

log=$("$RS" inspect-ape "$COM" 2>&1)
echo "$log" | grep -q 'inspect-ape.ok=1' || {
  echo "nano-jit-rs-release-promote-smoke=fail inspect"
  echo "$log"
  exit 1
}

log=$("$RS" run-ape-expect-exit "$COM" 1 2>&1) || true
echo "$log" | grep -q 'run-ape-expect-exit.ok=1' || {
  echo "nano-jit-rs-release-promote-smoke=fail run_com"
  echo "$log"
  exit 1
}

log=$("$RS" run-ape-expect-exit "$APE" 1 2>&1) || true
echo "$log" | grep -q 'run-ape-expect-exit.ok=1' || {
  echo "nano-jit-rs-release-promote-smoke=fail run_ape"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-release-promote-smoke=ok bytes=$com_bytes fnv1a64=$com_hash"
