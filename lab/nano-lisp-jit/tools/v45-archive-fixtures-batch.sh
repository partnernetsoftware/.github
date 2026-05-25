#!/usr/bin/env bash
# 发行面 samples/*.c fixtures 出仓 → archive/fixtures/ + symlink（并行友好）.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
SAMPLES="$ROOT/lab/nano-lisp-jit/samples"
ARCH="$ROOT/lab/nano-lisp-jit/archive/fixtures/nano-cc"
mkdir -p "$ARCH"
track="${1:-X}"
shift || true
for f in "$@"; do
  base="${f##*/}"
  src="$SAMPLES/$base"
  dst="$ARCH/$base"
  if [ -L "$src" ]; then
    echo "v45-archive-fixtures=skip_symlink track=$track file=$base"
    continue
  fi
  if [ ! -f "$src" ]; then
    echo "v45-archive-fixtures=missing track=$track file=$base" >&2
    exit 1
  fi
  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
  fi
  rm -f "$src"
  ln -sf "../archive/fixtures/nano-cc/$base" "$src"
  echo "v45-archive-fixtures=ok track=$track file=$base"
done
echo "v45-archive-fixtures=done track=$track"
