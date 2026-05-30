#!/usr/bin/env bash
# 将 lispjit-ir/*.c 真源迁至 archive/c/runner/ 并建 symlink（供 wave12 四轨并发调用）.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
IR="$ROOT/lab/lispjit-ir"
ARCH="$ROOT/lab/nano-lisp-jit/archive/runner"
mkdir -p "$ARCH"
track="${1:-}"
shift || true
if [ "$#" -eq 0 ]; then
  echo "usage: $0 <track-id> file.c ..." >&2
  exit 2
fi
n=0
for f in "$@"; do
  base="${f##*/}"
  src="$IR/$base"
  dst="$ARCH/$base"
  if [ -L "$src" ]; then
    echo "v45-archive-runner=skip_symlink track=$track file=$base"
    n=$((n + 1))
    continue
  fi
  if [ ! -f "$src" ]; then
    echo "v45-archive-runner=missing track=$track file=$base" >&2
    exit 1
  fi
  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
  fi
  rm -f "$src"
  ln -sf "../nano-lisp-jit/archive/c/runner/$base" "$src"
  echo "v45-archive-runner=ok track=$track file=$base"
  n=$((n + 1))
done
echo "v45-archive-runner=done track=$track count=$n"
