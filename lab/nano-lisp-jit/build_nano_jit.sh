#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"

# shellcheck source=skip_registry.sh
source "$LAB_DIR/skip_registry.sh"

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

NANO_SLICE_COMPILER="${NANO_SLICE_COMPILER:-cosmo}"

slice_tool() {
  if [ -f "$BUILD_DIR/nano-jit.com" ]; then
    printf '%s\n' "$BUILD_DIR/nano-jit.com"
  elif [ -x "$BUILD_DIR/nano-jit.x86_64" ]; then
    printf '%s\n' "$BUILD_DIR/nano-jit.x86_64"
  else
    return 1
  fi
}

bytes_of() {
  local tool
  tool="$(slice_tool)" || {
    stat -c%s "$1"
    return
  }
  "$tool" file-size "$1"
}

hash_of() {
  local tool
  tool="$(slice_tool)" || {
    printf '0\n'
    return
  }
  "$tool" file-hash "$1"
}

BUILD_PASS=0
BUILD_FAIL=0
BUILD_SKIP=0

run_case() {
  local name="$1"
  shift
  printf '\n## %s\n' "$name" | tee -a "$REPORT"
  set +e
  "$@" 2>&1 | tee -a "$REPORT"
  local status="${PIPESTATUS[0]}"
  set -e
  printf 'exit.status=%s\n' "$status" | tee -a "$REPORT"
  if [ "$status" -eq 0 ]; then
    BUILD_PASS=$((BUILD_PASS + 1))
  else
    BUILD_FAIL=$((BUILD_FAIL + 1))
  fi
  return "$status"
}

build_skip_case() {
  local name="$1"
  local reason="$2"
  BUILD_SKIP=$((BUILD_SKIP + 1))
  printf '\n## SKIP %s\n' "$name" | tee -a "$REPORT"
  printf '%s\n' "$reason" | tee -a "$REPORT"
}

build_end_summary() {
  printf '\n# build summary\n' | tee -a "$REPORT"
  printf 'build.pass=%s\n' "$BUILD_PASS" | tee -a "$REPORT"
  printf 'build.skip=%s\n' "$BUILD_SKIP" | tee -a "$REPORT"
  printf 'build.fail=%s\n' "$BUILD_FAIL" | tee -a "$REPORT"
}

COSMO_BIN="$(discover_cosmo_bin)"
X86_CC="$COSMO_BIN/x86_64-unknown-cosmo-cc"
ARM_CC="$COSMO_BIN/aarch64-unknown-cosmo-cc"
BUILD_DIR="$LAB_DIR/.build/nano-jit"
GENESIS_DIR="$LAB_DIR/genesis"
GENESIS_X86="$GENESIS_DIR/nano-jit.x86_64"
GENESIS_AARCH64="$GENESIS_DIR/nano-jit.aarch64"
NANO_C="$ROOT_DIR/lab/lispjit-ir/lispjit.c"
STRLEN_SRC="$LAB_DIR/samples/strlen.lisp"
ARITH_SRC="$LAB_DIR/samples/arithmetic.lisp"
ARITH_BLOB="$BUILD_DIR/arithmetic.lbin"
ARITH_I64_SRC="$LAB_DIR/samples/arithmetic-i64.lisp"
ARITH_I64_BLOB="$BUILD_DIR/arithmetic-i64.lbin"
TYPED_SRC="$LAB_DIR/samples/typed-values.lisp"
TYPED_BLOB="$BUILD_DIR/typed-values.lbin"
PTR_SRC="$LAB_DIR/samples/ptr-values.lisp"
PTR_BLOB="$BUILD_DIR/ptr-values.lbin"
CONST_PTR_SRC="$LAB_DIR/samples/const-ptr-load-u8.lisp"
CONST_PTR_BLOB="$BUILD_DIR/const-ptr-load-u8.lbin"
CONST_PTR_DIRECT_EXE="$BUILD_DIR/const_ptr_load_u8_direct"
BOOTSTRAP_APE_NEG_SRC="$LAB_DIR/samples/bootstrap-ape-negative.lisp"
BOOTSTRAP_DATA_NEG_SRC="$LAB_DIR/samples/bootstrap-data-negative.lisp"
BOOTSTRAP_V25_NATIVE_SELFPACK="$LAB_DIR/samples/bootstrap-v25-native-selfpack.lisp"
BOOTSTRAP_V3_VM_MATRIX="$LAB_DIR/samples/bootstrap-v3-vm-selfpack-matrix.lisp"
BOOTSTRAP_V3_BUILD_SLICE="$LAB_DIR/samples/bootstrap-v3-build-slice.lisp"
BOOTSTRAP_V3_SELFHOST_GEN1="$LAB_DIR/samples/bootstrap-v3-selfhost-gen1.lisp"
BOOTSTRAP_V3_SELFHOST_GEN2="$LAB_DIR/samples/bootstrap-v3-selfhost-gen2.lisp"
BOOTSTRAP_V3_CODEGEN_SMOKE="$LAB_DIR/samples/bootstrap-v3-codegen-smoke.lisp"
BOOTSTRAP_V3_SELFHOST_GEN3="$LAB_DIR/samples/bootstrap-v3-selfhost-gen3.lisp"
SELFHOST_DIR="$BUILD_DIR/selfhost"
NANO_SELFHOST_THOROUGH="${NANO_SELFHOST_THOROUGH:-1}"
FUNC_PARAM_VM_I64_SRC="$LAB_DIR/samples/func-param-vm-i64.lisp"
RODATA_READONLY_SRC="$LAB_DIR/samples/rodata-readonly.lisp"
APE_FIXTURE_DIR="$LAB_DIR/.build"
DATA_GOOD_OBJ="$APE_FIXTURE_DIR/data-good.o"
DATA_BAD_RELOC_TYPE_OBJ="$APE_FIXTURE_DIR/data-bad-reloc-type.o"
DATA_BAD_RELOC_SYM_OBJ="$APE_FIXTURE_DIR/data-bad-reloc-sym.o"
DATA_BAD_SYMBOL_SHNDX_OBJ="$APE_FIXTURE_DIR/data-bad-symbol-shndx.o"
CTRL_SRC="$LAB_DIR/samples/control-flow.lisp"
CTRL_BLOB="$BUILD_DIR/control-flow.lbin"
MULTI_SRC="$LAB_DIR/samples/multi-func.lisp"
MULTI_CTRL_SRC="$LAB_DIR/samples/multi-func-control-flow.lisp"
MULTI_PTR_SRC="$LAB_DIR/samples/multi-func-ptr.lisp"
MULTI_BAD_SRC="$LAB_DIR/samples/multi-func-recursive-bad.lisp"
FUNC_PARAM_MISSING_PARAM_BAD_SRC="$LAB_DIR/samples/func-param-missing-param-bad.lisp"
FUNC_PARAM_CALL_NO_ARG_BAD_SRC="$LAB_DIR/samples/func-param-call-no-arg-bad.lisp"
TYPE_BAD_PTR_OP_SRC="$LAB_DIR/samples/type-error-ptr-op-bad.lisp"
TYPE_BAD_ADD_PTR_SRC="$LAB_DIR/samples/type-error-add-ptr-bad.lisp"
TYPE_BAD_SUB_PTR_SRC="$LAB_DIR/samples/type-error-sub-ptr-bad.lisp"
TYPE_BAD_PTR_TO_U64_SRC="$LAB_DIR/samples/type-error-ptr-to-u64-bad.lisp"
TYPE_BAD_U64_TO_PTR_SRC="$LAB_DIR/samples/type-error-u64-to-ptr-bad.lisp"
TYPE_BAD_LOAD_U8_SRC="$LAB_DIR/samples/type-error-load-u8-bad.lisp"
TYPE_BAD_LOAD_U16_SRC="$LAB_DIR/samples/type-error-load-u16-bad.lisp"
TYPE_BAD_LOAD_U32_SRC="$LAB_DIR/samples/type-error-load-u32-bad.lisp"
TYPE_BAD_STORE_U8_SRC="$LAB_DIR/samples/type-error-store-u8-bad.lisp"
TYPE_BAD_STORE_U8_RANGE_SRC="$LAB_DIR/samples/type-error-store-u8-range-bad.lisp"
TYPE_BAD_STORE_U16_SRC="$LAB_DIR/samples/type-error-store-u16-bad.lisp"
TYPE_BAD_STORE_U16_RANGE_SRC="$LAB_DIR/samples/type-error-store-u16-range-bad.lisp"
TYPE_BAD_STORE_U32_SRC="$LAB_DIR/samples/type-error-store-u32-bad.lisp"
TYPE_BAD_STORE_U32_RANGE_SRC="$LAB_DIR/samples/type-error-store-u32-range-bad.lisp"
TYPE_BAD_BRANCH_SRC="$LAB_DIR/samples/type-error-branch-bad.lisp"
TYPE_BAD_EXPECT_PTR_SRC="$LAB_DIR/samples/type-error-expect-ptr-bad.lisp"
BAD_ARITH_SRC="$LAB_DIR/samples/arithmetic-bad.lisp"
BAD_ARITH_BLOB="$BUILD_DIR/arithmetic-bad.lbin"
EXIT42="$BUILD_DIR/exit42.elf"
ARITH_EXIT="$BUILD_DIR/arithmetic-aot.elf"
ARITH_CODE="$BUILD_DIR/arithmetic-code.elf"
ARITH_I64_CODE="$BUILD_DIR/arithmetic-i64-code.elf"
BAD_ARITH_CODE="$BUILD_DIR/arithmetic-bad-code.elf"
CTRL_CODE="$BUILD_DIR/control-flow-code.elf"
CTRL_EXIT="$BUILD_DIR/control-flow-aot.elf"
CTRL_OBJ="$BUILD_DIR/control_flow_obj.o"
CTRL_OBJ_EXE="$BUILD_DIR/control_flow_obj"
CTRL_CODE_OBJ="$BUILD_DIR/control_flow_code_obj.o"
CTRL_LINK_EXE="$BUILD_DIR/control_flow_linked"
CTRL_DIRECT_EXE="$BUILD_DIR/control_flow_direct"
MULTI_OBJ="$BUILD_DIR/multi_func.o"
MULTI_LINK_EXE="$BUILD_DIR/multi_func_linked"
MULTI_CTRL_OBJ="$BUILD_DIR/multi_func_control.o"
MULTI_CTRL_LINK_EXE="$BUILD_DIR/multi_func_control_linked"
RET42_OBJ="$BUILD_DIR/nano_ret42.o"
RET42_EXE="$BUILD_DIR/nano_ret42"
ARITH_OBJ="$BUILD_DIR/arithmetic_obj.o"
ARITH_OBJ_EXE="$BUILD_DIR/arithmetic_obj"
ARITH_CODE_OBJ="$BUILD_DIR/arithmetic_code_obj.o"
ARITH_LINK_EXE="$BUILD_DIR/arithmetic_linked"
ARITH_DIRECT_EXE="$BUILD_DIR/arithmetic_direct"
ARITH_DIRECT_OBJ="$BUILD_DIR/arithmetic_direct.o"
ARITH_DIRECT_OBJ_EXE="$BUILD_DIR/arithmetic_direct_obj"
CALL42_OBJ="$BUILD_DIR/nano_call42.o"
CALL42_CALLEE_OBJ="$BUILD_DIR/nano_ext42.o"
CALL42_LINK_EXE="$BUILD_DIR/nano_call42_linked"
CONST_PTR_CALL_OBJ="$BUILD_DIR/const_ptr_call.o"
CONST_PTR_CALLEE_OBJ="$BUILD_DIR/const_ptr_callee.o"
CONST_PTR_CROSS_LINK_EXE="$BUILD_DIR/const_ptr_cross_obj_linked"
DUP42_OBJ="$BUILD_DIR/nano_dup42.o"
SMOKE_SRC="$LAB_DIR/samples/libc-smoke.lisp"
SMOKE_BLOB="$BUILD_DIR/libc-smoke.lbin"
SMOKE_BLOB_REPEAT="$BUILD_DIR/libc-smoke-repeat.lbin"
SMOKE_APP="$BUILD_DIR/libc-smoke-app.com"
BOOTSTRAP_PLAN="$BUILD_DIR/bootstrap-smoke-plan.lisp"
RESOLVE_SRC="$BUILD_DIR/libc-resolve.lisp"
RESOLVE_BLOB="$BUILD_DIR/libc-resolve.lbin"
REPORT="$BUILD_DIR/bootstrap-report.txt"

