#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"
BUILD_DIR="$LAB_DIR/.build"
SRC="$LAB_DIR/samples/strlen.lisp"
SMOKE_SRC="$LAB_DIR/samples/libc-smoke.lisp"
BLOB="$BUILD_DIR/strlen.lbin"
SMOKE_BLOB="$BUILD_DIR/libc-smoke.lbin"
LIBC_SRC="$BUILD_DIR/libc-resolve.lisp"
LIBC_BLOB="$BUILD_DIR/libc-resolve.lbin"
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
log "smoke.source.path=$SMOKE_SRC"
log "smoke.source.bytes=$(bytes_of "$SMOKE_SRC")"

run_case "build-native-nano-listp" cc -DNANO_LISTP -Os -s "$NANO_C" -ldl -o "$RUNNER"
log "native.runtime.bytes=$(bytes_of "$RUNNER")"

run_case "compile-lisp-to-lbin" "$RUNNER" compile "$SRC" "$BLOB"
log "blob.bytes=$(bytes_of "$BLOB")"

run_case "dump-lbin" "$RUNNER" dump "$BLOB"

run_case "execute-lbin-via-jit" "$RUNNER" run "$BLOB"

run_case "compile-libc-smoke-lbin" "$RUNNER" compile "$SMOKE_SRC" "$SMOKE_BLOB"
log "smoke.blob.bytes=$(bytes_of "$SMOKE_BLOB")"

run_case "dump-libc-smoke-lbin" "$RUNNER" dump "$SMOKE_BLOB"

run_case "execute-libc-smoke-lbin" "$RUNNER" run "$SMOKE_BLOB"

if command -v nm >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  run_case "generate-libc-resolve-manifest" python3 "$LAB_DIR/gen_libc_resolve.py" "$LIBC_SRC"
  run_case "compile-libc-resolve-lbin" "$RUNNER" compile "$LIBC_SRC" "$LIBC_BLOB"
  log "libc.resolve.blob.bytes=$(bytes_of "$LIBC_BLOB")"
  run_case "resolve-libc-imports" "$RUNNER" resolve --quiet "$LIBC_BLOB"
else
  log ""
  log "## resolve-libc-imports"
  log "skip: need python3 and nm"
fi

log ""
log "results.file=$RESULTS"
