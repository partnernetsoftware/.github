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
ARITH_SRC="$LAB_DIR/samples/arithmetic.lisp"
ARITH_BLOB="$BUILD_DIR/arithmetic.lbin"
TYPED_SRC="$LAB_DIR/samples/typed-values.lisp"
TYPED_BLOB="$BUILD_DIR/typed-values.lbin"
CTRL_SRC="$LAB_DIR/samples/control-flow.lisp"
CTRL_BLOB="$BUILD_DIR/control-flow.lbin"
MULTI_SRC="$LAB_DIR/samples/multi-func.lisp"
MULTI_CTRL_SRC="$LAB_DIR/samples/multi-func-control-flow.lisp"
BAD_ARITH_SRC="$BUILD_DIR/arithmetic-bad.lisp"
BAD_ARITH_BLOB="$BUILD_DIR/arithmetic-bad.lbin"
EXIT42="$BUILD_DIR/exit42.elf"
ARITH_EXIT="$BUILD_DIR/arithmetic-aot.elf"
ARITH_CODE="$BUILD_DIR/arithmetic-code.elf"
BAD_ARITH_CODE="$BUILD_DIR/arithmetic-bad-code.elf"
CTRL_CODE="$BUILD_DIR/control-flow-code.elf"
CTRL_EXIT="$BUILD_DIR/control-flow-aot.elf"
CTRL_OBJ="$BUILD_DIR/control_flow_obj.o"
CTRL_OBJ_C="$BUILD_DIR/control_flow_main.c"
CTRL_OBJ_EXE="$BUILD_DIR/control_flow_obj"
CTRL_CODE_OBJ="$BUILD_DIR/control_flow_code_obj.o"
CTRL_CODE_OBJ_C="$BUILD_DIR/control_flow_code_main.c"
CTRL_CODE_OBJ_EXE="$BUILD_DIR/control_flow_code_obj"
CTRL_LINK_EXE="$BUILD_DIR/control_flow_linked"
CTRL_DIRECT_EXE="$BUILD_DIR/control_flow_direct"
MULTI_OBJ="$BUILD_DIR/multi_func.o"
MULTI_C="$BUILD_DIR/multi_func_main.c"
MULTI_EXE="$BUILD_DIR/multi_func"
MULTI_LINK_EXE="$BUILD_DIR/multi_func_linked"
MULTI_CTRL_OBJ="$BUILD_DIR/multi_func_control.o"
MULTI_CTRL_C="$BUILD_DIR/multi_func_control_main.c"
MULTI_CTRL_EXE="$BUILD_DIR/multi_func_control"
MULTI_CTRL_LINK_EXE="$BUILD_DIR/multi_func_control_linked"
RET42_OBJ="$BUILD_DIR/nano_ret42.o"
RET42_C="$BUILD_DIR/nano_ret42_main.c"
RET42_EXE="$BUILD_DIR/nano_ret42"
ARITH_OBJ="$BUILD_DIR/arithmetic_obj.o"
ARITH_OBJ_C="$BUILD_DIR/arithmetic_obj_main.c"
ARITH_OBJ_EXE="$BUILD_DIR/arithmetic_obj"
ARITH_CODE_OBJ="$BUILD_DIR/arithmetic_code_obj.o"
ARITH_CODE_OBJ_C="$BUILD_DIR/arithmetic_code_obj_main.c"
ARITH_CODE_OBJ_EXE="$BUILD_DIR/arithmetic_code_obj"
ARITH_LINK_EXE="$BUILD_DIR/arithmetic_linked"
ARITH_DIRECT_EXE="$BUILD_DIR/arithmetic_direct"
ARITH_DIRECT_OBJ="$BUILD_DIR/arithmetic_direct.o"
ARITH_DIRECT_OBJ_C="$BUILD_DIR/arithmetic_direct_main.c"
ARITH_DIRECT_OBJ_EXE="$BUILD_DIR/arithmetic_direct_obj"
CALL42_OBJ="$BUILD_DIR/nano_call42.o"
CALL42_CALLEE_OBJ="$BUILD_DIR/nano_ext42.o"
CALL42_LINK_EXE="$BUILD_DIR/nano_call42_linked"
DUP42_OBJ="$BUILD_DIR/nano_dup42.o"
CALL42_C="$BUILD_DIR/nano_call42_main.c"
CALL42_EXE="$BUILD_DIR/nano_call42"
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
cat > "$BAD_ARITH_SRC" <<'EOF'
(module
  (main
    (u64 40)
    (add-u64 2)
    (expect 43)))
