#!/usr/bin/env bash
# nanolisp release promote smoke — verify-only: rebuild .com/.ape in .build/ must match release/ pins + memfd run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
REL="$ROOT/lab/nano-lisp-jit/release"
COM="$REL/nanolisp.com"
APE="$REL/nanolisp.ape"
MAN="$REL/manifest.txt"
X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
ARM="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-release-promote-smoke=fail no_binary"; exit 1; }
[ -f "$X86" ] || { echo "nano-jit-rs-release-promote-smoke=fail no_x86"; exit 1; }
[ -f "$ARM" ] || { echo "nano-jit-rs-release-promote-smoke=fail no_aarch64"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-release-promote-smoke=fail no_com"; exit 1; }
[ -f "$APE" ] || { echo "nano-jit-rs-release-promote-smoke=fail no_ape"; exit 1; }
[ -f "$MAN" ] || { echo "nano-jit-rs-release-promote-smoke=fail no_manifest"; exit 1; }

pin_com_bytes=$(grep '^nanolisp.com.bytes=' "$MAN" | cut -d= -f2)
pin_com_hash=$(grep '^nanolisp.com.fnv1a64=' "$MAN" | cut -d= -f2)
pin_ape_bytes=$(grep '^nanolisp.ape.bytes=' "$MAN" | cut -d= -f2)
pin_ape_hash=$(grep '^nanolisp.ape.fnv1a64=' "$MAN" | cut -d= -f2)

com_bytes=$(wc -c <"$COM" | tr -d ' ')
com_hash=$("$RS" hash "$COM")
[ "$com_bytes" = "$pin_com_bytes" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail bytes com=$com_bytes pin=$pin_com_bytes"
  exit 1
}
[ "$com_hash" = "$pin_com_hash" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail hash com=$com_hash pin=$pin_com_hash"
  exit 1
}

ape_bytes=$(wc -c <"$APE" | tr -d ' ')
ape_hash=$("$RS" hash "$APE")
[ "$ape_bytes" = "$pin_ape_bytes" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail bytes ape=$ape_bytes pin=$pin_ape_bytes"
  exit 1
}
[ "$ape_hash" = "$pin_ape_hash" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail hash ape=$ape_hash pin=$pin_ape_hash"
  exit 1
}

TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-release-promote-smoke"
mkdir -p "$TMP"
"$RS" pack-ape "$TMP/rebuild.com" "$X86" "$ARM" >/dev/null
"$RS" pack-ape-bare "$TMP/rebuild.ape" "$X86" "$ARM" >/dev/null

rebuild_com_bytes=$(wc -c <"$TMP/rebuild.com" | tr -d ' ')
rebuild_com_hash=$("$RS" hash "$TMP/rebuild.com")
[ "$rebuild_com_bytes" = "$pin_com_bytes" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail rebuild_bytes com=$rebuild_com_bytes pin=$pin_com_bytes"
  exit 1
}
[ "$rebuild_com_hash" = "$pin_com_hash" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail rebuild_hash com=$rebuild_com_hash pin=$pin_com_hash"
  exit 1
}
cmp -s "$COM" "$TMP/rebuild.com" || {
  echo "nano-jit-rs-release-promote-smoke=fail rebuild_com_mismatch"
  exit 1
}

rebuild_ape_bytes=$(wc -c <"$TMP/rebuild.ape" | tr -d ' ')
rebuild_ape_hash=$("$RS" hash "$TMP/rebuild.ape")
[ "$rebuild_ape_bytes" = "$pin_ape_bytes" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail rebuild_bytes ape=$rebuild_ape_bytes pin=$pin_ape_bytes"
  exit 1
}
[ "$rebuild_ape_hash" = "$pin_ape_hash" ] || {
  echo "nano-jit-rs-release-promote-smoke=fail rebuild_hash ape=$rebuild_ape_hash pin=$pin_ape_hash"
  exit 1
}
cmp -s "$APE" "$TMP/rebuild.ape" || {
  echo "nano-jit-rs-release-promote-smoke=fail rebuild_ape_mismatch"
  exit 1
}

log=$("$RS" inspect-ape "$COM" 2>&1)
echo "$log" | grep -q 'inspect-ape.ok=1' || {
  echo "nano-jit-rs-release-promote-smoke=fail inspect"
  echo "$log"
  exit 1
}

log=$("$RS" run-ape-expect-exit "$COM" 0 2>&1) || true
echo "$log" | grep -q 'run-ape-expect-exit.ok=1' || {
  echo "nano-jit-rs-release-promote-smoke=fail run_com"
  echo "$log"
  exit 1
}

log=$("$RS" run-ape-expect-exit "$APE" 0 2>&1) || true
echo "$log" | grep -q 'run-ape-expect-exit.ok=1' || {
  echo "nano-jit-rs-release-promote-smoke=fail run_ape"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-release-promote-smoke=ok bytes=$com_bytes fnv1a64=$com_hash"
