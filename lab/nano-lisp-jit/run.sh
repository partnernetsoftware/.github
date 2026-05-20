#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"
BUILD_DIR="$LAB_DIR/.build"
SRC="$LAB_DIR/samples/strlen.lisp"
ARITH_SRC="$LAB_DIR/samples/arithmetic.lisp"
TYPED_SRC="$LAB_DIR/samples/typed-values.lisp"
CTRL_SRC="$LAB_DIR/samples/control-flow.lisp"
MULTI_SRC="$LAB_DIR/samples/multi-func.lisp"
MULTI_CTRL_SRC="$LAB_DIR/samples/multi-func-control-flow.lisp"
BOOTSTRAP_SRC="$LAB_DIR/samples/bootstrap-smoke.lisp"
BOOTSTRAP_AOT_SRC="$LAB_DIR/samples/bootstrap-aot-smoke.lisp"
SMOKE_SRC="$LAB_DIR/samples/libc-smoke.lisp"
BLOB="$BUILD_DIR/strlen.lbin"
BLOB_REPEAT="$BUILD_DIR/strlen-repeat.lbin"
ARITH_BLOB="$BUILD_DIR/arithmetic.lbin"
TYPED_BLOB="$BUILD_DIR/typed-values.lbin"
CTRL_BLOB="$BUILD_DIR/control-flow.lbin"
BAD_ARITH_SRC="$LAB_DIR/samples/arithmetic-bad.lisp"
BAD_ARITH_BLOB="$BUILD_DIR/arithmetic-bad.lbin"
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
SMOKE_BLOB="$BUILD_DIR/libc-smoke.lbin"
LIBC_SRC="$BUILD_DIR/libc-resolve.lisp"
LIBC_BLOB="$BUILD_DIR/libc-resolve.lbin"
EXIT42="$BUILD_DIR/exit42.elf"
ARITH_EXIT="$BUILD_DIR/arithmetic-aot.elf"
ARITH_CODE="$BUILD_DIR/arithmetic-code.elf"
BAD_ARITH_CODE="$BUILD_DIR/arithmetic-bad-code.elf"
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
RUNNER="$BUILD_DIR/nano-lisp-jit"
RESULTS="$BUILD_DIR/results.txt"
NANO_C="$ROOT_DIR/lab/lispjit-ir/lispjit.c"

mkdir -p "$BUILD_DIR"
: > "$RESULTS"
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

log() {
  printf '%s\n' "$*" | tee -a "$RESULTS"
}

bytes_of() {
  wc -c < "$1" | tr -d ' '
}

run_case() {
  local name="$1"
  shift
  log ""
  log "## $name"
  "$@" 2>&1 | tee -a "$RESULTS"
  local status="${PIPESTATUS[0]}"
  log "exit.status=$status"
  return "$status"
}

log "# nano-lisp-jit .lisp to .lbin probe"
log "source.path=$SRC"
log "source.bytes=$(bytes_of "$SRC")"
log "arithmetic.source.path=$ARITH_SRC"
log "arithmetic.source.bytes=$(bytes_of "$ARITH_SRC")"
log "typed.source.path=$TYPED_SRC"
log "typed.source.bytes=$(bytes_of "$TYPED_SRC")"
log "control.source.path=$CTRL_SRC"
log "control.source.bytes=$(bytes_of "$CTRL_SRC")"
log "multi.source.path=$MULTI_SRC"
log "multi.source.bytes=$(bytes_of "$MULTI_SRC")"
log "multi.ctrl.source.path=$MULTI_CTRL_SRC"
log "multi.ctrl.source.bytes=$(bytes_of "$MULTI_CTRL_SRC")"
log "bootstrap.source.path=$BOOTSTRAP_SRC"
log "bootstrap.source.bytes=$(bytes_of "$BOOTSTRAP_SRC")"
log "bootstrap.aot.source.path=$BOOTSTRAP_AOT_SRC"
log "bootstrap.aot.source.bytes=$(bytes_of "$BOOTSTRAP_AOT_SRC")"
log "smoke.source.path=$SMOKE_SRC"
log "smoke.source.bytes=$(bytes_of "$SMOKE_SRC")"

run_case "build-native-nano-lisp-jit" cc -DNANO_LISP_JIT -Os -s "$NANO_C" -ldl -o "$RUNNER"
log "native.runtime.bytes=$(bytes_of "$RUNNER")"

