#!/usr/bin/env bash
# pack-ape-bare parity — Rust vs legacy COM byte-identical container.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nano-jit"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
ARM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.aarch64"
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-ape-smoke"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -f "$X86" ] || { echo "nano-jit-rs-ape-smoke=fail no_x86_elf"; exit 1; }
[ -f "$ARM" ] || { echo "nano-jit-rs-ape-smoke=fail no_aarch64_elf"; exit 1; }
mkdir -p "$TMP"
"$RS" pack-ape-bare "$TMP/rs.ape" "$X86" "$ARM" >/dev/null
"$COM" pack-ape-bare "$TMP/com.ape" "$X86" "$ARM" >/dev/null
cmp -s "$TMP/rs.ape" "$TMP/com.ape" || {
  rsz=$(wc -c <"$TMP/rs.ape")
  csz=$(wc -c <"$TMP/com.ape")
  echo "nano-jit-rs-ape-smoke=fail bare_bytes rs=$rsz com=$csz"
  exit 1
}
"$RS" inspect-ape "$TMP/rs.ape" | grep -q 'inspect-ape.ok=1'
"$RS" pack-ape "$TMP/rs.com" "$X86" "$ARM" >/dev/null
"$RS" inspect-ape "$TMP/rs.com" | grep -q 'inspect-ape.ok=1'
echo "nano-jit-rs-ape-smoke=ok"
