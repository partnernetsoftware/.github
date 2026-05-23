#!/usr/bin/env bash
# Fast v4 codegen verify for squad `verify --quick` (~15–30s). Full regression: run.sh (optional in catalog).
set -euo pipefail
LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$LAB_DIR/../.." && pwd)"
cd "$ROOT"
BUILD="$LAB_DIR/.build"
RUNNER="$BUILD/nano-lisp-jit"
NANO_C="$ROOT/lab/lispjit-ir/lispjit.c"
mkdir -p "$BUILD"
cc -DNANO_LISP_JIT -Os -s "$NANO_C" -ldl -o "$RUNNER"
run_plan() {
  local plan="$1"
  local needle="$2"
  local out
  out=$("$RUNNER" run-bootstrap-plan "$plan" 2>&1) || { printf "%s\n" "$out"; return 1; }
  printf "%s\n" "$out" | grep -q "$needle"
}
run_plan "$LAB_DIR/samples/bootstrap-v4-slice10-add15.lisp" "aarch64.emit.ir_surface=manifest-v1"
run_plan "$LAB_DIR/samples/bootstrap-v4-slice11-add16.lisp" "aarch64.emit.encode="
# slice11 accepts manifest-v1 or lisp-v1 (S13+ prefers lisp when IR file present)
run_plan "$LAB_DIR/samples/bootstrap-v4-slice12-add17.lisp" "aarch64.emit.ir_source=plan-lisp-v1"
run_plan "$LAB_DIR/samples/bootstrap-v4-slice12-add17.lisp" "aarch64.add=10+7"
run_plan "$LAB_DIR/samples/bootstrap-v4-slice13-add18.lisp" "aarch64.emit.encode=lisp-v1"
run_plan "$LAB_DIR/samples/bootstrap-v4-slice13-add18.lisp" "aarch64.add=11+7"
test -f "$LAB_DIR/samples/v4-aarch64-add-exit-ops.lisp"
test -f "$LAB_DIR/samples/v4-aarch64-add-exit-ops.manifest"
grep -q "^encode " "$LAB_DIR/samples/v4-aarch64-add-exit-ops.manifest"
echo "verify-v4-fast.ok=1"