EOF
cat > "$RET42_C" <<'EOF'
extern int nano_ret(void);
int main(void) {
  return nano_ret();
}
EOF
cat > "$ARITH_OBJ_C" <<'EOF'
extern int nano_arith(void);
int main(void) {
  return nano_arith();
}
EOF
cat > "$ARITH_CODE_OBJ_C" <<'EOF'
extern int nano_arith_code(void);
int main(void) {
  return nano_arith_code();
}
EOF
cat > "$ARITH_DIRECT_OBJ_C" <<'EOF'
extern int nano_arith_direct(void);
int main(void) {
  return nano_arith_direct();
}
EOF
cat > "$CALL42_C" <<'EOF'
int nano_ext(void) {
  return 42;
}
extern int nano_call(void);
int main(void) {
  return nano_call();
}
EOF
cat > "$CTRL_OBJ_C" <<'EOF'
extern int nano_ctrl(void);
int main(void) {
  return nano_ctrl();
}
EOF
cat > "$CTRL_CODE_OBJ_C" <<'EOF'
extern int nano_ctrl_code(void);
int main(void) {
  return nano_ctrl_code();
}
EOF
cat > "$MULTI_C" <<'EOF'
extern int nano_multi_entry(void);
int main(void) {
  return nano_multi_entry();
}
EOF
cat > "$MULTI_CTRL_C" <<'EOF'
extern int nano_multi_ctrl(void);
int main(void) {
  return nano_multi_ctrl();
}
EOF
cat > "$BOOTSTRAP_PLAN" <<EOF
(bootstrap
  (compile "$SMOKE_SRC" "$BUILD_DIR/bootstrap-smoke.lbin")
  (hash "$BUILD_DIR/bootstrap-smoke.lbin")
  (compile "$SMOKE_SRC" "$BUILD_DIR/bootstrap-smoke-repeat.lbin")
  (compare "$BUILD_DIR/bootstrap-smoke.lbin" "$BUILD_DIR/bootstrap-smoke-repeat.lbin")
  (pack-app "$BUILD_DIR/bootstrap-smoke.com" "$BUILD_DIR/nano-jit.x86_64" "$BUILD_DIR/nano-jit.aarch64" "$BUILD_DIR/bootstrap-smoke.lbin")
  (inspect-app "$BUILD_DIR/bootstrap-smoke.com")
  (run "$BUILD_DIR/bootstrap-smoke.lbin")
  (compile "$ARITH_SRC" "$BUILD_DIR/bootstrap-aot-arithmetic.lbin")
  (aot-elf64-exit "$BUILD_DIR/bootstrap-aot-arithmetic.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-exit.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-exit.elf" 42)
  (aot-elf64-code "$BUILD_DIR/bootstrap-aot-arithmetic.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-code.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-code.elf" 42)
  (compile-elf64-code "$CTRL_SRC" "$BUILD_DIR/bootstrap-aot-control-flow.elf")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-control-flow.elf" 1)
  (aot-elf64-obj-ret "$BUILD_DIR/bootstrap-aot-arithmetic.lbin" "$BUILD_DIR/bootstrap-aot-arithmetic-ret.o" "nano_bootstrap_arith_ret")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-arithmetic-ret-linked" "nano_bootstrap_arith_ret" "$BUILD_DIR/bootstrap-aot-arithmetic-ret.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-arithmetic-ret-linked" 42)
  (compile-elf64-obj-code "$MULTI_CTRL_SRC" "$BUILD_DIR/bootstrap-aot-multi-ctrl.o" "nano_bootstrap_multi_ctrl")
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-multi-ctrl-linked" "nano_bootstrap_multi_ctrl" "$BUILD_DIR/bootstrap-aot-multi-ctrl.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-multi-ctrl-linked" 43)
  (emit-elf64-obj-call "$BUILD_DIR/bootstrap-aot-call42.o" "nano_bootstrap_call" "nano_bootstrap_ext")
  (emit-elf64-obj-ret "$BUILD_DIR/bootstrap-aot-ext42.o" "nano_bootstrap_ext" 42)
  (link-elf64-exe "$BUILD_DIR/bootstrap-aot-call42-linked" "nano_bootstrap_call" "$BUILD_DIR/bootstrap-aot-call42.o" "$BUILD_DIR/bootstrap-aot-ext42.o")
  (run-expect-exit "$BUILD_DIR/bootstrap-aot-call42-linked" 42))
