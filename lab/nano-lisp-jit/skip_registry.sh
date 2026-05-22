# Central skip/host helpers for lab/nano-lisp-jit/run.sh and build_nano_jit.sh
# Sourced after log() is defined in run.sh. Uses ROOT_DIR for cosmocc_available.

host_is_linux_x86_64() {
  [ "$(uname -s)" = "Linux" ] && { [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ]; }
}

cosmocc_bin_usable() {
  local bin="${1:-}"
  [ -n "$bin" ] && [ -x "$bin/x86_64-unknown-cosmo-cc" ] && [ -x "$bin/aarch64-unknown-cosmo-cc" ]
}

cosmocc_available() {
  for tool in x86_64-unknown-cosmo-cc cosmocc; do
    if command -v "$tool" >/dev/null 2>&1; then
      local dir
      dir="$(dirname "$(command -v "$tool")")"
      if cosmocc_bin_usable "$dir"; then
        return 0
      fi
    fi
  done
  for dir in \
    "${ROOT_DIR}/third_party/cosmocc/bin" \
    /opt/cosmocc/bin \
    /opt/cosmo/bin \
    /usr/local/cosmocc/bin \
    /usr/local/cosmo/bin; do
    if cosmocc_bin_usable "$dir"; then
      return 0
    fi
  done
  return 1
}

skip_case() {
  local name="$1"
  local reason="$2"
  log ""
  log "## SKIP $name"
  log "$reason"
}
