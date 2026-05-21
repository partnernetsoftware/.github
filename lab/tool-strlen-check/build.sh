#!/usr/bin/env bash
set -euo pipefail
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../_nano_common.sh
source "$TOOL_DIR/../_nano_common.sh"
RUNNER="$(nano_runner)"
SRC="$TOOL_DIR/src/strlen-check.lisp"
BLOB="$TOOL_DIR/.build/strlen-check.lbin"
mkdir -p "$TOOL_DIR/.build"
"$RUNNER" compile "$SRC" "$BLOB"
"$RUNNER" run "$BLOB"
echo "ok: $BLOB"