mkdir -p "$BUILD_DIR"
: > "$REPORT"
cat > "$BOOTSTRAP_PLAN" <<EOF
(bootstrap
  (compile "$ARITH_SRC" "$BUILD_DIR/bootstrap-smoke-arithmetic.lbin")
  (hash "$BUILD_DIR/bootstrap-smoke-arithmetic.lbin")
  (compile "$ARITH_SRC" "$BUILD_DIR/bootstrap-smoke-arithmetic-repeat.lbin")
  (compare "$BUILD_DIR/bootstrap-smoke-arithmetic.lbin" "$BUILD_DIR/bootstrap-smoke-arithmetic-repeat.lbin")
  (run "$BUILD_DIR/bootstrap-smoke-arithmetic.lbin")
  (compile "$ARITH_I64_SRC" "$BUILD_DIR/bootstrap-smoke-arithmetic-i64.lbin")
  (run "$BUILD_DIR/bootstrap-smoke-arithmetic-i64.lbin")
  (compile "$CTRL_SRC" "$BUILD_DIR/bootstrap-smoke-control-flow.lbin")
  (run "$BUILD_DIR/bootstrap-smoke-control-flow.lbin")
  (compile "$STRLEN_SRC" "$BUILD_DIR/bootstrap-smoke-strlen.lbin")
  (resolve-quiet "$BUILD_DIR/bootstrap-smoke-strlen.lbin")
  (hash "$BUILD_DIR/bootstrap-smoke-strlen.lbin")
  (file-size "$BUILD_DIR/bootstrap-smoke-strlen.lbin")
  (file-hash "$BUILD_DIR/bootstrap-smoke-strlen.lbin")
  (dump "$BUILD_DIR/bootstrap-smoke-strlen.lbin")
  (compile "$STRLEN_SRC" "$BUILD_DIR/bootstrap-smoke-strlen-repeat.lbin")
  (compare "$BUILD_DIR/bootstrap-smoke-strlen.lbin" "$BUILD_DIR/bootstrap-smoke-strlen-repeat.lbin")
  (run "$BUILD_DIR/bootstrap-smoke-strlen.lbin")
  (compile "$TYPED_SRC" "$BUILD_DIR/bootstrap-smoke-typed-values.lbin")
  (resolve-quiet "$BUILD_DIR/bootstrap-smoke-typed-values.lbin")
  (file-size "$BUILD_DIR/bootstrap-smoke-typed-values.lbin")
  (run "$BUILD_DIR/bootstrap-smoke-typed-values.lbin")
  (compile "$PTR_SRC" "$BUILD_DIR/bootstrap-smoke-ptr-values.lbin")
  (file-size "$BUILD_DIR/bootstrap-smoke-ptr-values.lbin")
  (run "$BUILD_DIR/bootstrap-smoke-ptr-values.lbin")
  (compile "$CONST_PTR_SRC" "$BUILD_DIR/bootstrap-smoke-const-ptr-load-u8.lbin")
  (file-size "$BUILD_DIR/bootstrap-smoke-const-ptr-load-u8.lbin")
  (run "$BUILD_DIR/bootstrap-smoke-const-ptr-load-u8.lbin")
  (compile "$SMOKE_SRC" "$BUILD_DIR/bootstrap-smoke.lbin")
  (resolve-quiet "$BUILD_DIR/bootstrap-smoke.lbin")
  (hash "$BUILD_DIR/bootstrap-smoke.lbin")
  (dump "$BUILD_DIR/bootstrap-smoke.lbin")
  (compile "$SMOKE_SRC" "$BUILD_DIR/bootstrap-smoke-repeat.lbin")
  (compare "$BUILD_DIR/bootstrap-smoke.lbin" "$BUILD_DIR/bootstrap-smoke-repeat.lbin")
  (gen-libc-resolve "$BUILD_DIR/bootstrap-libc-resolve.lisp")
  (compile "$BUILD_DIR/bootstrap-libc-resolve.lisp" "$BUILD_DIR/bootstrap-libc-resolve.lbin")
  (file-size "$BUILD_DIR/bootstrap-libc-resolve.lbin")
  (resolve-quiet "$BUILD_DIR/bootstrap-libc-resolve.lbin")
  (pack-app "$BUILD_DIR/bootstrap-smoke.com" "$BUILD_DIR/nano-jit.x86_64" "$BUILD_DIR/nano-jit.aarch64" "$BUILD_DIR/bootstrap-smoke.lbin")
  (file-size "$BUILD_DIR/bootstrap-smoke.com")
  (file-hash "$BUILD_DIR/bootstrap-smoke.com")
  (inspect-app "$BUILD_DIR/bootstrap-smoke.com")
  (pack-ape "$BUILD_DIR/bootstrap-ape.com" "$BUILD_DIR/nano-jit.x86_64" "$BUILD_DIR/nano-jit.aarch64")
  (file-size "$BUILD_DIR/bootstrap-ape.com")
  (file-hash "$BUILD_DIR/bootstrap-ape.com")
  (inspect-ape "$BUILD_DIR/bootstrap-ape.com")
  (run-app "$BUILD_DIR/bootstrap-smoke.com")
  (run "$BUILD_DIR/bootstrap-smoke.lbin")
  (emit-elf64-exit "$BUILD_DIR/bootstrap-aot-exit42.elf" 42)
  (file-size "$BUILD_DIR/bootstrap-aot-exit42.elf")
  (file-hash "$BUILD_DIR/bootstrap-aot-exit42.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-exit42.elf" 42)
  (compile "$ARITH_SRC" "$BUILD_DIR/bootstrap-aot-arithmetic.lbin")
  (compile "$ARITH_I64_SRC" "$BUILD_DIR/bootstrap-aot-arithmetic-i64.lbin")
  (compile "$BAD_ARITH_SRC" "$BUILD_DIR/bootstrap-aot-arithmetic-bad.lbin")
  (aot-elf64-exit "$BUILD_DIR/bootstrap-aot-arithmetic.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-exit.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-exit.elf" 42)
  (aot-elf64-code "$BUILD_DIR/bootstrap-aot-arithmetic.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-code.elf")
  (file-size "$BUILD_DIR/bootstrap-aot-arithmetic-code.elf")
  (file-hash "$BUILD_DIR/bootstrap-aot-arithmetic-code.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-code.elf" 42)
  (aot-elf64-code "$BUILD_DIR/bootstrap-aot-arithmetic-i64.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-i64-code.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-i64-code.elf" 42)
  (aot-elf64-code "$BUILD_DIR/bootstrap-aot-arithmetic-bad.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-bad-code.elf")
  (file-size "$BUILD_DIR/bootstrap-aot-arithmetic-bad-code.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-bad-code.elf" 125)
  (compile "$CTRL_SRC" "$BUILD_DIR/bootstrap-aot-control-flow.lbin")
  (aot-elf64-exit "$BUILD_DIR/bootstrap-aot-control-flow.lbin" "$BUILD_DIR/bootstrap-aot-control-flow-exit.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-control-flow-exit.elf" 1)
  (aot-elf64-code "$BUILD_DIR/bootstrap-aot-control-flow.lbin" "$BUILD_DIR/bootstrap-aot-control-flow-code.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-control-flow-code.elf" 1)
  (compile-elf64-code "$CTRL_SRC" "$BUILD_DIR/bootstrap-aot-control-flow.elf")
  (file-size "$BUILD_DIR/bootstrap-aot-control-flow.elf")
  (file-hash "$BUILD_DIR/bootstrap-aot-control-flow.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-control-flow.elf" 1)
  (compile "$PTR_SRC" "$BUILD_DIR/bootstrap-aot-ptr-values.lbin")
  (aot-elf64-exit "$BUILD_DIR/bootstrap-aot-ptr-values.lbin" "$BUILD_DIR/bootstrap-aot-ptr-values-exit.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-ptr-values-exit.elf" 1)
  (compile "$CONST_PTR_SRC" "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8.lbin")
  (aot-elf64-exit "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8.lbin" "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8-exit.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8-exit.elf" 1)
  (aot-elf64-code "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8.lbin" "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8-code.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8-code.elf" 1)
  (aot-elf64-obj-code "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8.lbin" "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8-code.o" "nano_bootstrap_const_ptr_code")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8-linked" "nano_bootstrap_const_ptr_code" "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8-code.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8-linked" 1)
  (emit-elf64-obj-call "$BUILD_DIR/bootstrap-aot-const-ptr-call.o" "nano_bootstrap_const_ptr_call" "nano_bootstrap_const_ptr_callee")
  (aot-elf64-obj-code "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8.lbin" "$BUILD_DIR/bootstrap-aot-const-ptr-callee.o" "nano_bootstrap_const_ptr_callee")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-const-ptr-cross-linked" "nano_bootstrap_const_ptr_call" "$BUILD_DIR/bootstrap-aot-const-ptr-call.o" "$BUILD_DIR/bootstrap-aot-const-ptr-callee.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-const-ptr-cross-linked" 1)
  (aot-elf64-code "$BUILD_DIR/bootstrap-aot-ptr-values.lbin" "$BUILD_DIR/bootstrap-aot-ptr-values-code.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-ptr-values-code.elf" 1)
  (compile-elf64-code "$PTR_SRC" "$BUILD_DIR/bootstrap-aot-ptr-values.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-ptr-values.elf" 1)
  (compile-elf64-code "$CONST_PTR_SRC" "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-const-ptr-load-u8.elf" 1)
  (compile-elf64-code "$RODATA_READONLY_SRC" "$BUILD_DIR/bootstrap-aot-rodata-readonly.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-rodata-readonly.elf" 0)
  (aot-elf64-obj-ret "$BUILD_DIR/bootstrap-aot-arithmetic.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-ret.o" "nano_bootstrap_arith_ret")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-arithmetic-ret-linked" "nano_bootstrap_arith_ret" "$BUILD_DIR/bootstrap-aot-arithmetic-ret.o")
  (file-size "$BUILD_DIR/bootstrap-aot-arithmetic-ret-linked")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-ret-linked" 42)
  (aot-elf64-obj-ret "$BUILD_DIR/bootstrap-aot-control-flow.lbin" "$BUILD_DIR/bootstrap-aot-control-flow-ret.o" "nano_bootstrap_ctrl_ret")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-control-flow-ret-linked" "nano_bootstrap_ctrl_ret" "$BUILD_DIR/bootstrap-aot-control-flow-ret.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-control-flow-ret-linked" 1)
  (aot-elf64-obj-code "$BUILD_DIR/bootstrap-aot-control-flow.lbin" "$BUILD_DIR/bootstrap-aot-control-flow-code.o" "nano_bootstrap_ctrl_code")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-control-flow-code-linked" "nano_bootstrap_ctrl_code" "$BUILD_DIR/bootstrap-aot-control-flow-code.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-control-flow-code-linked" 1)
  (aot-elf64-obj-code "$BUILD_DIR/bootstrap-aot-arithmetic.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-code.o" "nano_bootstrap_arith_code")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-arithmetic-code-linked" "nano_bootstrap_arith_code" "$BUILD_DIR/bootstrap-aot-arithmetic-code.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-code-linked" 42)
  (aot-elf64-obj-code "$BUILD_DIR/bootstrap-aot-arithmetic-i64.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-i64-code.o" "nano_bootstrap_arith_i64_code")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-arithmetic-i64-code-linked" "nano_bootstrap_arith_i64_code" "$BUILD_DIR/bootstrap-aot-arithmetic-i64-code.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-i64-code-linked" 42)
  (compile-elf64-code "$ARITH_SRC" "$BUILD_DIR/bootstrap-aot-arithmetic-direct.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-direct.elf" 42)
  (compile-elf64-code "$ARITH_I64_SRC" "$BUILD_DIR/bootstrap-aot-arithmetic-i64-direct.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-i64-direct.elf" 42)
  (compile-elf64-exe "$ARITH_I64_SRC" "$BUILD_DIR/bootstrap-aot-arithmetic-i64-exe.elf" "nano_bootstrap_arith_i64_exe")
  (file-size "$BUILD_DIR/bootstrap-aot-arithmetic-i64-exe.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-i64-exe.elf" 42)
  (compile-elf64-obj-code "$ARITH_SRC" "$BUILD_DIR/bootstrap-aot-arithmetic-direct.o" "nano_bootstrap_arith_direct")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-arithmetic-direct-linked" "nano_bootstrap_arith_direct" "$BUILD_DIR/bootstrap-aot-arithmetic-direct.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-direct-linked" 42)
  (compile-elf64-obj-code "$MULTI_SRC" "$BUILD_DIR/bootstrap-aot-multi.o" "nano_bootstrap_multi")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-multi-linked" "nano_bootstrap_multi" "$BUILD_DIR/bootstrap-aot-multi.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-multi-linked" 43)
  (compile-elf64-exe "$MULTI_SRC" "$BUILD_DIR/bootstrap-aot-multi-direct.elf" "nano_bootstrap_multi_direct")
  (file-size "$BUILD_DIR/bootstrap-aot-multi-direct.elf")
  (file-hash "$BUILD_DIR/bootstrap-aot-multi-direct.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-multi-direct.elf" 43)
  (compile-elf64-obj-code "$MULTI_CTRL_SRC" "$BUILD_DIR/bootstrap-aot-multi-ctrl.o" "nano_bootstrap_multi_ctrl")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-multi-ctrl-linked" "nano_bootstrap_multi_ctrl" "$BUILD_DIR/bootstrap-aot-multi-ctrl.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-multi-ctrl-linked" 43)
  (compile-elf64-exe "$MULTI_CTRL_SRC" "$BUILD_DIR/bootstrap-aot-multi-ctrl-direct.elf" "nano_bootstrap_multi_ctrl_direct")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-multi-ctrl-direct.elf" 43)
  (compile-elf64-obj-code "$MULTI_PTR_SRC" "$BUILD_DIR/bootstrap-aot-multi-ptr.o" "nano_bootstrap_multi_ptr")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-multi-ptr-linked" "nano_bootstrap_multi_ptr" "$BUILD_DIR/bootstrap-aot-multi-ptr.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-multi-ptr-linked" 1)
  (compile-elf64-exe "$MULTI_PTR_SRC" "$BUILD_DIR/bootstrap-aot-multi-ptr-direct.elf" "nano_bootstrap_multi_ptr_direct")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-multi-ptr-direct.elf" 1)
  (compile-expect-exit 2 compile-elf64-obj-code "$MULTI_BAD_SRC" "$BUILD_DIR/bootstrap-aot-recursive-bad.o" "nano_bootstrap_recursive_bad")
  (compile-expect-exit 2 compile-elf64-exe "$MULTI_BAD_SRC" "$BUILD_DIR/bootstrap-aot-recursive-bad.elf" "nano_bootstrap_recursive_bad")
  (compile-expect-exit 2 compile-elf64-obj-code "$FUNC_PARAM_MISSING_PARAM_BAD_SRC" "$BUILD_DIR/bootstrap-aot-func-param-missing-param-bad.o" "nano_bootstrap_func_param_missing_param_bad")
  (compile-expect-exit 2 compile-elf64-exe "$FUNC_PARAM_MISSING_PARAM_BAD_SRC" "$BUILD_DIR/bootstrap-aot-func-param-missing-param-bad.elf" "nano_bootstrap_func_param_missing_param_bad")
  (compile-expect-exit 2 compile-elf64-obj-code "$FUNC_PARAM_CALL_NO_ARG_BAD_SRC" "$BUILD_DIR/bootstrap-aot-func-param-call-no-arg-bad.o" "nano_bootstrap_func_param_call_no_arg_bad")
  (compile-expect-exit 2 compile-elf64-exe "$FUNC_PARAM_CALL_NO_ARG_BAD_SRC" "$BUILD_DIR/bootstrap-aot-func-param-call-no-arg-bad.elf" "nano_bootstrap_func_param_call_no_arg_bad")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_PTR_OP_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-ptr-op.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_PTR_OP_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-ptr-op.o" "nano_bootstrap_type_bad_ptr_op")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_PTR_OP_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-ptr-op-direct.elf" "nano_bootstrap_type_bad_ptr_op")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_ADD_PTR_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-add-ptr.o" "nano_bootstrap_type_bad_add_ptr")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_SUB_PTR_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-sub-ptr.o" "nano_bootstrap_type_bad_sub_ptr")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_PTR_TO_U64_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-ptr-to-u64.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_PTR_TO_U64_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-ptr-to-u64.o" "nano_bootstrap_type_bad_ptr_to_u64")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_PTR_TO_U64_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-ptr-to-u64-exe.elf" "nano_bootstrap_type_bad_ptr_to_u64")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_U64_TO_PTR_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-u64-to-ptr.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_U64_TO_PTR_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-u64-to-ptr.o" "nano_bootstrap_type_bad_u64_to_ptr")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_U64_TO_PTR_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-u64-to-ptr-exe.elf" "nano_bootstrap_type_bad_u64_to_ptr")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_LOAD_U8_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-load-u8.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_LOAD_U8_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-load-u8.o" "nano_bootstrap_type_bad_load_u8")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_LOAD_U8_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-load-u8-exe.elf" "nano_bootstrap_type_bad_load_u8")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_LOAD_U16_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-load-u16.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_LOAD_U16_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-load-u16.o" "nano_bootstrap_type_bad_load_u16")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_LOAD_U16_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-load-u16-exe.elf" "nano_bootstrap_type_bad_load_u16")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_LOAD_U32_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-load-u32.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_LOAD_U32_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-load-u32.o" "nano_bootstrap_type_bad_load_u32")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_LOAD_U32_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-load-u32-exe.elf" "nano_bootstrap_type_bad_load_u32")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U8_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u8.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U8_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u8.o" "nano_bootstrap_type_bad_store_u8")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U8_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u8-exe.elf" "nano_bootstrap_type_bad_store_u8")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U8_RANGE_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u8-range.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U8_RANGE_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u8-range.o" "nano_bootstrap_type_bad_store_u8_range")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U8_RANGE_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u8-range-exe.elf" "nano_bootstrap_type_bad_store_u8_range")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U16_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u16.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U16_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u16.o" "nano_bootstrap_type_bad_store_u16")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U16_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u16-exe.elf" "nano_bootstrap_type_bad_store_u16")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U16_RANGE_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u16-range.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U16_RANGE_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u16-range.o" "nano_bootstrap_type_bad_store_u16_range")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U16_RANGE_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u16-range-exe.elf" "nano_bootstrap_type_bad_store_u16_range")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U32_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u32.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U32_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u32.o" "nano_bootstrap_type_bad_store_u32")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U32_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u32-exe.elf" "nano_bootstrap_type_bad_store_u32")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U32_RANGE_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u32-range.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U32_RANGE_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u32-range.o" "nano_bootstrap_type_bad_store_u32_range")
  (compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U32_RANGE_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-store-u32-range-exe.elf" "nano_bootstrap_type_bad_store_u32_range")
  (compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_BRANCH_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-branch.elf")
  (compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_EXPECT_PTR_SRC" "$BUILD_DIR/bootstrap-aot-type-bad-expect-ptr.o" "nano_bootstrap_type_bad_expect_ptr")
  (emit-elf64-obj-call "$BUILD_DIR/bootstrap-aot-call42.o" "nano_bootstrap_call" "nano_bootstrap_ext")
  (emit-elf64-obj-ret "$BUILD_DIR/bootstrap-aot-ext42.o" "nano_bootstrap_ext" 42)
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-call42-linked" "nano_bootstrap_call" "$BUILD_DIR/bootstrap-aot-call42.o" "$BUILD_DIR/bootstrap-aot-ext42.o")
  (file-size "$BUILD_DIR/bootstrap-aot-call42-linked")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-call42-linked" 42)
  (emit-elf64-obj-ret "$BUILD_DIR/bootstrap-aot-dup42.o" "nano_bootstrap_ext" 7)
  (link-expect-exit 2 "$BUILD_DIR/bootstrap-aot-dup-should-fail" "nano_bootstrap_call" "$BUILD_DIR/bootstrap-aot-call42.o" "$BUILD_DIR/bootstrap-aot-ext42.o" "$BUILD_DIR/bootstrap-aot-dup42.o"))
EOF

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

AARCH64_SLICE_SKIPPED=0

{
  echo "# nano-jit bootstrap"
  echo "stage=0"
  echo "goal=self-pack-multi-arch-com"
  echo "slice.compiler.mode=$NANO_SLICE_COMPILER"
  echo "apelink.role=not-used"
} | tee -a "$REPORT"

case "$NANO_SLICE_COMPILER" in
  native)
    if ! host_is_linux_x86_64; then
      {
        echo "native.slice=unsupported"
        echo "native.slice.host=$(uname -s)/$(uname -m)"
        echo "native.slice.need=Linux/x86_64"
      } | tee -a "$REPORT"
      exit 2
    fi
    if ! command -v cc >/dev/null 2>&1; then
      echo "native.slice=cc_missing" | tee -a "$REPORT"
      exit 2
    fi
    {
      echo "slice.compiler=native"
      echo "cosmocc.role=aarch64-slice-only-if-present"
      echo "genesis.pin.dir=$GENESIS_DIR"
    } | tee -a "$REPORT"
    if [ "${NANO_REGENESIS:-}" = "1" ]; then
      run_case "regenesis-build-x86_64-slice" cc -DNANO_LISP_JIT -Os -s "$NANO_C" -ldl \
        -o "$BUILD_DIR/nano-jit.x86_64"
      run_case "regenesis-update-genesis-x86_64" bash -c '
        cp "'"$BUILD_DIR/nano-jit.x86_64"'" "'"$GENESIS_X86"'" && chmod +x "'"$GENESIS_X86"'"
      '
      echo "genesis.regenesis=x86_64" | tee -a "$REPORT"
    else
      run_case "build-x86_64-slice-genesis-pin" bash -c '
        test -f "'"$GENESIS_X86"'" && cp "'"$GENESIS_X86"'" "'"$BUILD_DIR/nano-jit.x86_64"'" && chmod +x "'"$BUILD_DIR/nano-jit.x86_64"'"
      '
      echo "slice.x86_64.source=genesis-pin" | tee -a "$REPORT"
    fi
    if cosmocc_bin_usable "$COSMO_BIN"; then
      if [ "${NANO_REGENESIS:-}" = "1" ]; then
        run_case "regenesis-build-aarch64-slice" "$ARM_CC" "${COMMON[@]}" -o "$BUILD_DIR/nano-jit.aarch64"
        run_case "regenesis-update-genesis-aarch64" bash -c '
          cp "'"$BUILD_DIR/nano-jit.aarch64"'" "'"$GENESIS_AARCH64"'" && chmod +x "'"$GENESIS_AARCH64"'"
        '
      else
        run_case "build-aarch64-slice-genesis-pin" bash -c '
          test -f "'"$GENESIS_AARCH64"'" && cp "'"$GENESIS_AARCH64"'" "'"$BUILD_DIR/nano-jit.aarch64"'" && chmod +x "'"$BUILD_DIR/nano-jit.aarch64"'"
        '
        echo "slice.aarch64.source=genesis-pin" | tee -a "$REPORT"
      fi
      echo "slice.aarch64.compiler=cosmocc" | tee -a "$REPORT"
      echo "slice.aarch64.mode=cosmo" | tee -a "$REPORT"
    elif aarch64_cross_cc_available; then
      if [ "${NANO_REGENESIS:-}" = "1" ]; then
        ARM_CROSS="$(aarch64_cross_cc)"
        AARCH64_STATIC_FLAGS="-DNANO_LISP_JIT -Os -s"
        if has_qemu_aarch64; then
          AARCH64_STATIC_FLAGS="$AARCH64_STATIC_FLAGS -static"
          echo "slice.aarch64.link=static-for-qemu" | tee -a "$REPORT"
        fi
        run_case "regenesis-build-aarch64-slice-cross" "$ARM_CROSS" $AARCH64_STATIC_FLAGS "$NANO_C" -ldl \
          -o "$BUILD_DIR/nano-jit.aarch64"
        run_case "regenesis-update-genesis-aarch64-cross" bash -c '
          cp "'"$BUILD_DIR/nano-jit.aarch64"'" "'"$GENESIS_AARCH64"'" && chmod +x "'"$GENESIS_AARCH64"'"
        '
      else
        run_case "build-aarch64-slice-cross-genesis-pin" bash -c '
          test -f "'"$GENESIS_AARCH64"'" && cp "'"$GENESIS_AARCH64"'" "'"$BUILD_DIR/nano-jit.aarch64"'" && chmod +x "'"$BUILD_DIR/nano-jit.aarch64"'"
        '
        echo "slice.aarch64.source=genesis-pin" | tee -a "$REPORT"
      fi
      {
        echo "slice.aarch64.compiler=native-cross-genesis-pin"
        echo "slice.aarch64.mode=native-cross"
      } | tee -a "$REPORT"
      run_case "verify-aarch64-slice-elf" bash -c '
        file -b "'"$BUILD_DIR/nano-jit.aarch64"'" | grep -q "ARM aarch64"
      '
      if has_qemu_aarch64; then
        QEMU_AARCH64="$(qemu_aarch64_cmd)"
        run_case "qemu-aarch64-slice-compile-arithmetic" bash -c '
          "'"$QEMU_AARCH64"'" "'"$BUILD_DIR/nano-jit.aarch64"'" compile "'"$ARITH_SRC"'" \
            "'"$BUILD_DIR/native-aarch64-arithmetic.lbin"'"
        '
        run_case "qemu-aarch64-slice-run-arithmetic" bash -c '
          "'"$QEMU_AARCH64"'" "'"$BUILD_DIR/nano-jit.aarch64"'" run \
            "'"$BUILD_DIR/native-aarch64-arithmetic.lbin"'"
        '
      else
        build_skip_case "qemu-aarch64-slice-smoke" "qemu-aarch64-static not installed"
      fi
    else
      {
        printf '\n## build-aarch64-slice\n'
        echo "slice.aarch64=skipped"
        echo "slice.aarch64.reason=cosmocc_missing"
        echo "slice.aarch64.need=aarch64-unknown-cosmo-cc"
        echo "searched=$COSMO_BIN"
        echo "exit.status=0"
      } | tee -a "$REPORT"
      AARCH64_SLICE_SKIPPED=1
    fi
    ;;
  cosmo)
    if ! cosmocc_bin_usable "$COSMO_BIN"; then
      {
        echo "cosmocc=missing"
        echo "searched=$COSMO_BIN"
        echo "need=x86_64-unknown-cosmo-cc,aarch64-unknown-cosmo-cc"
        echo "hint=set NANO_SLICE_COMPILER=native on Linux x86_64 with host cc"
      } | tee -a "$REPORT"
      exit 2
    fi
    {
      echo "slice.compiler=cosmo"
      echo "cosmocc.role=temporary-slice-compiler"
    } | tee -a "$REPORT"
    run_case "build-x86_64-slice" "$X86_CC" "${COMMON[@]}" -o "$BUILD_DIR/nano-jit.x86_64"
    run_case "build-aarch64-slice" "$ARM_CC" "${COMMON[@]}" -o "$BUILD_DIR/nano-jit.aarch64"
    ;;
  *)
    {
      echo "slice.compiler=invalid"
      echo "slice.compiler.value=$NANO_SLICE_COMPILER"
      echo "slice.compiler.allowed=native,cosmo"
    } | tee -a "$REPORT"
    exit 2
    ;;