EOF

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
run_case "nano-jit-compile-arithmetic" "$BUILD_DIR/nano-jit.com" compile "$ARITH_SRC" "$ARITH_BLOB"
run_case "nano-jit-run-arithmetic" "$BUILD_DIR/nano-jit.com" run "$ARITH_BLOB"
run_case "nano-jit-compile-typed-values" "$BUILD_DIR/nano-jit.com" compile "$TYPED_SRC" "$TYPED_BLOB"
run_case "nano-jit-run-typed-values" "$BUILD_DIR/nano-jit.com" run "$TYPED_BLOB"
run_case "nano-jit-run-bootstrap-plan" "$BUILD_DIR/nano-jit.com" run-bootstrap-plan "$BOOTSTRAP_PLAN"
run_case "nano-jit-compile-control-flow" "$BUILD_DIR/nano-jit.com" compile "$CTRL_SRC" "$CTRL_BLOB"
run_case "nano-jit-run-control-flow" "$BUILD_DIR/nano-jit.com" run "$CTRL_BLOB"
run_case "nano-jit-emit-elf64-exit42" "$BUILD_DIR/nano-jit.com" emit-elf64-exit "$EXIT42" 42
run_case "nano-jit-run-elf64-exit42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$EXIT42"
run_case "nano-jit-aot-arithmetic-elf64-exit42" "$BUILD_DIR/nano-jit.com" aot-elf64-exit "$ARITH_BLOB" "$ARITH_EXIT"
run_case "nano-jit-run-aot-arithmetic-exit42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_EXIT"
run_case "nano-jit-aot-arithmetic-elf64-code42" "$BUILD_DIR/nano-jit.com" aot-elf64-code "$ARITH_BLOB" "$ARITH_CODE"
run_case "nano-jit-run-aot-arithmetic-code42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_CODE"
run_case "nano-jit-compile-bad-arithmetic" "$BUILD_DIR/nano-jit.com" compile "$BAD_ARITH_SRC" "$BAD_ARITH_BLOB"
run_case "nano-jit-aot-bad-arithmetic-elf64-code" "$BUILD_DIR/nano-jit.com" aot-elf64-code "$BAD_ARITH_BLOB" "$BAD_ARITH_CODE"
run_case "nano-jit-run-aot-bad-arithmetic-expect125" bash -c '"$1"; status=$?; test "$status" -eq 125' _ "$BAD_ARITH_CODE"
run_case "nano-jit-aot-control-flow-elf64-exit1" "$BUILD_DIR/nano-jit.com" aot-elf64-exit "$CTRL_BLOB" "$CTRL_EXIT"
run_case "nano-jit-run-aot-control-flow-exit1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_EXIT"
run_case "nano-jit-aot-control-flow-elf64-obj-ret1" "$BUILD_DIR/nano-jit.com" aot-elf64-obj-ret "$CTRL_BLOB" "$CTRL_OBJ" nano_ctrl
run_case "nano-jit-link-aot-control-flow-obj1" cc "$CTRL_OBJ_C" "$CTRL_OBJ" -o "$CTRL_OBJ_EXE"
run_case "nano-jit-run-aot-control-flow-obj1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_OBJ_EXE"
run_case "nano-jit-aot-control-flow-elf64-code1" "$BUILD_DIR/nano-jit.com" aot-elf64-code "$CTRL_BLOB" "$CTRL_CODE"
run_case "nano-jit-run-aot-control-flow-code1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_CODE"
run_case "nano-jit-aot-control-flow-elf64-obj-code1" "$BUILD_DIR/nano-jit.com" aot-elf64-obj-code "$CTRL_BLOB" "$CTRL_CODE_OBJ" nano_ctrl_code
run_case "nano-jit-link-aot-control-flow-obj-code1" cc "$CTRL_CODE_OBJ_C" "$CTRL_CODE_OBJ" -o "$CTRL_CODE_OBJ_EXE"
run_case "nano-jit-run-aot-control-flow-obj-code1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_CODE_OBJ_EXE"
run_case "nano-jit-tiny-link-aot-control-flow-obj-code1" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$CTRL_LINK_EXE" nano_ctrl_code "$CTRL_CODE_OBJ"
run_case "nano-jit-run-tiny-linked-control-flow1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_LINK_EXE"
run_case "nano-jit-compile-control-flow-elf64-code1" "$BUILD_DIR/nano-jit.com" compile-elf64-code "$CTRL_SRC" "$CTRL_DIRECT_EXE"
run_case "nano-jit-run-direct-compiled-control-flow1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_DIRECT_EXE"
run_case "nano-jit-emit-elf64-obj-ret42" "$BUILD_DIR/nano-jit.com" emit-elf64-obj-ret "$RET42_OBJ" nano_ret 42
run_case "nano-jit-link-elf64-obj-ret42" cc "$RET42_C" "$RET42_OBJ" -o "$RET42_EXE"
run_case "nano-jit-run-elf64-obj-ret42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$RET42_EXE"
run_case "nano-jit-aot-arithmetic-elf64-obj-ret42" "$BUILD_DIR/nano-jit.com" aot-elf64-obj-ret "$ARITH_BLOB" "$ARITH_OBJ" nano_arith
run_case "nano-jit-link-aot-arithmetic-obj-ret42" cc "$ARITH_OBJ_C" "$ARITH_OBJ" -o "$ARITH_OBJ_EXE"
run_case "nano-jit-run-aot-arithmetic-obj-ret42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_OBJ_EXE"
run_case "nano-jit-aot-arithmetic-elf64-obj-code42" "$BUILD_DIR/nano-jit.com" aot-elf64-obj-code "$ARITH_BLOB" "$ARITH_CODE_OBJ" nano_arith_code
run_case "nano-jit-link-aot-arithmetic-obj-code42" cc "$ARITH_CODE_OBJ_C" "$ARITH_CODE_OBJ" -o "$ARITH_CODE_OBJ_EXE"
run_case "nano-jit-run-aot-arithmetic-obj-code42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_CODE_OBJ_EXE"
run_case "nano-jit-tiny-link-aot-arithmetic-obj-code42" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$ARITH_LINK_EXE" nano_arith_code "$ARITH_CODE_OBJ"
run_case "nano-jit-run-tiny-linked-arithmetic42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_LINK_EXE"
run_case "nano-jit-compile-arithmetic-elf64-code42" "$BUILD_DIR/nano-jit.com" compile-elf64-code "$ARITH_SRC" "$ARITH_DIRECT_EXE"
run_case "nano-jit-run-direct-compiled-arithmetic42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_DIRECT_EXE"
run_case "nano-jit-compile-arithmetic-elf64-obj-code42" "$BUILD_DIR/nano-jit.com" compile-elf64-obj-code "$ARITH_SRC" "$ARITH_DIRECT_OBJ" nano_arith_direct
run_case "nano-jit-link-direct-compiled-arithmetic-obj42" cc "$ARITH_DIRECT_OBJ_C" "$ARITH_DIRECT_OBJ" -o "$ARITH_DIRECT_OBJ_EXE"
run_case "nano-jit-run-direct-compiled-arithmetic-obj42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_DIRECT_OBJ_EXE"
run_case "nano-jit-compile-multi-func-elf64-obj43" "$BUILD_DIR/nano-jit.com" compile-elf64-obj-code "$MULTI_SRC" "$MULTI_OBJ" nano_multi_entry
run_case "nano-jit-link-multi-func-obj43" cc "$MULTI_C" "$MULTI_OBJ" -o "$MULTI_EXE"
run_case "nano-jit-run-multi-func-obj43" bash -c '"$1"; status=$?; test "$status" -eq 43' _ "$MULTI_EXE"
run_case "nano-jit-tiny-link-multi-func-obj43" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$MULTI_LINK_EXE" nano_multi_entry "$MULTI_OBJ"
run_case "nano-jit-run-tiny-linked-multi-func43" bash -c '"$1"; status=$?; test "$status" -eq 43' _ "$MULTI_LINK_EXE"
run_case "nano-jit-compile-multi-func-control-flow-elf64-obj43" "$BUILD_DIR/nano-jit.com" compile-elf64-obj-code "$MULTI_CTRL_SRC" "$MULTI_CTRL_OBJ" nano_multi_ctrl
run_case "nano-jit-link-multi-func-control-flow-obj43" cc "$MULTI_CTRL_C" "$MULTI_CTRL_OBJ" -o "$MULTI_CTRL_EXE"
run_case "nano-jit-run-multi-func-control-flow-obj43" bash -c '"$1"; status=$?; test "$status" -eq 43' _ "$MULTI_CTRL_EXE"
run_case "nano-jit-tiny-link-multi-func-control-flow-obj43" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$MULTI_CTRL_LINK_EXE" nano_multi_ctrl "$MULTI_CTRL_OBJ"
run_case "nano-jit-run-tiny-linked-multi-func-control-flow43" bash -c '"$1"; status=$?; test "$status" -eq 43' _ "$MULTI_CTRL_LINK_EXE"
run_case "nano-jit-emit-elf64-obj-call42" "$BUILD_DIR/nano-jit.com" emit-elf64-obj-call "$CALL42_OBJ" nano_call nano_ext
run_case "nano-jit-link-elf64-obj-call42" cc "$CALL42_C" "$CALL42_OBJ" -o "$CALL42_EXE"
run_case "nano-jit-run-elf64-obj-call42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$CALL42_EXE"
run_case "nano-jit-emit-elf64-obj-callee42" "$BUILD_DIR/nano-jit.com" emit-elf64-obj-ret "$CALL42_CALLEE_OBJ" nano_ext 42
run_case "nano-jit-tiny-link-elf64-obj-call42" "$BUILD_DIR/nano-jit.com" link-elf64-exe "$CALL42_LINK_EXE" nano_call "$CALL42_OBJ" "$CALL42_CALLEE_OBJ"
run_case "nano-jit-run-tiny-linked-call42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$CALL42_LINK_EXE"
run_case "nano-jit-emit-elf64-obj-duplicate-nano-ext" "$BUILD_DIR/nano-jit.com" emit-elf64-obj-ret "$DUP42_OBJ" nano_ext 7
run_case "nano-jit-tiny-link-reject-duplicate-symbol" bash -c 'if "$1" link-elf64-exe "$2" nano_call "$3" "$4" "$5"; then exit 1; else test "$?" -eq 2; fi' _ "$BUILD_DIR/nano-jit.com" "$BUILD_DIR/dup_should_fail" "$CALL42_OBJ" "$CALL42_CALLEE_OBJ" "$DUP42_OBJ"
run_case "nano-jit-compile-smoke-repeat" "$BUILD_DIR/nano-jit.com" compile "$SMOKE_SRC" "$SMOKE_BLOB_REPEAT"
run_case "nano-jit-hash-smoke" "$BUILD_DIR/nano-jit.com" hash "$SMOKE_BLOB"
run_case "nano-jit-hash-smoke-repeat" "$BUILD_DIR/nano-jit.com" hash "$SMOKE_BLOB_REPEAT"
run_case "nano-jit-compare-deterministic-smoke" cmp "$SMOKE_BLOB" "$SMOKE_BLOB_REPEAT"
run_case "nano-jit-run-smoke" "$BUILD_DIR/nano-jit.com" run "$SMOKE_BLOB"
run_case "nano-jit-pack-smoke-app" "$BUILD_DIR/nano-jit.com" pack-app \
  "$SMOKE_APP" \
  "$BUILD_DIR/nano-jit.x86_64" \
  "$BUILD_DIR/nano-jit.aarch64" \
  "$SMOKE_BLOB"
run_case "nano-jit-inspect-smoke-app" "$BUILD_DIR/nano-jit.com" inspect-app "$SMOKE_APP"
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