run_case "compile-lisp-to-lbin" "$RUNNER" compile "$SRC" "$BLOB"
log "blob.bytes=$(bytes_of "$BLOB")"

run_case "compile-lisp-to-lbin-repeat" "$RUNNER" compile "$SRC" "$BLOB_REPEAT"
log "blob.repeat.bytes=$(bytes_of "$BLOB_REPEAT")"

run_case "hash-lbin" "$RUNNER" hash "$BLOB"

run_case "hash-lbin-repeat" "$RUNNER" hash "$BLOB_REPEAT"

run_case "compare-deterministic-lbin" cmp "$BLOB" "$BLOB_REPEAT"

run_case "dump-lbin" "$RUNNER" dump "$BLOB"

run_case "execute-lbin-via-jit" "$RUNNER" run "$BLOB"

run_case "compile-arithmetic-lbin" "$RUNNER" compile "$ARITH_SRC" "$ARITH_BLOB"
log "arithmetic.blob.bytes=$(bytes_of "$ARITH_BLOB")"

run_case "hash-arithmetic-lbin" "$RUNNER" hash "$ARITH_BLOB"

run_case "execute-arithmetic-lbin" "$RUNNER" run "$ARITH_BLOB"

run_case "compile-typed-values-lbin" "$RUNNER" compile "$TYPED_SRC" "$TYPED_BLOB"
log "typed.blob.bytes=$(bytes_of "$TYPED_BLOB")"

run_case "execute-typed-values-lbin" "$RUNNER" run "$TYPED_BLOB"

run_case "run-bootstrap-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_SRC"

run_case "run-bootstrap-aot-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_AOT_SRC"

run_case "compile-control-flow-lbin" "$RUNNER" compile "$CTRL_SRC" "$CTRL_BLOB"
log "control.blob.bytes=$(bytes_of "$CTRL_BLOB")"

run_case "execute-control-flow-lbin" "$RUNNER" run "$CTRL_BLOB"