esac

if [ "$AARCH64_SLICE_SKIPPED" = 1 ]; then
  PACKER="$BUILD_DIR/nano-jit.x86_64"
  {
    printf '\n## self-pack-nano-jit-com\n'
    echo "self-pack=oracle-x86-duplicate"
    echo "slice.aarch64=x86_64_duplicate"
    echo "slice.aarch64.reason=cosmocc_missing"
  } | tee -a "$REPORT"
  run_case "self-pack-nano-jit-com" "$PACKER" pack-ape \
    "$BUILD_DIR/nano-jit.com" \
    "$BUILD_DIR/nano-jit.x86_64" \
    "$BUILD_DIR/nano-jit.x86_64"
  run_case "inspect-nano-jit-com" bash -c '
    out=$("'"$PACKER"'" inspect-ape "'"$BUILD_DIR/nano-jit.com"'" 2>&1) || exit 1
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "inspect-ape.container=ape-v2"
  '
  run_case "run-ape-nano-jit-com-smoke" bash -c '
    out=$("'"$PACKER"'" run-ape "'"$BUILD_DIR/nano-jit.com"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "run-ape.arch="
  '
  run_case "native-x86-slice-compile-arithmetic" \
    "$PACKER" compile "$ARITH_SRC" "$BUILD_DIR/native-smoke-arithmetic.lbin"
  run_case "native-x86-slice-run-arithmetic" \
    "$PACKER" run "$BUILD_DIR/native-smoke-arithmetic.lbin"
  FUNC_CALL_VM_SMOKE_SRC="$LAB_DIR/samples/func-call-vm-smoke.lisp"
  run_case "native-x86-slice-compile-func-call-vm-smoke" \
    "$PACKER" compile "$FUNC_CALL_VM_SMOKE_SRC" "$BUILD_DIR/native-smoke-func-call-vm.lbin"
  run_case "native-x86-slice-run-func-call-vm-smoke" \
    "$PACKER" run "$BUILD_DIR/native-smoke-func-call-vm.lbin"
  run_case "native-x86-slice-reject-func-param-missing-param-lbin" \
    "$PACKER" compile-expect-exit 2 compile "$FUNC_PARAM_MISSING_PARAM_BAD_SRC" \
    "$BUILD_DIR/native-func-param-missing-param-bad.lbin"
  run_case "native-x86-slice-reject-func-param-call-no-arg-lbin" \
    "$PACKER" compile-expect-exit 2 compile "$FUNC_PARAM_CALL_NO_ARG_BAD_SRC" \
    "$BUILD_DIR/native-func-param-call-no-arg-bad.lbin"
  run_case "native-x86-slice-compile-func-param-vm-i64" \
    "$PACKER" compile "$FUNC_PARAM_VM_I64_SRC" "$BUILD_DIR/native-smoke-func-param-vm-i64.lbin"
  run_case "native-x86-slice-run-func-param-vm-i64" \
    "$PACKER" run "$BUILD_DIR/native-smoke-func-param-vm-i64.lbin"
  run_case "run-bootstrap-v3-vm-selfpack-matrix" \
    bash -c "cd \"$ROOT_DIR\" && \"$PACKER\" run-bootstrap-plan \"$BOOTSTRAP_V3_VM_MATRIX\""
  run_case "run-bootstrap-v3-codegen-smoke-native-slice" \
    bash -c "cd \"$ROOT_DIR\" && \"$PACKER\" run-bootstrap-plan \"$BOOTSTRAP_V3_CODEGEN_SMOKE\""
  run_case "run-bootstrap-v25-native-selfpack" \
    bash -c "cd \"$ROOT_DIR\" && \"$PACKER\" run-bootstrap-plan \"$BOOTSTRAP_V25_NATIVE_SELFPACK\""
  if [ "$NANO_SELFHOST_THOROUGH" = "1" ]; then
    mkdir -p "$SELFHOST_DIR"
    run_case "selfhost-thorough-round1-genesis-x86-only" bash -c '
      cd "'"$ROOT_DIR"'" && "'"$PACKER"'" run-bootstrap-plan "'"$BOOTSTRAP_V3_SELFHOST_GEN1"'"
    '
    run_case "selfhost-thorough-round2-gen1-slice-x86-only" bash -c '
      cd "'"$ROOT_DIR"'" && "'"$SELFHOST_DIR"'/gen1-slice-x86.elf" run-bootstrap-plan "'"$BOOTSTRAP_V3_SELFHOST_GEN2"'"
    '
  fi
  {
    echo "nano-jit.com.bytes=$(bytes_of "$BUILD_DIR/nano-jit.com")"
    echo "nano-jit.com.fnv1a64=$(hash_of "$BUILD_DIR/nano-jit.com")"
    echo "nano-jit.x86_64.bytes=$(bytes_of "$BUILD_DIR/nano-jit.x86_64")"
    echo "nano-jit.x86_64.fnv1a64=$(hash_of "$BUILD_DIR/nano-jit.x86_64")"
    echo "nano-jit.aarch64.bytes=$(bytes_of "$BUILD_DIR/nano-jit.x86_64")"
    echo "nano-jit.aarch64.fnv1a64=$(hash_of "$BUILD_DIR/nano-jit.x86_64")"
  } | tee -a "$REPORT"
  echo "bootstrap.report=$REPORT" | tee -a "$REPORT"
  ls -l "$BUILD_DIR"/nano-jit.com "$BUILD_DIR"/nano-jit.x86_64 2>/dev/null || ls -l "$BUILD_DIR"/nano-jit.x86_64
  exit 0
fi

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

run_case "inspect-nano-jit-com" bash -c '
  out=$("'"$PACKER"'" inspect-ape "'"$BUILD_DIR/nano-jit.com"'" 2>&1) || exit 1
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "inspect-ape.container=ape-v2"
'

if [ -f "$BUILD_DIR/nano-jit.aarch64" ] && [ -f "$BUILD_DIR/nano-jit.x86_64" ]; then
  run_case "native-slice-payload-hash-distinct" bash -c '
    h0=$("'"$PACKER"'" file-hash "'"$BUILD_DIR/nano-jit.x86_64"'" 2>/dev/null | tail -1)
    h1=$("'"$PACKER"'" file-hash "'"$BUILD_DIR/nano-jit.aarch64"'" 2>/dev/null | tail -1)
    printf "slice.x86_64.hash=%s\n" "$h0"
    printf "slice.aarch64.hash=%s\n" "$h1"
    [ -n "$h0" ] && [ -n "$h1" ] && [ "$h0" != "$h1" ]
  '
fi

if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ]; then
  run_case "run-ape-nano-jit-com-smoke" bash -c '
    out=$("'"$PACKER"'" run-ape "'"$BUILD_DIR/nano-jit.com"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "run-ape.arch="
  '
  if has_qemu_aarch64; then
    run_case "run-ape-nano-jit-com-aarch64-smoke" bash -c '
      out=$("'"$PACKER"'" run-ape "'"$BUILD_DIR/nano-jit.com"'" aarch64 2>&1) || true
      printf "%s\n" "$out"
      printf "%s\n" "$out" | grep -q "run-ape.force_arch=aarch64"
    '
  else
    build_skip_case "run-ape-nano-jit-com-aarch64-smoke" "qemu-aarch64 not available"
  fi
fi

run_case "make-ape-negative-fixtures-self-pack" python3 "$LAB_DIR/make_ape_fixtures.py" \
  "$BUILD_DIR/nano-jit.com" "$APE_FIXTURE_DIR"
run_case "run-bootstrap-ape-negative-self-pack" \
  bash -c "cd \"$ROOT_DIR\" && \"$BUILD_DIR/nano-jit.com\" run-bootstrap-plan \"$BOOTSTRAP_APE_NEG_SRC\""

rm -f "$APE_FIXTURE_DIR/const-ptr-data-fixtures.lbin" 2>/dev/null || true
run_case "nano-jit-compile-const-ptr-for-data-fixtures-self-pack" \
  "$BUILD_DIR/nano-jit.com" compile "$CONST_PTR_SRC" "$APE_FIXTURE_DIR/const-ptr-data-fixtures.lbin"
run_case "nano-jit-aot-const-ptr-data-good-obj-self-pack" \
  "$BUILD_DIR/nano-jit.com" aot-elf64-obj-code "$APE_FIXTURE_DIR/const-ptr-data-fixtures.lbin" "$DATA_GOOD_OBJ" nano_main
run_case "make-data-reloc-negative-fixtures-self-pack" python3 "$LAB_DIR/make_data_reloc_fixtures.py" \
  "$DATA_GOOD_OBJ" "$DATA_BAD_RELOC_TYPE_OBJ" "$DATA_BAD_RELOC_SYM_OBJ" "$DATA_BAD_SYMBOL_SHNDX_OBJ"
run_case "run-bootstrap-data-negative-self-pack" \
  bash -c "cd \"$ROOT_DIR\" && \"$BUILD_DIR/nano-jit.com\" run-bootstrap-plan \"$BOOTSTRAP_DATA_NEG_SRC\""
run_case "nano-jit-compile-rodata-readonly-elf64-self-pack" \
  "$BUILD_DIR/nano-jit.com" compile-elf64-code "$RODATA_READONLY_SRC" "$BUILD_DIR/rodata_readonly_self_packed.elf"
run_case "nano-jit-run-rodata-readonly-elf64-self-pack" \
  "$BUILD_DIR/nano-jit.com" run-expect-exit "$BUILD_DIR/rodata_readonly_self_packed.elf" 0

{
  echo "nano-jit.com.bytes=$(bytes_of "$BUILD_DIR/nano-jit.com")"
  echo "nano-jit.com.fnv1a64=$(hash_of "$BUILD_DIR/nano-jit.com")"
  echo "nano-jit.x86_64.bytes=$(bytes_of "$BUILD_DIR/nano-jit.x86_64")"
  echo "nano-jit.x86_64.fnv1a64=$(hash_of "$BUILD_DIR/nano-jit.x86_64")"
  echo "nano-jit.aarch64.bytes=$(bytes_of "$BUILD_DIR/nano-jit.aarch64")"
  echo "nano-jit.aarch64.fnv1a64=$(hash_of "$BUILD_DIR/nano-jit.aarch64")"
} | tee -a "$REPORT"

run_case "nano-jit-compile-smoke" "$BUILD_DIR/nano-jit.com" compile "$SMOKE_SRC" "$SMOKE_BLOB"
run_case "nano-jit-compile-arithmetic" "$BUILD_DIR/nano-jit.com" compile "$ARITH_SRC" "$ARITH_BLOB"
run_case "nano-jit-run-arithmetic" "$BUILD_DIR/nano-jit.com" run "$ARITH_BLOB"
run_case "nano-jit-compile-arithmetic-i64" "$BUILD_DIR/nano-jit.com" compile "$ARITH_I64_SRC" "$ARITH_I64_BLOB"
run_case "nano-jit-run-arithmetic-i64" "$BUILD_DIR/nano-jit.com" run "$ARITH_I64_BLOB"
FUNC_CALL_VM_SMOKE_SRC="$LAB_DIR/samples/func-call-vm-smoke.lisp"
run_case "nano-jit-selfpack-compile-func-call-vm-smoke" \
  "$BUILD_DIR/nano-jit.com" compile "$FUNC_CALL_VM_SMOKE_SRC" "$BUILD_DIR/selfpack-func-call-vm.lbin"
run_case "nano-jit-selfpack-run-func-call-vm-smoke" \
  "$BUILD_DIR/nano-jit.com" run "$BUILD_DIR/selfpack-func-call-vm.lbin"
run_case "nano-jit-selfpack-compile-func-param-vm-i64" \
  "$BUILD_DIR/nano-jit.com" compile "$FUNC_PARAM_VM_I64_SRC" "$BUILD_DIR/selfpack-func-param-vm-i64.lbin"
run_case "nano-jit-selfpack-run-func-param-vm-i64" \
  "$BUILD_DIR/nano-jit.com" run "$BUILD_DIR/selfpack-func-param-vm-i64.lbin"
run_case "nano-jit-selfpack-run-bootstrap-v3-vm-matrix" \
  bash -c "cd \"$ROOT_DIR\" && \"$BUILD_DIR/nano-jit.com\" run-bootstrap-plan \"$BOOTSTRAP_V3_VM_MATRIX\""
run_case "nano-jit-selfpack-run-bootstrap-v3-codegen-smoke" \
  bash -c "cd \"$ROOT_DIR\" && \"$BUILD_DIR/nano-jit.com\" run-bootstrap-plan \"$BOOTSTRAP_V3_CODEGEN_SMOKE\""
run_case "nano-jit-compile-typed-values" "$BUILD_DIR/nano-jit.com" compile "$TYPED_SRC" "$TYPED_BLOB"
run_case "nano-jit-run-typed-values" "$BUILD_DIR/nano-jit.com" run "$TYPED_BLOB"
run_case "nano-jit-run-bootstrap-plan" "$BUILD_DIR/nano-jit.com" run-bootstrap-plan "$BOOTSTRAP_PLAN"
run_case "nano-jit-compile-control-flow" "$BUILD_DIR/nano-jit.com" compile "$CTRL_SRC" "$CTRL_BLOB"
run_case "nano-jit-run-control-flow" "$BUILD_DIR/nano-jit.com" run "$CTRL_BLOB"
run_case "nano-jit-emit-elf64-exit42" "$BUILD_DIR/nano-jit.com" emit-elf64-exit "$EXIT42" 42
run_case "nano-jit-run-elf64-exit42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$EXIT42" 42
run_case "nano-jit-aot-arithmetic-elf64-exit42" "$BUILD_DIR/nano-jit.com" aot-elf64-exit "$ARITH_BLOB" "$ARITH_EXIT"
run_case "nano-jit-run-aot-arithmetic-exit42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$ARITH_EXIT" 42
run_case "nano-jit-aot-arithmetic-elf64-code42" "$BUILD_DIR/nano-jit.com" aot-elf64-code "$ARITH_BLOB" "$ARITH_CODE"
run_case "nano-jit-run-aot-arithmetic-code42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$ARITH_CODE" 42
run_case "nano-jit-aot-arithmetic-i64-elf64-code42" "$BUILD_DIR/nano-jit.com" aot-elf64-code "$ARITH_I64_BLOB" "$ARITH_I64_CODE"
run_case "nano-jit-run-aot-arithmetic-i64-code42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$ARITH_I64_CODE" 42
run_case "nano-jit-compile-bad-arithmetic" "$BUILD_DIR/nano-jit.com" compile "$BAD_ARITH_SRC" "$BAD_ARITH_BLOB"
run_case "nano-jit-aot-bad-arithmetic-elf64-code" "$BUILD_DIR/nano-jit.com" aot-elf64-code "$BAD_ARITH_BLOB" "$BAD_ARITH_CODE"
run_case "nano-jit-run-aot-bad-arithmetic-expect125" "$BUILD_DIR/nano-jit.com" run-expect-exit "$BAD_ARITH_CODE" 125
run_case "nano-jit-aot-control-flow-elf64-exit1" "$BUILD_DIR/nano-jit.com" aot-elf64-exit "$CTRL_BLOB" "$CTRL_EXIT"
run_case "nano-jit-run-aot-control-flow-exit1" "$BUILD_DIR/nano-jit.com" run-expect-exit "$CTRL_EXIT" 1
run_case "nano-jit-aot-control-flow-elf64-obj-ret1" "$BUILD_DIR/nano-jit.com" aot-elf64-obj-ret "$CTRL_BLOB" "$CTRL_OBJ" nano_ctrl
run_case "nano-jit-link-aot-control-flow-obj1" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$CTRL_OBJ_EXE" nano_ctrl "$CTRL_OBJ"
run_case "nano-jit-run-aot-control-flow-obj1" "$BUILD_DIR/nano-jit.com" run-expect-exit "$CTRL_OBJ_EXE" 1
run_case "nano-jit-aot-control-flow-elf64-code1" "$BUILD_DIR/nano-jit.com" aot-elf64-code "$CTRL_BLOB" "$CTRL_CODE"
run_case "nano-jit-run-aot-control-flow-code1" "$BUILD_DIR/nano-jit.com" run-expect-exit "$CTRL_CODE" 1
run_case "nano-jit-aot-control-flow-elf64-obj-code1" "$BUILD_DIR/nano-jit.com" aot-elf64-obj-code "$CTRL_BLOB" "$CTRL_CODE_OBJ" nano_ctrl_code
run_case "nano-jit-tiny-link-aot-control-flow-obj-code1" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$CTRL_LINK_EXE" nano_ctrl_code "$CTRL_CODE_OBJ"
run_case "nano-jit-run-tiny-linked-control-flow1" "$BUILD_DIR/nano-jit.com" run-expect-exit "$CTRL_LINK_EXE" 1
run_case "nano-jit-compile-control-flow-elf64-code1" "$BUILD_DIR/nano-jit.com" compile-elf64-code "$CTRL_SRC" "$CTRL_DIRECT_EXE"
run_case "nano-jit-run-direct-compiled-control-flow1" "$BUILD_DIR/nano-jit.com" run-expect-exit "$CTRL_DIRECT_EXE" 1
run_case "nano-jit-emit-elf64-obj-ret42" "$BUILD_DIR/nano-jit.com" emit-elf64-obj-ret "$RET42_OBJ" nano_ret 42
run_case "nano-jit-link-elf64-obj-ret42" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$RET42_EXE" nano_ret "$RET42_OBJ"
run_case "nano-jit-run-elf64-obj-ret42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$RET42_EXE" 42
run_case "nano-jit-aot-arithmetic-elf64-obj-ret42" "$BUILD_DIR/nano-jit.com" aot-elf64-obj-ret "$ARITH_BLOB" "$ARITH_OBJ" nano_arith
run_case "nano-jit-link-aot-arithmetic-obj-ret42" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$ARITH_OBJ_EXE" nano_arith "$ARITH_OBJ"
run_case "nano-jit-run-aot-arithmetic-obj-ret42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$ARITH_OBJ_EXE" 42
run_case "nano-jit-aot-arithmetic-elf64-obj-code42" "$BUILD_DIR/nano-jit.com" aot-elf64-obj-code "$ARITH_BLOB" "$ARITH_CODE_OBJ" nano_arith_code
run_case "nano-jit-tiny-link-aot-arithmetic-obj-code42" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$ARITH_LINK_EXE" nano_arith_code "$ARITH_CODE_OBJ"
run_case "nano-jit-run-tiny-linked-arithmetic42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$ARITH_LINK_EXE" 42
run_case "nano-jit-compile-arithmetic-elf64-code42" "$BUILD_DIR/nano-jit.com" compile-elf64-code "$ARITH_SRC" "$ARITH_DIRECT_EXE"
run_case "nano-jit-run-direct-compiled-arithmetic42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$ARITH_DIRECT_EXE" 42
run_case "nano-jit-compile-arithmetic-elf64-obj-code42" "$BUILD_DIR/nano-jit.com" compile-elf64-obj-code "$ARITH_SRC" "$ARITH_DIRECT_OBJ" nano_arith_direct
run_case "nano-jit-link-direct-compiled-arithmetic-obj42" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$ARITH_DIRECT_OBJ_EXE" nano_arith_direct "$ARITH_DIRECT_OBJ"
run_case "nano-jit-run-direct-compiled-arithmetic-obj42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$ARITH_DIRECT_OBJ_EXE" 42
run_case "nano-jit-compile-multi-func-elf64-obj43" "$BUILD_DIR/nano-jit.com" compile-elf64-obj-code "$MULTI_SRC" "$MULTI_OBJ" nano_multi_entry
run_case "nano-jit-tiny-link-multi-func-obj43" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$MULTI_LINK_EXE" nano_multi_entry "$MULTI_OBJ"
run_case "nano-jit-run-tiny-linked-multi-func43" "$BUILD_DIR/nano-jit.com" run-expect-exit "$MULTI_LINK_EXE" 43
run_case "nano-jit-compile-multi-func-control-flow-elf64-obj43" "$BUILD_DIR/nano-jit.com" compile-elf64-obj-code "$MULTI_CTRL_SRC" "$MULTI_CTRL_OBJ" nano_multi_ctrl
run_case "nano-jit-tiny-link-multi-func-control-flow-obj43" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$MULTI_CTRL_LINK_EXE" nano_multi_ctrl "$MULTI_CTRL_OBJ"
run_case "nano-jit-run-tiny-linked-multi-func-control-flow43" "$BUILD_DIR/nano-jit.com" run-expect-exit "$MULTI_CTRL_LINK_EXE" 43
run_case "nano-jit-emit-elf64-obj-call42" "$BUILD_DIR/nano-jit.com" emit-elf64-obj-call "$CALL42_OBJ" nano_call nano_ext
run_case "nano-jit-emit-elf64-obj-callee42" "$BUILD_DIR/nano-jit.com" emit-elf64-obj-ret "$CALL42_CALLEE_OBJ" nano_ext 42
run_case "nano-jit-tiny-link-elf64-obj-call42" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$CALL42_LINK_EXE" nano_call "$CALL42_OBJ" "$CALL42_CALLEE_OBJ"
run_case "nano-jit-run-tiny-linked-call42" "$BUILD_DIR/nano-jit.com" run-expect-exit "$CALL42_LINK_EXE" 42
run_case "nano-jit-emit-cross-object-const-ptr-call" "$BUILD_DIR/nano-jit.com" emit-elf64-obj-call "$CONST_PTR_CALL_OBJ" nano_const_ptr_call nano_const_ptr_callee
run_case "nano-jit-compile-const-ptr-elf64-code1" "$BUILD_DIR/nano-jit.com" compile-elf64-code "$CONST_PTR_SRC" "$CONST_PTR_DIRECT_EXE"
run_case "nano-jit-run-direct-compiled-const-ptr-load-u8-1" "$BUILD_DIR/nano-jit.com" run-expect-exit "$CONST_PTR_DIRECT_EXE" 1
run_case "nano-jit-compile-cross-object-const-ptr-callee" "$BUILD_DIR/nano-jit.com" compile "$CONST_PTR_SRC" "$CONST_PTR_BLOB"
run_case "nano-jit-aot-cross-object-const-ptr-callee" "$BUILD_DIR/nano-jit.com" aot-elf64-obj-code "$CONST_PTR_BLOB" "$CONST_PTR_CALLEE_OBJ" nano_const_ptr_callee
run_case "nano-jit-tiny-link-cross-object-const-ptr-data" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$CONST_PTR_CROSS_LINK_EXE" nano_const_ptr_call "$CONST_PTR_CALL_OBJ" "$CONST_PTR_CALLEE_OBJ"
run_case "nano-jit-run-cross-object-const-ptr-data" "$BUILD_DIR/nano-jit.com" run-expect-exit "$CONST_PTR_CROSS_LINK_EXE" 1
run_case "nano-jit-emit-elf64-obj-duplicate-nano-ext" "$BUILD_DIR/nano-jit.com" emit-elf64-obj-ret "$DUP42_OBJ" nano_ext 7
run_case "nano-jit-tiny-link-reject-duplicate-symbol" "$BUILD_DIR/nano-jit.com" link-expect-exit 2 "$BUILD_DIR/dup_should_fail" nano_call "$CALL42_OBJ" "$CALL42_CALLEE_OBJ" "$DUP42_OBJ"
run_case "nano-jit-compile-smoke-repeat" "$BUILD_DIR/nano-jit.com" compile "$SMOKE_SRC" "$SMOKE_BLOB_REPEAT"
run_case "nano-jit-hash-smoke" "$BUILD_DIR/nano-jit.com" hash "$SMOKE_BLOB"
run_case "nano-jit-hash-smoke-repeat" "$BUILD_DIR/nano-jit.com" hash "$SMOKE_BLOB_REPEAT"
run_case "nano-jit-compare-deterministic-smoke" "$BUILD_DIR/nano-jit.com" compare "$SMOKE_BLOB" "$SMOKE_BLOB_REPEAT"
run_case "nano-jit-run-smoke" "$BUILD_DIR/nano-jit.com" run "$SMOKE_BLOB"
run_case "nano-jit-pack-smoke-app" "$BUILD_DIR/nano-jit.com" pack-app \
  "$SMOKE_APP" \
  "$BUILD_DIR/nano-jit.x86_64" \
  "$BUILD_DIR/nano-jit.aarch64" \
  "$SMOKE_BLOB"
run_case "nano-jit-inspect-smoke-app" "$BUILD_DIR/nano-jit.com" inspect-app "$SMOKE_APP"
{
  echo "libc-smoke-app.com.bytes=$(bytes_of "$SMOKE_APP")"
  echo "libc-smoke-app.com.fnv1a64=$(hash_of "$SMOKE_APP")"
} | tee -a "$REPORT"
run_case "nano-jit-run-smoke-app" "$SMOKE_APP"
run_case "generate-libc-resolve-manifest" "$BUILD_DIR/nano-jit.com" gen-libc-resolve "$RESOLVE_SRC"
run_case "nano-jit-compile-libc-resolve" "$BUILD_DIR/nano-jit.com" compile "$RESOLVE_SRC" "$RESOLVE_BLOB"
run_case "nano-jit-resolve-libc" "$BUILD_DIR/nano-jit.com" resolve --quiet "$RESOLVE_BLOB"

if [ "$NANO_SELFHOST_THOROUGH" = "1" ] && { [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ]; }; then
  mkdir -p "$SELFHOST_DIR"
  GENESIS_RUNNER="$PACKER"
  if [ ! -x "$GENESIS_RUNNER" ]; then
    GENESIS_RUNNER="$BUILD_DIR/nano-jit.x86_64"
  fi
  run_case "selfhost-thorough-round1-genesis" bash -c '
    cd "'"$ROOT_DIR"'" && "'"$GENESIS_RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V3_SELFHOST_GEN1"'"
  '
  run_case "selfhost-thorough-round1-artifacts" bash -c '
    test -x "'"$SELFHOST_DIR"'/gen1-slice-x86.elf"
    test -f "'"$SELFHOST_DIR"'/gen1-slice-aarch64.elf"
    test -f "'"$SELFHOST_DIR"'/gen1-nano-jit.com"
    test -f "'"$SELFHOST_DIR"'/gen1-arithmetic.lbin"
    file -b "'"$SELFHOST_DIR"'/gen1-slice-aarch64.elf" | grep -q "ARM aarch64"
    "'"$SELFHOST_DIR"'/gen1-slice-x86.elf" run "'"$SELFHOST_DIR"'/gen1-arithmetic.lbin"
  '
  run_case "selfhost-thorough-round2-gen1-slice" bash -c '
    cd "'"$ROOT_DIR"'" && "'"$SELFHOST_DIR"'/gen1-slice-x86.elf" run-bootstrap-plan "'"$BOOTSTRAP_V3_SELFHOST_GEN2"'"
  '
  run_case "selfhost-thorough-round2-artifacts" bash -c '
    test -x "'"$SELFHOST_DIR"'/gen2-slice-x86.elf"
    test -f "'"$SELFHOST_DIR"'/gen2-nano-jit.com"
    test -f "'"$SELFHOST_DIR"'/gen2-arithmetic.lbin"
    "'"$SELFHOST_DIR"'/gen2-slice-x86.elf" run "'"$SELFHOST_DIR"'/gen2-arithmetic.lbin"
  '
  run_case "selfhost-codegen-round3-gen2-runner" bash -c '
    cd "'"$ROOT_DIR"'" && "'"$SELFHOST_DIR"'/gen2-slice-x86.elf" run-bootstrap-plan "'"$BOOTSTRAP_V3_SELFHOST_GEN3"'"
  '
  run_case "selfhost-codegen-round3-artifacts" bash -c '
    test -x "'"$SELFHOST_DIR"'/gen3-slice-lisp-x86.elf"
    test -x "'"$SELFHOST_DIR"'/gen3-slice-nano-cc-x86.elf"
    "'"$SELFHOST_DIR"'/gen3-slice-lisp-x86.elf"; test $? -eq 42
    "'"$SELFHOST_DIR"'/gen3-slice-nano-cc-x86.elf"; test $? -eq 42
  '
  {
    echo "selfhost.thorough=ok"
    echo "selfhost.gen1.slice.x86.hash=$(hash_of "$SELFHOST_DIR/gen1-slice-x86.elf")"
    echo "selfhost.gen2.slice.x86.hash=$(hash_of "$SELFHOST_DIR/gen2-slice-x86.elf")"
  } | tee -a "$REPORT"
else
  build_skip_case "selfhost-thorough-round1-genesis" "NANO_SELFHOST_THOROUGH=$NANO_SELFHOST_THOROUGH or non-x86 host"
fi

build_end_summary
echo "bootstrap.report=$REPORT" | tee -a "$REPORT"
ls -l "$BUILD_DIR"/nano-jit.*
if [ "$BUILD_FAIL" -gt 0 ]; then
  exit 1
fi
