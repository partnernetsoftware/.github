#!/usr/bin/env bash
# Build nano-jit-rs for host + optional aarch64 cross-target.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RS_DIR="$ROOT/lab/nano-jit-rs"
OUT_DIR="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs"
mkdir -p "$OUT_DIR"

echo "nano-jit-rs.build=begin"
(cd "$RS_DIR" && cargo build --release)
install -m 755 "$RS_DIR/target/release/nano-jit" "$OUT_DIR/nano-jit"
"$OUT_DIR/nano-jit" version

if rustup target list --installed | grep -q '^aarch64-unknown-linux-gnu$'; then
  (cd "$RS_DIR" && cargo build --release --target aarch64-unknown-linux-gnu)
  install -m 755 "$RS_DIR/target/aarch64-unknown-linux-gnu/release/nano-jit" \
    "$OUT_DIR/nano-jit.aarch64"
  echo "nano-jit-rs.aarch64=ok"
else
  echo "nano-jit-rs.aarch64=skip no_target"
fi

echo "nano-jit-rs.output=$OUT_DIR/nano-jit"
echo "nano-jit-rs.build=ok"
