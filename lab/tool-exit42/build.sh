#!/usr/bin/env bash
set -euo pipefail
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../_nano_common.sh
source "$TOOL_DIR/../_nano_common.sh"
ROOT="$(repo_root)"
RUNNER="$(nano_runner)"
SRC="$TOOL_DIR/src/exit42.lisp"
OUT="$TOOL_DIR/.build/exit42.elf"
mkdir -p "$TOOL_DIR/.build"
"$RUNNER" compile-elf64-code "$SRC" "$OUT"
"$RUNNER" run-expect-exit "$OUT" 42
echo "ok: $OUT exits 42"
