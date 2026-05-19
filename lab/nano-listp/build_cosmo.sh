#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"

discover_cosmo_bin() {
  if [ -n "${COSMO_BIN:-}" ]; then
    printf '%s\n' "$COSMO_BIN"
    return
  fi

  for tool in x86_64-unknown-cosmo-cc cosmocc apelink; do
    if command -v "$tool" >/dev/null 2>&1; then
      dirname "$(command -v "$tool")"
      return
    fi
  done

  for dir in \
    "$ROOT_DIR/third_party/cosmocc/bin" \
    /opt/cosmocc/bin \
    /opt/cosmo/bin \
    /usr/local/cosmocc/bin \
    /usr/local/cosmo/bin; do
    if [ -d "$dir" ]; then
      printf '%s\n' "$dir"
      return
    fi
  done

  printf '%s\n' "$ROOT_DIR/third_party/cosmocc/bin"
}

COSMO_BIN="$(discover_cosmo_bin)"
X86_CC="$COSMO_BIN/x86_64-unknown-cosmo-cc"
ARM_CC="$COSMO_BIN/aarch64-unknown-cosmo-cc"
APELINK="$COSMO_BIN/apelink"
BUILD_DIR="$LAB_DIR/.build"
NANO_C="$ROOT_DIR/lab/lispjit-ir/lispjit.c"

mkdir -p "$BUILD_DIR"

if [ ! -x "$X86_CC" ] || [ ! -x "$ARM_CC" ] || [ ! -x "$APELINK" ]; then
  echo "cosmocc=missing"
  echo "searched=$COSMO_BIN"
  echo "need=x86_64-unknown-cosmo-cc,aarch64-unknown-cosmo-cc,apelink"
  echo "hint=set COSMO_BIN=/path/to/cosmocc/bin"
  exit 2
fi

COMMON=(-DNANO_LISTP -Os "$NANO_C")

echo "[nano-listp] build x86_64"
"$X86_CC" "${COMMON[@]}" -o "$BUILD_DIR/nano-listp.x86_64"

echo "[nano-listp] build aarch64"
"$ARM_CC" "${COMMON[@]}" -o "$BUILD_DIR/nano-listp.aarch64"

echo "[nano-listp] link APE fat binary"
"$APELINK" \
  -s \
  -l "$COSMO_BIN/ape-x86_64.elf" \
  -l "$COSMO_BIN/ape-aarch64.elf" \
  -M "$COSMO_BIN/ape-m1.c" \
  -o "$BUILD_DIR/nano-listp.com" \
  "$BUILD_DIR/nano-listp.x86_64" \
  "$BUILD_DIR/nano-listp.aarch64"

ls -l "$BUILD_DIR"/nano-listp.*
