#!/usr/bin/env bash
# nanolisp nano-cc build-slice smoke — build_slice_use_nano_cc path (zero host cc).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
HELLO_SRC="$ROOT/lab/nano-lisp-jit/archive/fixtures/nano-cc-hello.c"
ADD_SRC="$ROOT/lab/nano-lisp-jit/archive/fixtures/nano-cc-add.c"
BUILD_SLICE_SRC="$ROOT/lab/nano-lisp-jit/archive/fixtures/nano-cc-build-slice.c"
HELLO_ELF="$ROOT/lab/nano-lisp-jit/.build/rs-nano-cc-hello.elf"
ADD_ELF="$ROOT/lab/nano-lisp-jit/.build/rs-nano-cc-add.elf"
BUILD_SLICE_ELF="$ROOT/lab/nano-lisp-jit/.build/rs-nano-cc-build-slice.elf"
PLAN_HELLO="$ROOT/lab/nano-lisp-jit/retired/archive-c/factory/legacy/bootstrap-v35-nano-cc-hello.lisp"
PLAN_BUILD_SLICE="$ROOT/lab/nano-lisp-jit/retired/archive-c/factory/legacy/bootstrap-v35-build-slice.lisp"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-nano-cc-build-slice-smoke=fail no_binary"; exit 1; }

run_build_slice() {
  local label="$1" src="$2" out="$3" exit_code="$4" need_codegen="${5:-0}"
  local plan="$ROOT/lab/nano-lisp-jit/.build/rs-nano-cc-${label}.lisp"
  rm -f "$out"
  unset NANO_BUILD_SLICE_CODEGEN NANO_V35_CODEGEN_DEFAULT
  if [ "$need_codegen" = "1" ]; then
    export NANO_BUILD_SLICE_CODEGEN=1
  fi
  printf '(bootstrap (build-slice "%s" "%s" "x86_64"))\n' "$src" "$out" >"$plan"
  local log
  log=$("$RS" run-bootstrap-plan "$plan" 2>&1) || true
  echo "$log" | grep -q 'build-slice.compiler=nano-cc' || {
    echo "nano-jit-rs-nano-cc-build-slice-smoke=fail ${label}_compiler"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q 'build-slice.role=lisp-codegen' || {
    echo "nano-jit-rs-nano-cc-build-slice-smoke=fail ${label}_role"
    exit 1
  }
  [ -f "$out" ] || {
    echo "nano-jit-rs-nano-cc-build-slice-smoke=fail ${label}_missing_elf"
    exit 1
  }
  "$RS" run-expect-exit "$out" "$exit_code" >/dev/null || {
    echo "nano-jit-rs-nano-cc-build-slice-smoke=fail ${label}_run"
    exit 1
  }
  echo "nano-jit-rs-nano-cc-build-slice-smoke=ok ${label}"
}

run_build_slice hello "$HELLO_SRC" "$HELLO_ELF" 42 0
run_build_slice add "$ADD_SRC" "$ADD_ELF" 42 0
run_build_slice build_slice "$BUILD_SLICE_SRC" "$BUILD_SLICE_ELF" 43 1

if [ -f "$PLAN_HELLO" ]; then
  hello_plan_elf="$ROOT/lab/nano-lisp-jit/.build/bootstrap-v35-nano-cc-hello.elf"
  rm -f "$hello_plan_elf"
  log=$("$RS" run-bootstrap-plan "$PLAN_HELLO" 2>&1) || true
  echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
    echo "nano-jit-rs-nano-cc-build-slice-smoke=fail plan_hello"
    echo "$log"
    exit 1
  }
  "$RS" run-expect-exit "$hello_plan_elf" 42 >/dev/null
fi

if [ -x "$COM" ] && [ -f "$PLAN_BUILD_SLICE" ]; then
  export NANO_BUILD_SLICE_CODEGEN=1
  rm -f "$BUILD_SLICE_ELF"
  rs_log=$("$RS" run-bootstrap-plan "$PLAN_BUILD_SLICE" 2>&1) || true
  com_log=$("$COM" run-bootstrap-plan "$PLAN_BUILD_SLICE" 2>&1) || true
  echo "$rs_log" | grep -q 'build-slice.compiler=nano-cc' || {
    echo "nano-jit-rs-nano-cc-build-slice-smoke=fail com_parity_rs"
    exit 1
  }
  echo "$com_log" | grep -q 'build-slice.compiler=nano-cc' || {
    echo "nano-jit-rs-nano-cc-build-slice-smoke=fail com_parity_com"
    exit 1
  }
fi

echo "nano-jit-rs-nano-cc-build-slice-smoke=ok"
