#!/usr/bin/env bash
# P0: promote factory C COM → release/nano-lisp.com + manifest pin (cosmocc required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
LAB="$ROOT/lab/nano-lisp-jit"
RELEASE_COM="$LAB/release/nano-lisp.com"
cd "$ROOT"

discover_cosmo_bin() {
  if [ -n "${COSMO_BIN:-}" ]; then
    printf '%s\n' "$COSMO_BIN"
    return
  fi
  for tool in x86_64-unknown-cosmo-cc cosmocc; do
    if command -v "$tool" >/dev/null 2>&1; then
      dirname "$(command -v "$tool")"
      return
    fi
  done
  for dir in \
    "$ROOT/third_party/cosmocc/bin" \
    /opt/cosmocc/bin \
    /opt/cosmo/bin \
    /usr/local/cosmocc/bin \
    /usr/local/cosmo/bin; do
    if [ -x "$dir/x86_64-unknown-cosmo-cc" ]; then
      printf '%s\n' "$dir"
      return
    fi
  done
  printf '%s\n' "$ROOT/third_party/cosmocc/bin"
}

cosmocc_usable() {
  local dir="$1"
  [ -x "$dir/x86_64-unknown-cosmo-cc" ]
}

require_cosmocc() {
  local dir
  dir="$(discover_cosmo_bin)"
  if cosmocc_usable "$dir"; then
    echo "nano-jit-c-shell-release-promote=ok cosmocc dir=$dir"
    return 0
  fi
  echo "nano-jit-c-shell-release-promote=fail cosmocc_required dir=$dir"
  exit 1
}

echo "nano-jit-c-shell-release-promote=begin"

bash "$RETIRED/bootstrap-cosmocc.sh" || true
require_cosmocc

export NANO_C_SHELL_PROMOTE_BUILD=1
NANO_C_GATE_FACTORY=1 bash "$LAB/build_nano_jit.sh" || true

BUILD_COM="$LAB/.build/nano-jit/nano-jit.com"
if [ ! -x "$BUILD_COM" ]; then
  BUILD_COM="$LAB/.build/nano-jit/nano-jit.x86_64"
fi
[ -x "$BUILD_COM" ] || {
  echo "nano-jit-c-shell-release-promote=fail factory_no_artifact"
  exit 1
}

log=$("$BUILD_COM" 2>&1) || rc=$?
rc=${rc:-0}
echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
  echo "nano-jit-c-shell-release-promote=fail factory_noarg expected=embedded-lbin rc=$rc"
  echo "$log"
  exit 1
}
echo "nano-jit-c-shell-release-promote=ok factory_noarg artifact=$BUILD_COM"

mkdir -p "$(dirname "$RELEASE_COM")"
install -m 755 "$BUILD_COM" "$RELEASE_COM"

bash "$RETIRED/v45-manifest-pin.sh" "$RELEASE_COM"

probe_out=$(bash "$RETIRED/nanolisp-c-release-shell-probe.sh")
echo "$probe_out"
echo "$probe_out" | grep -q 'nanolisp.c-release-shell=embedded' || {
  echo "nano-jit-c-shell-release-promote=fail release_probe"
  exit 1
}

COM_BYTES=$(wc -c <"$RELEASE_COM" | tr -d ' ')
COM_HASH=$("$RELEASE_COM" file-hash "$RELEASE_COM" 2>/dev/null | tail -1 | tr -d '[:space:]')
echo "nano-jit-c-shell-release-promote=ok release_com bytes=$COM_BYTES fnv1a64=$COM_HASH"

bash "$RETIRED/nano-jit-c-gate.sh"
echo "nano-jit-c-shell-release-promote=ok gate=pass"
echo "nano-jit-c-shell-release-promote=done"
