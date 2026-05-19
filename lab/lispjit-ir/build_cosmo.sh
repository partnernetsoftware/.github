#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"
COSMO_BIN="${COSMO_BIN:-$ROOT_DIR/third_party/cosmocc/bin}"
X86_CC="$COSMO_BIN/x86_64-unknown-cosmo-cc"
ARM_CC="$COSMO_BIN/aarch64-unknown-cosmo-cc"
APELINK="$COSMO_BIN/apelink"
BUILD_DIR="$LAB_DIR/.build"

mkdir -p "$BUILD_DIR"

if [ ! -x "$X86_CC" ] || [ ! -x "$ARM_CC" ] || [ ! -x "$APELINK" ]; then
  echo "cosmocc=missing"
  echo "expected=$COSMO_BIN"
  echo "need=x86_64-unknown-cosmo-cc,aarch64-unknown-cosmo-cc,apelink"
  exit 2
fi

COMMON=(-Os -s "$LAB_DIR/lispjit.c")

echo "[lispjit] build x86_64"
"$X86_CC" "${COMMON[@]}" -o "$BUILD_DIR/lispjit.x86_64"

echo "[lispjit] build aarch64"
"$ARM_CC" "${COMMON[@]}" -o "$BUILD_DIR/lispjit.aarch64"

echo "[lispjit] link APE fat binary"
"$APELINK" \
  -s \
  -l "$COSMO_BIN/ape-x86_64.elf" \
  -l "$COSMO_BIN/ape-aarch64.elf" \
  -M "$COSMO_BIN/ape-m1.c" \
  -o "$BUILD_DIR/lispjit.com" \
  "$BUILD_DIR/lispjit.x86_64" \
  "$BUILD_DIR/lispjit.aarch64"

ls -l "$BUILD_DIR"/lispjit.*