if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ]; then
  run_case "emit-elf64-exit42" "$RUNNER" emit-elf64-exit "$EXIT42" 42
  log "exit42.bytes=$(bytes_of "$EXIT42")"
  run_case "run-elf64-exit42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$EXIT42"
  run_case "aot-arithmetic-elf64-exit42" "$RUNNER" aot-elf64-exit "$ARITH_BLOB" "$ARITH_EXIT"
  log "arithmetic.aot.bytes=$(bytes_of "$ARITH_EXIT")"
  run_case "run-aot-arithmetic-exit42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_EXIT"
  run_case "aot-arithmetic-elf64-code42" "$RUNNER" aot-elf64-code "$ARITH_BLOB" "$ARITH_CODE"
  log "arithmetic.codegen.bytes=$(bytes_of "$ARITH_CODE")"
  run_case "run-aot-arithmetic-code42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_CODE"
  run_case "compile-bad-arithmetic-lbin" "$RUNNER" compile "$BAD_ARITH_SRC" "$BAD_ARITH_BLOB"
  run_case "aot-bad-arithmetic-elf64-code" "$RUNNER" aot-elf64-code "$BAD_ARITH_BLOB" "$BAD_ARITH_CODE"
  run_case "run-aot-bad-arithmetic-expect125" bash -c '"$1"; status=$?; test "$status" -eq 125' _ "$BAD_ARITH_CODE"
  run_case "aot-control-flow-elf64-exit1" "$RUNNER" aot-elf64-exit "$CTRL_BLOB" "$CTRL_EXIT"
  run_case "run-aot-control-flow-exit1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_EXIT"
  run_case "aot-control-flow-elf64-obj-ret1" "$RUNNER" aot-elf64-obj-ret "$CTRL_BLOB" "$CTRL_OBJ" nano_ctrl
  run_case "link-aot-control-flow-obj1" cc "$CTRL_OBJ_C" "$CTRL_OBJ" -o "$CTRL_OBJ_EXE"
  run_case "run-aot-control-flow-obj1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_OBJ_EXE"
  run_case "aot-control-flow-elf64-code1" "$RUNNER" aot-elf64-code "$CTRL_BLOB" "$CTRL_CODE"
  run_case "run-aot-control-flow-code1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_CODE"
  run_case "aot-control-flow-elf64-obj-code1" "$RUNNER" aot-elf64-obj-code "$CTRL_BLOB" "$CTRL_CODE_OBJ" nano_ctrl_code
  run_case "link-aot-control-flow-obj-code1" cc "$CTRL_CODE_OBJ_C" "$CTRL_CODE_OBJ" -o "$CTRL_CODE_OBJ_EXE"
  run_case "run-aot-control-flow-obj-code1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_CODE_OBJ_EXE"
  run_case "tiny-link-aot-control-flow-obj-code1" "$RUNNER" link-elf64-exe "$CTRL_LINK_EXE" nano_ctrl_code "$CTRL_CODE_OBJ"
  run_case "run-tiny-linked-control-flow1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_LINK_EXE"
  run_case "compile-control-flow-elf64-code1" "$RUNNER" compile-elf64-code "$CTRL_SRC" "$CTRL_DIRECT_EXE"
  run_case "run-direct-compiled-control-flow1" bash -c '"$1"; status=$?; test "$status" -eq 1' _ "$CTRL_DIRECT_EXE"
  run_case "emit-elf64-obj-ret42" "$RUNNER" emit-elf64-obj-ret "$RET42_OBJ" nano_ret 42
  log "ret42.obj.bytes=$(bytes_of "$RET42_OBJ")"
  run_case "link-elf64-obj-ret42" cc "$RET42_C" "$RET42_OBJ" -o "$RET42_EXE"
  run_case "run-elf64-obj-ret42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$RET42_EXE"
  run_case "aot-arithmetic-elf64-obj-ret42" "$RUNNER" aot-elf64-obj-ret "$ARITH_BLOB" "$ARITH_OBJ" nano_arith
  log "arithmetic.obj.bytes=$(bytes_of "$ARITH_OBJ")"
  run_case "link-aot-arithmetic-obj-ret42" cc "$ARITH_OBJ_C" "$ARITH_OBJ" -o "$ARITH_OBJ_EXE"
  run_case "run-aot-arithmetic-obj-ret42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_OBJ_EXE"
  run_case "aot-arithmetic-elf64-obj-code42" "$RUNNER" aot-elf64-obj-code "$ARITH_BLOB" "$ARITH_CODE_OBJ" nano_arith_code
  log "arithmetic.code.obj.bytes=$(bytes_of "$ARITH_CODE_OBJ")"
  run_case "link-aot-arithmetic-obj-code42" cc "$ARITH_CODE_OBJ_C" "$ARITH_CODE_OBJ" -o "$ARITH_CODE_OBJ_EXE"
  run_case "run-aot-arithmetic-obj-code42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_CODE_OBJ_EXE"
  run_case "tiny-link-aot-arithmetic-obj-code42" "$RUNNER" link-elf64-exe "$ARITH_LINK_EXE" nano_arith_code "$ARITH_CODE_OBJ"
  log "arithmetic.tiny.link.bytes=$(bytes_of "$ARITH_LINK_EXE")"
  run_case "run-tiny-linked-arithmetic42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_LINK_EXE"
  run_case "compile-arithmetic-elf64-code42" "$RUNNER" compile-elf64-code "$ARITH_SRC" "$ARITH_DIRECT_EXE"
  log "arithmetic.direct.bytes=$(bytes_of "$ARITH_DIRECT_EXE")"
  run_case "run-direct-compiled-arithmetic42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_DIRECT_EXE"
  run_case "compile-arithmetic-elf64-obj-code42" "$RUNNER" compile-elf64-obj-code "$ARITH_SRC" "$ARITH_DIRECT_OBJ" nano_arith_direct
  run_case "link-direct-compiled-arithmetic-obj42" cc "$ARITH_DIRECT_OBJ_C" "$ARITH_DIRECT_OBJ" -o "$ARITH_DIRECT_OBJ_EXE"
  run_case "run-direct-compiled-arithmetic-obj42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$ARITH_DIRECT_OBJ_EXE"
  run_case "compile-multi-func-elf64-obj43" "$RUNNER" compile-elf64-obj-code "$MULTI_SRC" "$MULTI_OBJ" nano_multi_entry
  log "multi.obj.bytes=$(bytes_of "$MULTI_OBJ")"
  run_case "link-multi-func-obj43" cc "$MULTI_C" "$MULTI_OBJ" -o "$MULTI_EXE"
  run_case "run-multi-func-obj43" bash -c '"$1"; status=$?; test "$status" -eq 43' _ "$MULTI_EXE"
  run_case "tiny-link-multi-func-obj43" "$RUNNER" link-elf64-exe "$MULTI_LINK_EXE" nano_multi_entry "$MULTI_OBJ"
  log "multi.tiny.link.bytes=$(bytes_of "$MULTI_LINK_EXE")"
  run_case "run-tiny-linked-multi-func43" bash -c '"$1"; status=$?; test "$status" -eq 43' _ "$MULTI_LINK_EXE"
  run_case "compile-multi-func-control-flow-elf64-obj43" "$RUNNER" compile-elf64-obj-code "$MULTI_CTRL_SRC" "$MULTI_CTRL_OBJ" nano_multi_ctrl
  log "multi.ctrl.obj.bytes=$(bytes_of "$MULTI_CTRL_OBJ")"
  run_case "link-multi-func-control-flow-obj43" cc "$MULTI_CTRL_C" "$MULTI_CTRL_OBJ" -o "$MULTI_CTRL_EXE"
  run_case "run-multi-func-control-flow-obj43" bash -c '"$1"; status=$?; test "$status" -eq 43' _ "$MULTI_CTRL_EXE"
  run_case "tiny-link-multi-func-control-flow-obj43" "$RUNNER" link-elf64-exe "$MULTI_CTRL_LINK_EXE" nano_multi_ctrl "$MULTI_CTRL_OBJ"
  log "multi.ctrl.tiny.link.bytes=$(bytes_of "$MULTI_CTRL_LINK_EXE")"
  run_case "run-tiny-linked-multi-func-control-flow43" bash -c '"$1"; status=$?; test "$status" -eq 43' _ "$MULTI_CTRL_LINK_EXE"
  run_case "emit-elf64-obj-call42" "$RUNNER" emit-elf64-obj-call "$CALL42_OBJ" nano_call nano_ext
  log "call42.obj.bytes=$(bytes_of "$CALL42_OBJ")"
  run_case "link-elf64-obj-call42" cc "$CALL42_C" "$CALL42_OBJ" -o "$CALL42_EXE"
  run_case "run-elf64-obj-call42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$CALL42_EXE"
  run_case "emit-elf64-obj-callee42" "$RUNNER" emit-elf64-obj-ret "$CALL42_CALLEE_OBJ" nano_ext 42
  run_case "tiny-link-elf64-obj-call42" "$RUNNER" link-elf64-exe "$CALL42_LINK_EXE" nano_call "$CALL42_OBJ" "$CALL42_CALLEE_OBJ"
  log "call42.tiny.link.bytes=$(bytes_of "$CALL42_LINK_EXE")"
  run_case "run-tiny-linked-call42" bash -c '"$1"; status=$?; test "$status" -eq 42' _ "$CALL42_LINK_EXE"
  run_case "emit-elf64-obj-duplicate-nano-ext" "$RUNNER" emit-elf64-obj-ret "$DUP42_OBJ" nano_ext 7
  run_case "tiny-link-reject-duplicate-symbol" bash -c 'if "$1" link-elf64-exe "$2" nano_call "$3" "$4" "$5"; then exit 1; else test "$?" -eq 2; fi' _ "$RUNNER" "$BUILD_DIR/dup_should_fail" "$CALL42_OBJ" "$CALL42_CALLEE_OBJ" "$DUP42_OBJ"
else
  log ""
  log "## run-elf64-exit42"
  log "skip: host is not x86_64"
fi

run_case "compile-libc-smoke-lbin" "$RUNNER" compile "$SMOKE_SRC" "$SMOKE_BLOB"
log "smoke.blob.bytes=$(bytes_of "$SMOKE_BLOB")"

run_case "dump-libc-smoke-lbin" "$RUNNER" dump "$SMOKE_BLOB"

run_case "execute-libc-smoke-lbin" "$RUNNER" run "$SMOKE_BLOB"

if command -v nm >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  run_case "generate-libc-resolve-manifest" python3 "$LAB_DIR/gen_libc_resolve.py" "$LIBC_SRC"
  run_case "compile-libc-resolve-lbin" "$RUNNER" compile "$LIBC_SRC" "$LIBC_BLOB"
  log "libc.resolve.blob.bytes=$(bytes_of "$LIBC_BLOB")"
  run_case "resolve-libc-imports" "$RUNNER" resolve --quiet "$LIBC_BLOB"
else
  log ""
  log "## resolve-libc-imports"
  log "skip: need python3 and nm"
fi

log ""
log "results.file=$RESULTS"
