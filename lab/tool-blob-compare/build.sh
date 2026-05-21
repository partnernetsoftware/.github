#!/usr/bin/env bash
set -euo pipefail
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../_nano_common.sh
source "$TOOL_DIR/../_nano_common.sh"
RUNNER="$(nano_runner)"
SRC="$TOOL_DIR/src/blob-compare.lisp"
A="$TOOL_DIR/.build/a.lbin"
B="$TOOL_DIR/.build/b.lbin"
mkdir -p "$TOOL_DIR/.build"
"$RUNNER" compile "$SRC" "$A"
"$RUNNER" compile "$SRC" "$B"
"$RUNNER" compare "$A" "$B"
"$RUNNER" hash "$A"
"$RUNNER" run "$A"
echo "ok: deterministic blob $A"
