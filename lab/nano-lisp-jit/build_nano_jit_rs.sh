#!/usr/bin/env bash
# Build nanolisp (Rust) for host + optional aarch64 cross-target.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RS_DIR="$ROOT/lab/nano-jit-rs"
OUT_DIR="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs"
mkdir -p "$OUT_DIR"

echo "nanolisp.build=begin"
(cd "$RS_DIR" && cargo build --release)
(install -m 755 "$RS_DIR/target/release/nanolisp" "$OUT_DIR/nanolisp")
# Refresh embedded shell.lbin when source changes (Phase 3 no-arg dispatch).
EMBED_SRC="$ROOT/lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
EMBED_BIN="$RS_DIR/embed/shell-script.lbin"
if [ -f "$EMBED_BIN" ] && [ -f "$EMBED_SRC" ]; then
  if [ "$EMBED_SRC" -nt "$EMBED_BIN" ]; then
    "$OUT_DIR/nanolisp" compile "$EMBED_SRC" "$EMBED_BIN" >/dev/null
    echo "nanolisp.embed=refresh shell-script.lbin"
    (cd "$RS_DIR" && cargo build --release)
    install -m 755 "$RS_DIR/target/release/nanolisp" "$OUT_DIR/nanolisp"
  fi
fi
ln -sf nanolisp "$OUT_DIR/nano-jit"
"$OUT_DIR/nanolisp" version

AARCH64_OK=0
if ! rustup target list --installed | grep -q '^aarch64-unknown-linux-gnu$'; then
  if command -v aarch64-linux-gnu-gcc >/dev/null 2>&1; then
    rustup target add aarch64-unknown-linux-gnu 2>/dev/null || true
  fi
fi
if rustup target list --installed | grep -q '^aarch64-unknown-linux-gnu$'; then
  if command -v aarch64-linux-gnu-gcc >/dev/null 2>&1; then
    if (cd "$RS_DIR" && cargo build --release --target aarch64-unknown-linux-gnu); then
      install -m 755 "$RS_DIR/target/aarch64-unknown-linux-gnu/release/nanolisp" \
        "$OUT_DIR/nanolisp.aarch64"
      ln -sf nanolisp.aarch64 "$OUT_DIR/nano-jit.aarch64"
      echo "nanolisp.aarch64=ok"
      AARCH64_OK=1
    fi
  fi
fi
if [ "$AARCH64_OK" -eq 0 ]; then
  echo "nanolisp.aarch64=skip no_target_or_linker"
fi

echo "nanolisp.output=$OUT_DIR/nanolisp"
echo "nanolisp.legacy_symlink=$OUT_DIR/nano-jit"
echo "nanolisp.build=ok"
