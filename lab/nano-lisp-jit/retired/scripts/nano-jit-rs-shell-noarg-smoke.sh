#!/usr/bin/env bash
# nanolisp shell Phase 3 — no-arg dispatch runs embedded shell.lbin.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
EMBED="$ROOT/lab/nano-jit-rs/embed/shell-script.lbin"
SRC="$ROOT/lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-noarg-smoke=fail no_binary"; exit 1; }
[ -f "$EMBED" ] || { echo "nano-jit-rs-shell-noarg-smoke=fail no_embed"; exit 1; }

TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-shell-noarg-smoke"
mkdir -p "$TMP"
FRESH="$TMP/shell-script-fresh.lbin"
"$RS" compile "$SRC" "$FRESH" >/dev/null
embed_hash=$("$RS" hash "$EMBED" | tr -d '\n')
fresh_hash=$("$RS" hash "$FRESH" | tr -d '\n')
[ "$embed_hash" = "$fresh_hash" ] || {
  echo "nano-jit-rs-shell-noarg-smoke=fail embed_hash embed=$embed_hash fresh=$fresh_hash"
  exit 1
}

log=$("$RS" 2>&1) || true
echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
  echo "nano-jit-rs-shell-noarg-smoke=fail mode"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-script-step1' || {
  echo "nano-jit-rs-shell-noarg-smoke=fail step1"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'ret=0' || {
  echo "nano-jit-rs-shell-noarg-smoke=fail ret"
  echo "$log"
  exit 1
}

X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
ARM="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64"
if [ -f "$ARM" ]; then
  BARE="$TMP/nanolisp-noarg.ape"
  "$RS" pack-ape-bare "$BARE" "$X86" "$ARM" >/dev/null
  log=$("$RS" run-ape-expect-exit "$BARE" 0 2>&1) || true
  echo "$log" | grep -q 'run-ape-expect-exit.ok=1' || {
    echo "nano-jit-rs-shell-noarg-smoke=fail ape_exit"
    echo "$log"
    exit 1
  }
fi

echo "nano-jit-rs-shell-noarg-smoke=ok embed.hash=$embed_hash"
