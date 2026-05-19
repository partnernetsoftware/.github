#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"
BUILD_DIR="$LAB_DIR/.build"
SRC="$LAB_DIR/samples/strlen.lisp"
BLOB="$BUILD_DIR/strlen.lbin"
RUNNER="$BUILD_DIR/nano-listp"
RESULTS="$BUILD_DIR/results.txt"
NANO_C="$ROOT_DIR/lab/lispjit-ir/lispjit.c"

mkdir -p "$BUILD_DIR"
: > "$RESULTS"

log() {
  printf '%s\n' "$*" | tee -a "$RESULTS"
}

bytes_of() {
  wc -c < "$1" | tr -d ' '
}

run_case() {
  local name="$1"
  shift
  log ""
  log "## $name"
  "$@" 2>&1 | tee -a "$RESULTS"
  local status="${PIPESTATUS[0]}"
  log "exit.status=$status"
  return "$status"
}

log "# nano-listp .lisp to .lbin probe"
log "source.path=$SRC"
log "source.bytes=$(bytes_of "$SRC")"

run_case "build-native-nano-listp" cc -DNANO_LISTP -Os -s "$NANO_C" -ldl -o "$RUNNER"
log "native.runtime.bytes=$(bytes_of "$RUNNER")"

run_case "compile-lisp-to-lbin" "$RUNNER" compile "$SRC" "$BLOB"
log "blob.bytes=$(bytes_of "$BLOB")"

run_case "dump-lbin" "$RUNNER" dump "$BLOB"

run_case "execute-lbin-via-jit" "$RUNNER" run "$BLOB"

log ""
log "results.file=$RESULTS"
