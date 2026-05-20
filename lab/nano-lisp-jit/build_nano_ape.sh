#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"

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
BUILD_DIR="$LAB_DIR/.build/nano-ape"
NANO_C="$ROOT_DIR/lab/lispjit-ir/lispjit.c"

mkdir -p "$BUILD_DIR"

if [ ! -x "$X86_CC" ] || [ ! -x "$ARM_CC" ]; then
  echo "cosmocc=missing"
  echo "searched=$COSMO_BIN"
  echo "need=x86_64-unknown-cosmo-cc,aarch64-unknown-cosmo-cc"
  exit 2
fi

COMMON=(
  -DNANO_LISP_JIT
  -Os
  -mtiny
  -ffunction-sections
  -fdata-sections
  -Wl,--gc-sections
  -fno-unwind-tables
  -fno-asynchronous-unwind-tables
  -fno-stack-protector
  -fno-ident
  -s
  "$NANO_C"
)

echo "[nano-ape] build stripped x86_64 slice"
"$X86_CC" "${COMMON[@]}" -o "$BUILD_DIR/nano-lisp-jit.x86_64"

echo "[nano-ape] build stripped aarch64 slice"
"$ARM_CC" "${COMMON[@]}" -o "$BUILD_DIR/nano-lisp-jit.aarch64"

case "$(uname -m)" in
  x86_64|amd64) PACKER="$BUILD_DIR/nano-lisp-jit.x86_64" ;;
  aarch64|arm64) PACKER="$BUILD_DIR/nano-lisp-jit.aarch64" ;;
  *)
    echo "host.arch=unsupported_for_self_pack"
    exit 2
    ;;
esac

echo "[nano-ape] pack without cosmocc apelink"
"$PACKER" pack-ape \
  "$BUILD_DIR/nano-lisp-jit.com" \
  "$BUILD_DIR/nano-lisp-jit.x86_64" \
  "$BUILD_DIR/nano-lisp-jit.aarch64"

ls -l "$BUILD_DIR"/nano-lisp-jit.*
