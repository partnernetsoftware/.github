#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$LAB_DIR/.build"
SRC="$LAB_DIR/samples/strlen.lispir"
BLOB="$BUILD_DIR/strlen.ljir"
RUNNER="$BUILD_DIR/irjit"
RESULTS="$BUILD_DIR/results.txt"

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

log "# LispJIT portable IR blob prototype"
log "source.bytes=$(bytes_of "$SRC")"

run_case "compile-portable-blob" "$LAB_DIR/compile_blob.py" "$SRC" "$BLOB"
log "blob.bytes=$(bytes_of "$BLOB")"

run_case "build-irjit-runtime" cc -Os -s "$LAB_DIR/irjit.c" -ldl -o "$RUNNER"
log "runtime.bytes=$(bytes_of "$RUNNER")"

run_case "execute-blob-via-jit" "$RUNNER" "$BLOB"
log ""
log "results.file=$RESULTS"
