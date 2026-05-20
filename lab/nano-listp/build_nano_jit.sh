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

bytes_of() {
  wc -c < "$1" | tr -d ' '
}

sha256_of() {
  sha256sum "$1" | awk '{print $1}'
}

run_case() {
  local name="$1"
  shift
  printf '\n## %s\n' "$name" | tee -a "$REPORT"
  "$@" 2>&1 | tee -a "$REPORT"
  local status="${PIPESTATUS[0]}"
  printf 'exit.status=%s\n' "$status" | tee -a "$REPORT"
  return "$status"
}

COSMO_BIN="$(discover_cosmo_bin)"
X86_CC="$COSMO_BIN/x86_64-unknown-cosmo-cc"
ARM_CC="$COSMO_BIN/aarch64-unknown-cosmo-cc"
BUILD_DIR="$LAB_DIR/.build/nano-jit"
NANO_C="$ROOT_DIR/lab/lispjit-ir/lispjit.c"
SMOKE_SRC="$LAB_DIR/samples/libc-smoke.lisp"
SMOKE_BLOB="$BUILD_DIR/libc-smoke.lbin"
SMOKE_APP="$BUILD_DIR/libc-smoke-app.com"
RESOLVE_SRC="$BUILD_DIR/libc-resolve.lisp"
RESOLVE_BLOB="$BUILD_DIR/libc-resolve.lbin"
REPORT="$BUILD_DIR/bootstrap-report.txt"

mkdir -p "$BUILD_DIR"
: > "$REPORT"

if [ ! -x "$X86_CC" ] || [ ! -x "$ARM_CC" ]; then
  echo "cosmocc=missing"
  echo "searched=$COSMO_BIN"
  echo "need=x86_64-unknown-cosmo-cc,aarch64-unknown-cosmo-cc"
  exit 2
fi

COMMON=(
  -DNANO_LISTP
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

{
  echo "# nano-jit bootstrap"
  echo "stage=0"
  echo "goal=self-pack-multi-arch-com"
  echo "cosmocc.role=temporary-slice-compiler"
  echo "apelink.role=not-used"
} | tee -a "$REPORT"

run_case "build-x86_64-slice" "$X86_CC" "${COMMON[@]}" -o "$BUILD_DIR/nano-jit.x86_64"
run_case "build-aarch64-slice" "$ARM_CC" "${COMMON[@]}" -o "$BUILD_DIR/nano-jit.aarch64"

case "$(uname -m)" in
  x86_64|amd64) PACKER="$BUILD_DIR/nano-jit.x86_64" ;;
  aarch64|arm64) PACKER="$BUILD_DIR/nano-jit.aarch64" ;;
  *)
    echo "host.arch=unsupported_for_self_pack" | tee -a "$REPORT"
    exit 2
    ;;
esac

run_case "self-pack-nano-jit-com" "$PACKER" pack-ape \
  "$BUILD_DIR/nano-jit.com" \
  "$BUILD_DIR/nano-jit.x86_64" \
  "$BUILD_DIR/nano-jit.aarch64"

{
  echo "nano-jit.com.bytes=$(bytes_of "$BUILD_DIR/nano-jit.com")"
  echo "nano-jit.com.sha256=$(sha256_of "$BUILD_DIR/nano-jit.com")"
  echo "nano-jit.x86_64.bytes=$(bytes_of "$BUILD_DIR/nano-jit.x86_64")"
  echo "nano-jit.x86_64.sha256=$(sha256_of "$BUILD_DIR/nano-jit.x86_64")"
  echo "nano-jit.aarch64.bytes=$(bytes_of "$BUILD_DIR/nano-jit.aarch64")"
  echo "nano-jit.aarch64.sha256=$(sha256_of "$BUILD_DIR/nano-jit.aarch64")"
} | tee -a "$REPORT"

run_case "nano-jit-compile-smoke" "$BUILD_DIR/nano-jit.com" compile "$SMOKE_SRC" "$SMOKE_BLOB"
run_case "nano-jit-run-smoke" "$BUILD_DIR/nano-jit.com" run "$SMOKE_BLOB"
run_case "nano-jit-pack-smoke-app" "$BUILD_DIR/nano-jit.com" pack-app \
  "$SMOKE_APP" \
  "$BUILD_DIR/nano-jit.x86_64" \
  "$BUILD_DIR/nano-jit.aarch64" \
  "$SMOKE_BLOB"
{
  echo "libc-smoke-app.com.bytes=$(bytes_of "$SMOKE_APP")"
  echo "libc-smoke-app.com.sha256=$(sha256_of "$SMOKE_APP")"
} | tee -a "$REPORT"
run_case "nano-jit-run-smoke-app" "$SMOKE_APP"
run_case "generate-libc-resolve-manifest" python3 "$LAB_DIR/gen_libc_resolve.py" "$RESOLVE_SRC"
run_case "nano-jit-compile-libc-resolve" "$BUILD_DIR/nano-jit.com" compile "$RESOLVE_SRC" "$RESOLVE_BLOB"
run_case "nano-jit-resolve-libc" "$BUILD_DIR/nano-jit.com" resolve --quiet "$RESOLVE_BLOB"

echo "bootstrap.report=$REPORT" | tee -a "$REPORT"
ls -l "$BUILD_DIR"/nano-jit.*
