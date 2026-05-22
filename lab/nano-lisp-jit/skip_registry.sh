# Central skip helpers for lab/nano-lisp-jit/run.sh
# Sourced after log() is defined. Uses ROOT_DIR for cosmocc_available.

PASS_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0

run_case() {
  local name="$1"
  shift
  log ""
  log "## $name"
  set +e
  "$@" 2>&1 | tee -a "$RESULTS"
  local status="${PIPESTATUS[0]}"
  set -e
  log "exit.status=$status"
  if [ "$status" -eq 0 ]; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
  return 0
}

run_end_summary() {
  log ""
  log "# run summary"
  log "tests.pass=$PASS_COUNT"
  log "tests.skip=$SKIP_COUNT"
  log "tests.fail=$FAIL_COUNT"
}

host_is_linux_x86_64() {
  [ "$(uname -s)" = "Linux" ] && { [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ]; }
}

cosmocc_available() {
  for tool in x86_64-unknown-cosmo-cc cosmocc; do
    if command -v "$tool" >/dev/null 2>&1; then
      return 0
    fi
  done
  for dir in \
    "${ROOT_DIR}/third_party/cosmocc/bin" \
    /opt/cosmocc/bin \
    /opt/cosmo/bin; do
    if [ -x "$dir/x86_64-unknown-cosmo-cc" ] && [ -x "$dir/aarch64-unknown-cosmo-cc" ]; then
      return 0
    fi
  done
  return 1
}

skip_case() {
  local name="$1"
  local reason="$2"
  SKIP_COUNT=$((SKIP_COUNT + 1))
  log ""
  log "## SKIP $name"
  log "$reason"
}
