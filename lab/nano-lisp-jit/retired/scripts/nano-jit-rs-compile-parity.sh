#!/usr/bin/env bash
# Full lisp/core compile parity audit — Rust vs legacy COM (excludes *-bad and ir-table).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
CORE="$ROOT/lab/nano-lisp-jit/lisp/core"
TMP="$ROOT/lab/nano-lisp-jit/.build/compile-parity"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
mkdir -p "$TMP"
ok=0
skip=0
fail=0
for src in "$CORE"/*.lisp; do
  base=$(basename "$src" .lisp)
  case "$base" in
    *-bad|v4-ir-table-*)
      skip=$((skip + 1))
      continue
      ;;
  esac
  if ! "$RS" compile "$src" "$TMP/rs.lbin" >/dev/null 2>&1; then
    echo "compile-parity=fail rust_compile name=$base"
    fail=$((fail + 1))
    continue
  fi
  if ! "$COM" compile "$src" "$TMP/com.lbin" >/dev/null 2>&1; then
    echo "compile-parity=fail com_compile name=$base"
    fail=$((fail + 1))
    continue
  fi
  rh=$("$RS" hash "$TMP/rs.lbin")
  ch=$("$COM" hash "$TMP/com.lbin" | sed -n 's/^blob.fnv1a64=//p')
  if [ "$rh" = "$ch" ]; then
    ok=$((ok + 1))
  else
    echo "compile-parity=fail hash name=$base rh=$rh ch=$ch"
    fail=$((fail + 1))
  fi
done
echo "compile-parity.ok=$ok compile-parity.skip=$skip compile-parity.fail=$fail"
[ "$fail" -eq 0 ]
