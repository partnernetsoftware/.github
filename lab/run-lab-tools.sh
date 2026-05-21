#!/usr/bin/env bash
# Run all lab consumer tools that depend on nano-lisp-jit.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
tools=(
  tool-exit42
  tool-strlen-check
  tool-blob-compare
  tool-resolve-check
)
for t in "${tools[@]}"; do
  echo "== $t =="
  bash "$ROOT/$t/build.sh"
done
echo "lab tools: all ok"
