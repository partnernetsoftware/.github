#!/usr/bin/env bash
# Wave105: factory lisp-only regenesis path — plan 驱动 promote · C 种子仍靠 build_nano_jit.sh
set -euo pipefail
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"
BUILD_COM="$LAB_DIR/.build/nano-jit/nano-jit.com"
RELEASE_COM="$LAB_DIR/release/nano-lisp.com"
COM="${NANO_JIT:-}"
if [ -z "$COM" ]; then
  [ -x "$BUILD_COM" ] && COM="$BUILD_COM" || COM="$RELEASE_COM"
fi
if [ ! -x "$COM" ]; then
  echo "factory.lisp_only.path=fail reason=no_com"
  exit 1
fi
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_LISPJIT_FROM_LISP -u NANO_REGENESIS)
cd "$ROOT_DIR"
echo "factory.lisp_only.runner=$COM"
echo "factory.lisp_only.seed_note=build_nano_jit.sh still compiles archive/c/runner/lispjit.c for initial COM"
"${GEN[@]}" "$COM" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-factory-build-lisp-only-regenesis.lisp
OUT="$LAB_DIR/.build/v45-w105-factory-lo.com"
if [ ! -f "$OUT" ]; then
  echo "factory.lisp_only.path=fail reason=no_output_com"
  exit 1
fi
INSPECT=$("$COM" inspect-ape "$OUT" 2>&1 || true)
printf '%s\n' "$INSPECT"
printf '%s\n' "$INSPECT" | grep -q 'inspect-ape.ok=1'
echo "factory.lisp_only.output=$OUT"
echo "factory.lisp_only.path=ok"
