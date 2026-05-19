#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"
BUILD_DIR="$LAB_DIR/.build"
PROBE_C="$LAB_DIR/ffi_probe.c"
BUDGET_C="$LAB_DIR/byte_budget.c"
RESULTS="$BUILD_DIR/results.txt"

mkdir -p "$BUILD_DIR"
: > "$RESULTS"

log() {
  printf '%s\n' "$*" | tee -a "$RESULTS"
}

bytes_of() {
  if [ -f "$1" ]; then
    wc -c < "$1" | tr -d ' '
  else
    printf 'missing'
  fi
}

describe_file() {
  if [ -f "$1" ]; then
    file "$1" | tee -a "$RESULTS"
    log "size.bytes=$(bytes_of "$1")"
  else
    log "file.missing=$1"
  fi
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

log "# cross-arch ffi executable probe"
log "host.uname=$(uname -srm)"
log "probe.source.bytes=$(bytes_of "$PROBE_C")"
log "budget.source.bytes=$(bytes_of "$BUDGET_C")"

if command -v cc >/dev/null 2>&1; then
  NATIVE_BIN="$BUILD_DIR/ffi_probe_native"
  run_case "native-cc-build" cc -Os -s "$PROBE_C" -ldl -lm -o "$NATIVE_BIN"
  describe_file "$NATIVE_BIN"
  run_case "native-cc-run" "$NATIVE_BIN"

  BUDGET_BIN="$BUILD_DIR/byte_budget_native"
  run_case "byte-budget-native-build" cc -Os -s "$BUDGET_C" -ldl -o "$BUDGET_BIN"
  describe_file "$BUDGET_BIN"
  run_case "byte-budget-native-run" "$BUDGET_BIN"
else
  log ""
  log "## native-cc"
  log "skip: cc not found"
fi

TCCX="$ROOT_DIR/third_party/tccx.sh"
if [ -x "$TCCX" ]; then
  TCC_BIN="$BUILD_DIR/ffi_probe_tcc"
  if run_case "bundled-tcc-build" "$TCCX" "$PROBE_C" -ldl -lm -o "$TCC_BIN"; then
    describe_file "$TCC_BIN"
    run_case "bundled-tcc-run" "$TCC_BIN"
  else
    log "bundled-tcc-link=fail"
    log "bundled-tcc-note=missing CRT objects in this checkout; trying compile-only"
    TCC_OBJ="$BUILD_DIR/ffi_probe_tcc.o"
    run_case "bundled-tcc-compile-only" "$TCCX" -c "$PROBE_C" -o "$TCC_OBJ"
    describe_file "$TCC_OBJ"
  fi
else
  log ""
  log "## bundled-tcc"
  log "skip: $TCCX not executable"
fi

COSMORUN="$ROOT_DIR/cosmorun/cosmorun.exe"
if [ -x "$COSMORUN" ]; then
  log ""
  log "## cosmorun-runtime"
  describe_file "$COSMORUN"
  run_case "cosmorun-run-source" "$COSMORUN" "$PROBE_C"
else
  log ""
  log "## cosmorun"
  log "skip: $COSMORUN not executable"
fi

log ""
log "results.file=$RESULTS"
