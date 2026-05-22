#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"
BUILD_DIR="$LAB_DIR/.build"
SRC="$LAB_DIR/samples/strlen.lisp"
ARITH_SRC="$LAB_DIR/samples/arithmetic.lisp"
ARITH_I64_SRC="$LAB_DIR/samples/arithmetic-i64.lisp"
TYPED_SRC="$LAB_DIR/samples/typed-values.lisp"
PTR_SRC="$LAB_DIR/samples/ptr-values.lisp"
CONST_PTR_SRC="$LAB_DIR/samples/const-ptr-load-u8.lisp"
CTRL_SRC="$LAB_DIR/samples/control-flow.lisp"
MULTI_SRC="$LAB_DIR/samples/multi-func.lisp"
MULTI_CTRL_SRC="$LAB_DIR/samples/multi-func-control-flow.lisp"
MULTI_PTR_SRC="$LAB_DIR/samples/multi-func-ptr.lisp"
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
BOOTSTRAP_SRC="$LAB_DIR/samples/bootstrap-smoke.lisp"
BOOTSTRAP_AOT_SRC="$LAB_DIR/samples/bootstrap-aot-smoke.lisp"
BOOTSTRAP_APE_SRC="$LAB_DIR/samples/bootstrap-ape-smoke.lisp"
BOOTSTRAP_APE_COM="$BUILD_DIR/bootstrap-ape.com"
BOOTSTRAP_APE_BAD_CONTAINER="$BUILD_DIR/bootstrap-ape-bad-container.com"
BOOTSTRAP_APE_BAD_OFFSET="$BUILD_DIR/bootstrap-ape-bad-offset.com"
BOOTSTRAP_APE_MISSING_KEY="$BUILD_DIR/bootstrap-ape-missing-key.com"
BOOTSTRAP_APE_BAD_HASH="$BUILD_DIR/bootstrap-ape-bad-hash.com"
BOOTSTRAP_APE_BAD_ARCH="$BUILD_DIR/bootstrap-ape-bad-arch.com"
BOOTSTRAP_APE_MISSING_OS="$BUILD_DIR/bootstrap-ape-missing-os.com"
SMOKE_SRC="$LAB_DIR/samples/libc-smoke.lisp"
BLOB="$BUILD_DIR/strlen.lbin"
BLOB_REPEAT="$BUILD_DIR/strlen-repeat.lbin"
ARITH_BLOB="$BUILD_DIR/arithmetic.lbin"
ARITH_I64_BLOB="$BUILD_DIR/arithmetic-i64.lbin"
TYPED_BLOB="$BUILD_DIR/typed-values.lbin"
PTR_BLOB="$BUILD_DIR/ptr-values.lbin"
CONST_PTR_BLOB="$BUILD_DIR/const-ptr-load-u8.lbin"
CTRL_BLOB="$BUILD_DIR/control-flow.lbin"
BAD_ARITH_SRC="$LAB_DIR/samples/arithmetic-bad.lisp"
BAD_ARITH_BLOB="$BUILD_DIR/arithmetic-bad.lbin"
CTRL_CODE="$BUILD_DIR/control-flow-code.elf"
CTRL_EXIT="$BUILD_DIR/control-flow-aot.elf"
CTRL_OBJ="$BUILD_DIR/control_flow_obj.o"
CTRL_OBJ_EXE="$BUILD_DIR/control_flow_obj"
CTRL_CODE_OBJ="$BUILD_DIR/control_flow_code_obj.o"
CTRL_LINK_EXE="$BUILD_DIR/control_flow_linked"
CTRL_DIRECT_EXE="$BUILD_DIR/control_flow_direct"
PTR_EXIT="$BUILD_DIR/ptr-values-aot.elf"
PTR_CODE="$BUILD_DIR/ptr-values-code.elf"
PTR_CODE_OBJ="$BUILD_DIR/ptr_values_code_obj.o"
PTR_LINK_EXE="$BUILD_DIR/ptr_values_linked"
PTR_DIRECT_EXE="$BUILD_DIR/ptr_values_direct"
CONST_PTR_EXIT="$BUILD_DIR/const_ptr_load_u8_aot.elf"
CONST_PTR_CODE="$BUILD_DIR/const_ptr_load_u8_code.elf"
CONST_PTR_CODE_OBJ="$BUILD_DIR/const_ptr_load_u8_code.o"
CONST_PTR_LINK_EXE="$BUILD_DIR/const_ptr_load_u8_linked"
CONST_PTR_DIRECT_EXE="$BUILD_DIR/const_ptr_load_u8_direct"
CONST_PTR_BAD_RELOC_OBJ="$BUILD_DIR/const_ptr_bad_reloc.o"
CONST_PTR_BAD_SHNDX_OBJ="$BUILD_DIR/const_ptr_bad_shndx.o"
CONST_PTR_BAD_FLAGS_OBJ="$BUILD_DIR/const_ptr_bad_flags.o"
CONST_PTR_BAD_RELA_LINK_OBJ="$BUILD_DIR/const_ptr_bad_rela_link.o"
CONST_PTR_BAD_SYMTAB_ORDER_OBJ="$BUILD_DIR/const_ptr_bad_symtab_order.o"
CONST_PTR_BAD_LINK_EXE="$BUILD_DIR/const_ptr_bad_linked"
MULTI_OBJ="$BUILD_DIR/multi_func.o"
MULTI_LINK_EXE="$BUILD_DIR/multi_func_linked"
MULTI_CTRL_OBJ="$BUILD_DIR/multi_func_control.o"
MULTI_CTRL_LINK_EXE="$BUILD_DIR/multi_func_control_linked"
MULTI_PTR_OBJ="$BUILD_DIR/multi_func_ptr.o"
MULTI_PTR_LINK_EXE="$BUILD_DIR/multi_func_ptr_linked"
MULTI_PTR_DIRECT_EXE="$BUILD_DIR/multi_func_ptr_direct"
TYPE_BAD_PTR_OP_EXE="$BUILD_DIR/type_error_ptr_op_bad"
TYPE_BAD_PTR_OP_OBJ="$BUILD_DIR/type_error_ptr_op_bad.o"
TYPE_BAD_ADD_PTR_OBJ="$BUILD_DIR/type_error_add_ptr_bad.o"
TYPE_BAD_SUB_PTR_OBJ="$BUILD_DIR/type_error_sub_ptr_bad.o"
TYPE_BAD_PTR_TO_U64_EXE="$BUILD_DIR/type_error_ptr_to_u64_bad"
TYPE_BAD_PTR_TO_U64_OBJ="$BUILD_DIR/type_error_ptr_to_u64_bad.o"
TYPE_BAD_U64_TO_PTR_EXE="$BUILD_DIR/type_error_u64_to_ptr_bad"
TYPE_BAD_U64_TO_PTR_OBJ="$BUILD_DIR/type_error_u64_to_ptr_bad.o"
TYPE_BAD_LOAD_U8_EXE="$BUILD_DIR/type_error_load_u8_bad"
TYPE_BAD_LOAD_U8_OBJ="$BUILD_DIR/type_error_load_u8_bad.o"
TYPE_BAD_LOAD_U16_EXE="$BUILD_DIR/type_error_load_u16_bad"
TYPE_BAD_LOAD_U16_OBJ="$BUILD_DIR/type_error_load_u16_bad.o"
TYPE_BAD_LOAD_U32_EXE="$BUILD_DIR/type_error_load_u32_bad"
TYPE_BAD_LOAD_U32_OBJ="$BUILD_DIR/type_error_load_u32_bad.o"
TYPE_BAD_STORE_U8_EXE="$BUILD_DIR/type_error_store_u8_bad"
TYPE_BAD_STORE_U8_OBJ="$BUILD_DIR/type_error_store_u8_bad.o"
TYPE_BAD_STORE_U8_RANGE_EXE="$BUILD_DIR/type_error_store_u8_range_bad"
TYPE_BAD_STORE_U8_RANGE_OBJ="$BUILD_DIR/type_error_store_u8_range_bad.o"
TYPE_BAD_STORE_U16_EXE="$BUILD_DIR/type_error_store_u16_bad"
TYPE_BAD_STORE_U16_OBJ="$BUILD_DIR/type_error_store_u16_bad.o"
TYPE_BAD_STORE_U16_RANGE_EXE="$BUILD_DIR/type_error_store_u16_range_bad"
TYPE_BAD_STORE_U16_RANGE_OBJ="$BUILD_DIR/type_error_store_u16_range_bad.o"
TYPE_BAD_STORE_U32_EXE="$BUILD_DIR/type_error_store_u32_bad"
TYPE_BAD_STORE_U32_OBJ="$BUILD_DIR/type_error_store_u32_bad.o"
TYPE_BAD_STORE_U32_RANGE_EXE="$BUILD_DIR/type_error_store_u32_range_bad"
TYPE_BAD_STORE_U32_RANGE_OBJ="$BUILD_DIR/type_error_store_u32_range_bad.o"
TYPE_BAD_BRANCH_EXE="$BUILD_DIR/type_error_branch_bad"
TYPE_BAD_EXPECT_PTR_OBJ="$BUILD_DIR/type_error_expect_ptr_bad.o"
SMOKE_BLOB="$BUILD_DIR/libc-smoke.lbin"
LIBC_SRC="$BUILD_DIR/libc-resolve.lisp"
LIBC_BLOB="$BUILD_DIR/libc-resolve.lbin"
EXIT42="$BUILD_DIR/exit42.elf"
ARITH_EXIT="$BUILD_DIR/arithmetic-aot.elf"
ARITH_CODE="$BUILD_DIR/arithmetic-code.elf"
ARITH_I64_CODE="$BUILD_DIR/arithmetic-i64-code.elf"
BAD_ARITH_CODE="$BUILD_DIR/arithmetic-bad-code.elf"
RET42_OBJ="$BUILD_DIR/nano_ret42.o"
RET42_EXE="$BUILD_DIR/nano_ret42"
ARITH_OBJ="$BUILD_DIR/arithmetic_obj.o"
ARITH_OBJ_EXE="$BUILD_DIR/arithmetic_obj"
ARITH_CODE_OBJ="$BUILD_DIR/arithmetic_code_obj.o"
ARITH_I64_CODE_OBJ="$BUILD_DIR/arithmetic_i64_code_obj.o"
ARITH_I64_LINK_EXE="$BUILD_DIR/arithmetic_i64_linked"
ARITH_LINK_EXE="$BUILD_DIR/arithmetic_linked"
ARITH_DIRECT_EXE="$BUILD_DIR/arithmetic_direct"
ARITH_I64_DIRECT_EXE="$BUILD_DIR/arithmetic_i64_direct"
ARITH_I64_DIRECT_OBJ="$BUILD_DIR/arithmetic_i64_direct.o"
ARITH_I64_DIRECT_LINK_EXE="$BUILD_DIR/arithmetic_i64_direct_linked"
ARITH_DIRECT_OBJ="$BUILD_DIR/arithmetic_direct.o"
ARITH_DIRECT_OBJ_EXE="$BUILD_DIR/arithmetic_direct_obj"
CALL42_OBJ="$BUILD_DIR/nano_call42.o"
CALL42_CALLEE_OBJ="$BUILD_DIR/nano_ext42.o"
CALL42_LINK_EXE="$BUILD_DIR/nano_call42_linked"
CONST_PTR_CALL_OBJ="$BUILD_DIR/const_ptr_call.o"
CONST_PTR_CALLEE_OBJ="$BUILD_DIR/const_ptr_callee.o"
CONST_PTR_CROSS_LINK_EXE="$BUILD_DIR/const_ptr_cross_obj_linked"
DUP42_OBJ="$BUILD_DIR/nano_dup42.o"
RUNNER="$BUILD_DIR/nano-lisp-jit"
RESULTS="$BUILD_DIR/results.txt"
NANO_C="$ROOT_DIR/lab/lispjit-ir/lispjit.c"

mkdir -p "$BUILD_DIR"
: > "$RESULTS"

log() {
  printf '%s\n' "$*" | tee -a "$RESULTS"
}

bytes_of() {
  "$RUNNER" file-size "$1"
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

make_bad_ape_manifests() {
  python3 - "$BOOTSTRAP_APE_COM" "$BOOTSTRAP_APE_BAD_CONTAINER" \
    "$BOOTSTRAP_APE_BAD_OFFSET" "$BOOTSTRAP_APE_MISSING_KEY" \
    "$BOOTSTRAP_APE_BAD_HASH" "$BOOTSTRAP_APE_BAD_ARCH" \
    "$BOOTSTRAP_APE_MISSING_OS" <<'PY'
from pathlib import Path
import sys
import re

good, bad_container, bad_offset, missing_key, bad_hash, bad_arch, missing_os = map(Path, sys.argv[1:])
data = good.read_bytes()
bad_container.write_bytes(data.replace(
    b"# nano.container=ape-v1\n",
    b"# nano.container=app-v1\n",
))
bad_offset.write_bytes(re.sub(
    br"# nano\.slice\.aarch64\.offset=[0-9]+\n",
    b"# nano.slice.aarch64.offset=999999\n",
    data,
    count=1,
))
missing_key.write_bytes(re.sub(
    br"# nano\.slice\.aarch64\.size=[0-9]+\n",
    b"",
    data,
    count=1,
))
bad_hash.write_bytes(re.sub(
    br"# nano\.slice\.x86_64\.fnv1a64=[0-9a-f]+\n",
    b"# nano.slice.x86_64.fnv1a64=0000000000000000\n",
    data,
    count=1,
))
bad_arch.write_bytes(data.replace(
    b"# nano.slice.x86_64.arch=x86_64\n",
    b"# nano.slice.x86_64.arch=riscv64\n",
))
missing_os.write_bytes(re.sub(
    br"# nano\.slice\.x86_64\.os=linux\n",
    b"",
    data,
    count=1,
))
PY
}

make_bad_data_reloc_objs() {
  python3 - "$CONST_PTR_CODE_OBJ" "$CONST_PTR_BAD_RELOC_OBJ" "$CONST_PTR_BAD_SHNDX_OBJ" \
    "$CONST_PTR_BAD_FLAGS_OBJ" "$CONST_PTR_BAD_RELA_LINK_OBJ" "$CONST_PTR_BAD_SYMTAB_ORDER_OBJ" <<'PY'
from pathlib import Path
import struct
import sys

good, bad_reloc, bad_shndx, bad_flags, bad_rela_link, bad_symtab_order = map(Path, sys.argv[1:])
src = good.read_bytes()

def sections(data):
    shoff = struct.unpack_from("<Q", data, 40)[0]
    shentsize = struct.unpack_from("<H", data, 58)[0]
    shnum = struct.unpack_from("<H", data, 60)[0]
    shstrndx = struct.unpack_from("<H", data, 62)[0]
    shstr = data[shoff + shstrndx * shentsize: shoff + (shstrndx + 1) * shentsize]
    shstr_off = struct.unpack_from("<Q", shstr, 24)[0]
    shstr_size = struct.unpack_from("<Q", shstr, 32)[0]
    names = data[shstr_off: shstr_off + shstr_size]
    out = {}
    for i in range(shnum):
        sh = data[shoff + i * shentsize: shoff + (i + 1) * shentsize]
        name_off = struct.unpack_from("<I", sh, 0)[0]
        name = names[name_off:names.index(b"\0", name_off)].decode()
        out[name] = (i, shoff + i * shentsize, sh)
    return out, shnum

sec, shnum = sections(src)
rela_off = struct.unpack_from("<Q", sec[".rela.text"][2], 24)[0]
symtab_off = struct.unpack_from("<Q", sec[".symtab"][2], 24)[0]
text_shoff = sec[".text"][1]
rela_shoff = sec[".rela.text"][1]

bad = bytearray(src)
r_info = struct.unpack_from("<Q", bad, rela_off + 8)[0]
struct.pack_into("<Q", bad, rela_off + 8, ((r_info >> 32) << 32) | 1)
bad_reloc.write_bytes(bad)

bad = bytearray(src)
struct.pack_into("<H", bad, symtab_off + 24 + 6, shnum + 10)
bad_shndx.write_bytes(bad)

bad = bytearray(src)
struct.pack_into("<Q", bad, text_shoff + 8, 0x7)
bad_flags.write_bytes(bad)

bad = bytearray(src)
struct.pack_into("<I", bad, rela_shoff + 40, 0)
bad_rela_link.write_bytes(bad)

bad = bytearray(src)
first_sym = symtab_off + 24
second_sym = symtab_off + 48
sym1 = bytes(bad[first_sym:first_sym + 24])
sym2 = bytes(bad[second_sym:second_sym + 24])
bad[first_sym:first_sym + 24] = sym2
bad[second_sym:second_sym + 24] = sym1
bad_symtab_order.write_bytes(bad)
PY
}

expect_inspect_ape_failure() {
  local path="$1"
  local expected_msg="$2"
  local out=""
  local status=0
  out=$("$RUNNER" inspect-ape "$path" 2>&1 >/dev/null) || status=$?
  printf 'inspect-ape.path=%s\n' "$path"
  printf 'inspect-ape.status=%s\n' "$status"
  printf 'inspect-ape.stderr=%s\n' "$out"
  if [ "$status" -ne 2 ]; then
    return 1
  fi
  case "$out" in
    *"$expected_msg"*) return 0 ;;
    *) return 1 ;;
  esac
}

expect_run_ape_failure() {
  local path="$1"
  local expected_status="$2"
  local expected_msg="$3"
  local arch="${4:-}"
  local out=""
  local status=0
  if [ -n "$arch" ]; then
    out=$("$RUNNER" run-ape "$path" "$arch" 2>&1 >/dev/null) || status=$?
  else
    out=$("$RUNNER" run-ape "$path" 2>&1 >/dev/null) || status=$?
  fi
  printf 'run-ape.path=%s\n' "$path"
  if [ -n "$arch" ]; then
    printf 'run-ape.requested_arch=%s\n' "$arch"
  fi
  printf 'run-ape.status=%s\n' "$status"
  printf 'run-ape.stderr=%s\n' "$out"
  if [ "$status" -ne "$expected_status" ]; then
    return 1
  fi
  case "$out" in
    *"$expected_msg"*) return 0 ;;
    *) return 1 ;;
  esac
}

expect_link_failure() {
  local out_path="$1"
  local entry="$2"
  local obj="$3"
  local expected_status="$4"
  local expected_msg="$5"
  local out=""
  local status=0
  out=$("$RUNNER" link-elf64-exe "$out_path" "$entry" "$obj" 2>&1 >/dev/null) || status=$?
  printf 'link-failure.obj=%s\n' "$obj"
  printf 'link-failure.status=%s\n' "$status"
  printf 'link-failure.stderr=%s\n' "$out"
  if [ "$status" -ne "$expected_status" ]; then
    return 1
  fi
  case "$out" in
    *"$expected_msg"*) return 0 ;;
    *) return 1 ;;
  esac
}

expect_inspect_elf64_obj_failure() {
  local path="$1"
  local expected_msg="$2"
  local out=""
  local status=0
  out=$("$RUNNER" inspect-elf64-obj "$path" 2>&1 >/dev/null) || status=$?
  printf 'inspect-elf64-obj.path=%s\n' "$path"
  printf 'inspect-elf64-obj.status=%s\n' "$status"
  printf 'inspect-elf64-obj.stderr=%s\n' "$out"
  if [ "$status" -ne 2 ]; then
    return 1
  fi
  case "$out" in
    *"$expected_msg"*) return 0 ;;
    *) return 1 ;;
  esac
}

expect_elf64_exec_load_split() {
  local path="$1"
  local out=""
  out=$("$RUNNER" inspect-elf64-exe "$path")
  printf '%s\n' "$out"
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.load\.count=2'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.load\.0\.flags=rx'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.load\.1\.flags=rw'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.layout=split_rx_rw'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.code\.policy=rx_load_segment'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.data\.present=1'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.data\.policy=rw_load_segment'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.data\.bytes=[1-9]'
}

expect_elf64_exec_rwx_compat() {
  local path="$1"
  local out=""
  out=$("$RUNNER" inspect-elf64-exe "$path")
  printf '%s\n' "$out"
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.load\.count=1'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.load\.0\.flags=rwx'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.layout=single_rwx_compat'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.data\.present=0'
  printf '%s\n' "$out" | rg -q 'elf64\.exec\.data\.policy=none'
}

expect_elf64_obj_data_pc32() {
  local path="$1"
  local out=""
  out=$("$RUNNER" inspect-elf64-obj "$path")
  printf '%s\n' "$out"
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.section\..*\.name=\.data'
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.section\.1\.flags=ax'
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.section\..*\.flags=aw'
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.layout=section_data'
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.data\.policy=section_pc32'
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.data\.section=\.data'
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.data\.local_symbol=\.Ldata0'
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.rela\..*\.type=PC32'
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.rela\..*\.target=\.data'
  printf '%s\n' "$out" | rg -q 'elf64\.obj\.data\.bytes=[1-9]'
}

log "# nano-lisp-jit .lisp to .lbin probe"

run_case "build-native-nano-lisp-jit" cc -DNANO_LISP_JIT -Os -s "$NANO_C" -ldl -o "$RUNNER"

log "source.path=$SRC"
log "source.bytes=$(bytes_of "$SRC")"
log "arithmetic.source.path=$ARITH_SRC"
log "arithmetic.source.bytes=$(bytes_of "$ARITH_SRC")"
log "arithmetic.i64.source.path=$ARITH_I64_SRC"
log "arithmetic.i64.source.bytes=$(bytes_of "$ARITH_I64_SRC")"
log "typed.source.path=$TYPED_SRC"
log "typed.source.bytes=$(bytes_of "$TYPED_SRC")"
log "ptr.source.path=$PTR_SRC"
log "ptr.source.bytes=$(bytes_of "$PTR_SRC")"
log "const.ptr.source.path=$CONST_PTR_SRC"
log "const.ptr.source.bytes=$(bytes_of "$CONST_PTR_SRC")"
log "control.source.path=$CTRL_SRC"
log "control.source.bytes=$(bytes_of "$CTRL_SRC")"
log "multi.source.path=$MULTI_SRC"
log "multi.source.bytes=$(bytes_of "$MULTI_SRC")"
log "multi.ctrl.source.path=$MULTI_CTRL_SRC"
log "multi.ctrl.source.bytes=$(bytes_of "$MULTI_CTRL_SRC")"
log "multi.ptr.source.path=$MULTI_PTR_SRC"
log "multi.ptr.source.bytes=$(bytes_of "$MULTI_PTR_SRC")"
log "type.bad.ptr.op.source.path=$TYPE_BAD_PTR_OP_SRC"
log "type.bad.ptr.op.source.bytes=$(bytes_of "$TYPE_BAD_PTR_OP_SRC")"
log "type.bad.add.ptr.source.path=$TYPE_BAD_ADD_PTR_SRC"
log "type.bad.add.ptr.source.bytes=$(bytes_of "$TYPE_BAD_ADD_PTR_SRC")"
log "type.bad.sub.ptr.source.path=$TYPE_BAD_SUB_PTR_SRC"
log "type.bad.sub.ptr.source.bytes=$(bytes_of "$TYPE_BAD_SUB_PTR_SRC")"
log "type.bad.ptr.to.u64.source.path=$TYPE_BAD_PTR_TO_U64_SRC"
log "type.bad.ptr.to.u64.source.bytes=$(bytes_of "$TYPE_BAD_PTR_TO_U64_SRC")"
log "type.bad.u64.to.ptr.source.path=$TYPE_BAD_U64_TO_PTR_SRC"
log "type.bad.u64.to.ptr.source.bytes=$(bytes_of "$TYPE_BAD_U64_TO_PTR_SRC")"
log "type.bad.load.u8.source.path=$TYPE_BAD_LOAD_U8_SRC"
log "type.bad.load.u8.source.bytes=$(bytes_of "$TYPE_BAD_LOAD_U8_SRC")"
log "type.bad.load.u16.source.path=$TYPE_BAD_LOAD_U16_SRC"
log "type.bad.load.u16.source.bytes=$(bytes_of "$TYPE_BAD_LOAD_U16_SRC")"
log "type.bad.load.u32.source.path=$TYPE_BAD_LOAD_U32_SRC"
log "type.bad.load.u32.source.bytes=$(bytes_of "$TYPE_BAD_LOAD_U32_SRC")"
log "type.bad.store.u8.source.path=$TYPE_BAD_STORE_U8_SRC"
log "type.bad.store.u8.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U8_SRC")"
log "type.bad.store.u8.range.source.path=$TYPE_BAD_STORE_U8_RANGE_SRC"
log "type.bad.store.u8.range.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U8_RANGE_SRC")"
log "type.bad.store.u16.source.path=$TYPE_BAD_STORE_U16_SRC"
log "type.bad.store.u16.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U16_SRC")"
log "type.bad.store.u16.range.source.path=$TYPE_BAD_STORE_U16_RANGE_SRC"
log "type.bad.store.u16.range.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U16_RANGE_SRC")"
log "type.bad.store.u32.source.path=$TYPE_BAD_STORE_U32_SRC"
log "type.bad.store.u32.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U32_SRC")"
log "type.bad.store.u32.range.source.path=$TYPE_BAD_STORE_U32_RANGE_SRC"
log "type.bad.store.u32.range.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U32_RANGE_SRC")"
log "type.bad.branch.source.path=$TYPE_BAD_BRANCH_SRC"
log "type.bad.branch.source.bytes=$(bytes_of "$TYPE_BAD_BRANCH_SRC")"
log "type.bad.expect.ptr.source.path=$TYPE_BAD_EXPECT_PTR_SRC"
log "type.bad.expect.ptr.source.bytes=$(bytes_of "$TYPE_BAD_EXPECT_PTR_SRC")"
log "bootstrap.source.path=$BOOTSTRAP_SRC"
log "bootstrap.source.bytes=$(bytes_of "$BOOTSTRAP_SRC")"
log "bootstrap.aot.source.path=$BOOTSTRAP_AOT_SRC"
log "bootstrap.aot.source.bytes=$(bytes_of "$BOOTSTRAP_AOT_SRC")"
log "bootstrap.ape.source.path=$BOOTSTRAP_APE_SRC"
log "bootstrap.ape.source.bytes=$(bytes_of "$BOOTSTRAP_APE_SRC")"
log "smoke.source.path=$SMOKE_SRC"
log "smoke.source.bytes=$(bytes_of "$SMOKE_SRC")"
log "native.runtime.bytes=$(bytes_of "$RUNNER")"

run_case "compile-lisp-to-lbin" "$RUNNER" compile "$SRC" "$BLOB"
log "blob.bytes=$(bytes_of "$BLOB")"

run_case "compile-lisp-to-lbin-repeat" "$RUNNER" compile "$SRC" "$BLOB_REPEAT"
log "blob.repeat.bytes=$(bytes_of "$BLOB_REPEAT")"

run_case "hash-lbin" "$RUNNER" hash "$BLOB"

run_case "hash-lbin-repeat" "$RUNNER" hash "$BLOB_REPEAT"

run_case "compare-deterministic-lbin" "$RUNNER" compare "$BLOB" "$BLOB_REPEAT"

run_case "execute-lbin-via-jit" "$RUNNER" run "$BLOB"

run_case "compile-arithmetic-lbin" "$RUNNER" compile "$ARITH_SRC" "$ARITH_BLOB"
log "arithmetic.blob.bytes=$(bytes_of "$ARITH_BLOB")"

run_case "hash-arithmetic-lbin" "$RUNNER" hash "$ARITH_BLOB"

run_case "execute-arithmetic-lbin" "$RUNNER" run "$ARITH_BLOB"

run_case "compile-arithmetic-i64-lbin" "$RUNNER" compile "$ARITH_I64_SRC" "$ARITH_I64_BLOB"
log "arithmetic.i64.blob.bytes=$(bytes_of "$ARITH_I64_BLOB")"

run_case "execute-arithmetic-i64-lbin" "$RUNNER" run "$ARITH_I64_BLOB"

run_case "compile-typed-values-lbin" "$RUNNER" compile "$TYPED_SRC" "$TYPED_BLOB"
log "typed.blob.bytes=$(bytes_of "$TYPED_BLOB")"

run_case "execute-typed-values-lbin" "$RUNNER" run "$TYPED_BLOB"

run_case "compile-ptr-values-lbin" "$RUNNER" compile "$PTR_SRC" "$PTR_BLOB"
log "ptr.blob.bytes=$(bytes_of "$PTR_BLOB")"

run_case "execute-ptr-values-lbin" "$RUNNER" run "$PTR_BLOB"

run_case "compile-const-ptr-load-u8-lbin" "$RUNNER" compile "$CONST_PTR_SRC" "$CONST_PTR_BLOB"
log "const.ptr.blob.bytes=$(bytes_of "$CONST_PTR_BLOB")"

run_case "execute-const-ptr-load-u8-lbin" "$RUNNER" run "$CONST_PTR_BLOB"

run_case "run-bootstrap-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_SRC"

run_case "run-bootstrap-aot-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_AOT_SRC"

run_case "run-bootstrap-ape-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_APE_SRC"
run_case "run-ape-bootstrap-ape-com" "$RUNNER" run-ape-expect-exit "$BOOTSTRAP_APE_COM" 42
run_case "prepare-bad-ape-manifests" make_bad_ape_manifests
run_case "inspect-ape-reject-missing-manifest" expect_inspect_ape_failure "$BOOTSTRAP_SRC" "manifest_missing"
run_case "inspect-ape-reject-bad-container" expect_inspect_ape_failure "$BOOTSTRAP_APE_BAD_CONTAINER" "bad_container"
run_case "inspect-ape-reject-bad-offset" expect_inspect_ape_failure "$BOOTSTRAP_APE_BAD_OFFSET" "payload_bounds"
run_case "inspect-ape-reject-missing-key" expect_inspect_ape_failure "$BOOTSTRAP_APE_MISSING_KEY" "manifest_key_missing"
run_case "inspect-ape-reject-bad-hash" expect_inspect_ape_failure "$BOOTSTRAP_APE_BAD_HASH" "bad_hash"
run_case "inspect-ape-reject-bad-arch" expect_inspect_ape_failure "$BOOTSTRAP_APE_BAD_ARCH" "bad_arch"
run_case "inspect-ape-reject-missing-os" expect_inspect_ape_failure "$BOOTSTRAP_APE_MISSING_OS" "manifest_key_missing"
run_case "run-ape-reject-bad-container" expect_run_ape_failure "$BOOTSTRAP_APE_BAD_CONTAINER" 2 "bad_container"
run_case "run-ape-reject-bad-offset" expect_run_ape_failure "$BOOTSTRAP_APE_BAD_OFFSET" 2 "payload_bounds"
run_case "run-ape-reject-unsupported-arch" expect_run_ape_failure "$BOOTSTRAP_APE_COM" 126 "unsupported_arch" riscv64

run_case "compile-control-flow-lbin" "$RUNNER" compile "$CTRL_SRC" "$CTRL_BLOB"
log "control.blob.bytes=$(bytes_of "$CTRL_BLOB")"

run_case "execute-control-flow-lbin" "$RUNNER" run "$CTRL_BLOB"

if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ]; then
  run_case "emit-elf64-exit42" "$RUNNER" emit-elf64-exit "$EXIT42" 42
  log "exit42.bytes=$(bytes_of "$EXIT42")"
  run_case "run-elf64-exit42" "$RUNNER" run-expect-exit "$EXIT42" 42
  run_case "aot-arithmetic-elf64-exit42" "$RUNNER" aot-elf64-exit "$ARITH_BLOB" "$ARITH_EXIT"
  log "arithmetic.aot.bytes=$(bytes_of "$ARITH_EXIT")"
  run_case "run-aot-arithmetic-exit42" "$RUNNER" run-expect-exit "$ARITH_EXIT" 42
  run_case "aot-arithmetic-elf64-code42" "$RUNNER" aot-elf64-code "$ARITH_BLOB" "$ARITH_CODE"
  log "arithmetic.codegen.bytes=$(bytes_of "$ARITH_CODE")"
  run_case "inspect-arithmetic-code-rwx-compat" expect_elf64_exec_rwx_compat "$ARITH_CODE"
  run_case "run-aot-arithmetic-code42" "$RUNNER" run-expect-exit "$ARITH_CODE" 42
  run_case "aot-arithmetic-i64-elf64-code42" "$RUNNER" aot-elf64-code "$ARITH_I64_BLOB" "$ARITH_I64_CODE"
  run_case "run-aot-arithmetic-i64-code42" "$RUNNER" run-expect-exit "$ARITH_I64_CODE" 42
  run_case "compile-bad-arithmetic-lbin" "$RUNNER" compile "$BAD_ARITH_SRC" "$BAD_ARITH_BLOB"
  run_case "aot-bad-arithmetic-elf64-code" "$RUNNER" aot-elf64-code "$BAD_ARITH_BLOB" "$BAD_ARITH_CODE"
  run_case "run-aot-bad-arithmetic-expect125" "$RUNNER" run-expect-exit "$BAD_ARITH_CODE" 125
  run_case "aot-control-flow-elf64-exit1" "$RUNNER" aot-elf64-exit "$CTRL_BLOB" "$CTRL_EXIT"
  run_case "run-aot-control-flow-exit1" "$RUNNER" run-expect-exit "$CTRL_EXIT" 1
  run_case "aot-ptr-values-elf64-exit1" "$RUNNER" aot-elf64-exit "$PTR_BLOB" "$PTR_EXIT"
  run_case "run-aot-ptr-values-exit1" "$RUNNER" run-expect-exit "$PTR_EXIT" 1
  run_case "aot-const-ptr-load-u8-elf64-exit1" "$RUNNER" aot-elf64-exit "$CONST_PTR_BLOB" "$CONST_PTR_EXIT"
  run_case "run-aot-const-ptr-load-u8-exit1" "$RUNNER" run-expect-exit "$CONST_PTR_EXIT" 1
  run_case "aot-const-ptr-load-u8-elf64-code1" "$RUNNER" aot-elf64-code "$CONST_PTR_BLOB" "$CONST_PTR_CODE"
  run_case "inspect-aot-const-ptr-load-u8-rx-rw" expect_elf64_exec_load_split "$CONST_PTR_CODE"
  run_case "run-aot-const-ptr-load-u8-code1" "$RUNNER" run-expect-exit "$CONST_PTR_CODE" 1
  run_case "aot-const-ptr-load-u8-elf64-obj-code1" "$RUNNER" aot-elf64-obj-code "$CONST_PTR_BLOB" "$CONST_PTR_CODE_OBJ" nano_const_ptr_code
  run_case "inspect-aot-const-ptr-obj-data-pc32" expect_elf64_obj_data_pc32 "$CONST_PTR_CODE_OBJ"
  run_case "prepare-bad-data-reloc-objs" make_bad_data_reloc_objs
  run_case "inspect-elf64-obj-reject-bad-text-flags" expect_inspect_elf64_obj_failure "$CONST_PTR_BAD_FLAGS_OBJ" "bad_text_flags"
  run_case "inspect-elf64-obj-reject-bad-rela-link" expect_inspect_elf64_obj_failure "$CONST_PTR_BAD_RELA_LINK_OBJ" "bad_rela_symtab_link"
  run_case "inspect-elf64-obj-reject-bad-symtab-order" expect_inspect_elf64_obj_failure "$CONST_PTR_BAD_SYMTAB_ORDER_OBJ" "bad_symtab_order"
  run_case "link-reject-bad-object-flags" expect_link_failure "$CONST_PTR_BAD_LINK_EXE" nano_const_ptr_code "$CONST_PTR_BAD_FLAGS_OBJ" 2 "bad_text_flags"
  run_case "link-reject-bad-rela-link" expect_link_failure "$CONST_PTR_BAD_LINK_EXE" nano_const_ptr_code "$CONST_PTR_BAD_RELA_LINK_OBJ" 2 "bad_rela_symtab_link"
  run_case "link-reject-bad-symtab-order" expect_link_failure "$CONST_PTR_BAD_LINK_EXE" nano_const_ptr_code "$CONST_PTR_BAD_SYMTAB_ORDER_OBJ" 2 "bad_symtab_order"
  run_case "link-reject-unsupported-data-reloc" expect_link_failure "$CONST_PTR_BAD_LINK_EXE" nano_const_ptr_code "$CONST_PTR_BAD_RELOC_OBJ" 4 "unsupported_reloc"
  run_case "link-reject-bad-data-section-index" expect_link_failure "$CONST_PTR_BAD_LINK_EXE" nano_const_ptr_code "$CONST_PTR_BAD_SHNDX_OBJ" 4 "unsupported_local_reloc"
  run_case "tiny-link-aot-const-ptr-load-u8-obj-code1" "$RUNNER" link-elf64-exe "$CONST_PTR_LINK_EXE" nano_const_ptr_code "$CONST_PTR_CODE_OBJ"
  run_case "inspect-linked-const-ptr-load-u8-rx-rw" expect_elf64_exec_load_split "$CONST_PTR_LINK_EXE"
  run_case "run-tiny-linked-const-ptr-load-u8-1" "$RUNNER" run-expect-exit "$CONST_PTR_LINK_EXE" 1
  run_case "emit-cross-object-const-ptr-call" "$RUNNER" emit-elf64-obj-call "$CONST_PTR_CALL_OBJ" nano_const_ptr_call nano_const_ptr_callee
  run_case "aot-cross-object-const-ptr-callee" "$RUNNER" aot-elf64-obj-code "$CONST_PTR_BLOB" "$CONST_PTR_CALLEE_OBJ" nano_const_ptr_callee
  run_case "inspect-cross-object-const-ptr-callee-data-pc32" expect_elf64_obj_data_pc32 "$CONST_PTR_CALLEE_OBJ"
  run_case "tiny-link-cross-object-const-ptr-data" "$RUNNER" link-elf64-exe "$CONST_PTR_CROSS_LINK_EXE" nano_const_ptr_call "$CONST_PTR_CALL_OBJ" "$CONST_PTR_CALLEE_OBJ"
  run_case "inspect-cross-object-const-ptr-rx-rw" expect_elf64_exec_load_split "$CONST_PTR_CROSS_LINK_EXE"
  run_case "run-cross-object-const-ptr-data" "$RUNNER" run-expect-exit "$CONST_PTR_CROSS_LINK_EXE" 1
  run_case "aot-ptr-values-elf64-code1" "$RUNNER" aot-elf64-code "$PTR_BLOB" "$PTR_CODE"
  run_case "run-aot-ptr-values-code1" "$RUNNER" run-expect-exit "$PTR_CODE" 1
  run_case "aot-ptr-values-elf64-obj-code1" "$RUNNER" aot-elf64-obj-code "$PTR_BLOB" "$PTR_CODE_OBJ" nano_ptr_code
  run_case "tiny-link-aot-ptr-values-obj-code1" "$RUNNER" link-elf64-exe "$PTR_LINK_EXE" nano_ptr_code "$PTR_CODE_OBJ"
  run_case "run-tiny-linked-ptr-values1" "$RUNNER" run-expect-exit "$PTR_LINK_EXE" 1
  run_case "aot-control-flow-elf64-obj-ret1" "$RUNNER" aot-elf64-obj-ret "$CTRL_BLOB" "$CTRL_OBJ" nano_ctrl
  run_case "link-aot-control-flow-obj1" "$RUNNER" link-elf64-exe "$CTRL_OBJ_EXE" nano_ctrl "$CTRL_OBJ"
  run_case "run-aot-control-flow-obj1" "$RUNNER" run-expect-exit "$CTRL_OBJ_EXE" 1
  run_case "aot-control-flow-elf64-code1" "$RUNNER" aot-elf64-code "$CTRL_BLOB" "$CTRL_CODE"
  run_case "run-aot-control-flow-code1" "$RUNNER" run-expect-exit "$CTRL_CODE" 1
  run_case "aot-control-flow-elf64-obj-code1" "$RUNNER" aot-elf64-obj-code "$CTRL_BLOB" "$CTRL_CODE_OBJ" nano_ctrl_code
  run_case "tiny-link-aot-control-flow-obj-code1" "$RUNNER" link-elf64-exe "$CTRL_LINK_EXE" nano_ctrl_code "$CTRL_CODE_OBJ"
  run_case "run-tiny-linked-control-flow1" "$RUNNER" run-expect-exit "$CTRL_LINK_EXE" 1
  run_case "compile-control-flow-elf64-code1" "$RUNNER" compile-elf64-code "$CTRL_SRC" "$CTRL_DIRECT_EXE"
  run_case "run-direct-compiled-control-flow1" "$RUNNER" run-expect-exit "$CTRL_DIRECT_EXE" 1
  run_case "compile-ptr-values-elf64-code1" "$RUNNER" compile-elf64-code "$PTR_SRC" "$PTR_DIRECT_EXE"
  run_case "run-direct-compiled-ptr-values1" "$RUNNER" run-expect-exit "$PTR_DIRECT_EXE" 1
  run_case "compile-const-ptr-load-u8-elf64-code1" "$RUNNER" compile-elf64-code "$CONST_PTR_SRC" "$CONST_PTR_DIRECT_EXE"
  run_case "inspect-direct-const-ptr-load-u8-rx-rw" expect_elf64_exec_load_split "$CONST_PTR_DIRECT_EXE"
  run_case "run-direct-compiled-const-ptr-load-u8-1" "$RUNNER" run-expect-exit "$CONST_PTR_DIRECT_EXE" 1
  run_case "emit-elf64-obj-ret42" "$RUNNER" emit-elf64-obj-ret "$RET42_OBJ" nano_ret 42
  log "ret42.obj.bytes=$(bytes_of "$RET42_OBJ")"
  run_case "link-elf64-obj-ret42" "$RUNNER" link-elf64-exe "$RET42_EXE" nano_ret "$RET42_OBJ"
  run_case "run-elf64-obj-ret42" "$RUNNER" run-expect-exit "$RET42_EXE" 42
  run_case "aot-arithmetic-elf64-obj-ret42" "$RUNNER" aot-elf64-obj-ret "$ARITH_BLOB" "$ARITH_OBJ" nano_arith
  log "arithmetic.obj.bytes=$(bytes_of "$ARITH_OBJ")"
  run_case "link-aot-arithmetic-obj-ret42" "$RUNNER" link-elf64-exe "$ARITH_OBJ_EXE" nano_arith "$ARITH_OBJ"
  run_case "run-aot-arithmetic-obj-ret42" "$RUNNER" run-expect-exit "$ARITH_OBJ_EXE" 42
  run_case "aot-arithmetic-elf64-obj-code42" "$RUNNER" aot-elf64-obj-code "$ARITH_BLOB" "$ARITH_CODE_OBJ" nano_arith_code
  log "arithmetic.code.obj.bytes=$(bytes_of "$ARITH_CODE_OBJ")"
  run_case "tiny-link-aot-arithmetic-obj-code42" "$RUNNER" link-elf64-exe "$ARITH_LINK_EXE" nano_arith_code "$ARITH_CODE_OBJ"
  log "arithmetic.tiny.link.bytes=$(bytes_of "$ARITH_LINK_EXE")"
  run_case "run-tiny-linked-arithmetic42" "$RUNNER" run-expect-exit "$ARITH_LINK_EXE" 42
  run_case "aot-arithmetic-i64-elf64-obj-code42" "$RUNNER" aot-elf64-obj-code "$ARITH_I64_BLOB" "$ARITH_I64_CODE_OBJ" nano_arith_i64_code
  run_case "tiny-link-aot-arithmetic-i64-obj-code42" "$RUNNER" link-elf64-exe "$ARITH_I64_LINK_EXE" nano_arith_i64_code "$ARITH_I64_CODE_OBJ"
  run_case "run-tiny-linked-arithmetic-i64-42" "$RUNNER" run-expect-exit "$ARITH_I64_LINK_EXE" 42
  run_case "compile-arithmetic-elf64-code42" "$RUNNER" compile-elf64-code "$ARITH_SRC" "$ARITH_DIRECT_EXE"
  log "arithmetic.direct.bytes=$(bytes_of "$ARITH_DIRECT_EXE")"
  run_case "run-direct-compiled-arithmetic42" "$RUNNER" run-expect-exit "$ARITH_DIRECT_EXE" 42
  run_case "compile-arithmetic-i64-elf64-code42" "$RUNNER" compile-elf64-code "$ARITH_I64_SRC" "$ARITH_I64_DIRECT_EXE"
  run_case "run-direct-compiled-arithmetic-i64-42" "$RUNNER" run-expect-exit "$ARITH_I64_DIRECT_EXE" 42
  run_case "compile-arithmetic-i64-elf64-obj-code42" "$RUNNER" compile-elf64-obj-code "$ARITH_I64_SRC" "$ARITH_I64_DIRECT_OBJ" nano_arith_i64_direct
  run_case "tiny-link-direct-compiled-arithmetic-i64-obj42" "$RUNNER" link-elf64-exe "$ARITH_I64_DIRECT_LINK_EXE" nano_arith_i64_direct "$ARITH_I64_DIRECT_OBJ"
  run_case "run-tiny-linked-direct-arithmetic-i64-obj42" "$RUNNER" run-expect-exit "$ARITH_I64_DIRECT_LINK_EXE" 42
  run_case "compile-arithmetic-elf64-obj-code42" "$RUNNER" compile-elf64-obj-code "$ARITH_SRC" "$ARITH_DIRECT_OBJ" nano_arith_direct
  run_case "link-direct-compiled-arithmetic-obj42" "$RUNNER" link-elf64-exe "$ARITH_DIRECT_OBJ_EXE" nano_arith_direct "$ARITH_DIRECT_OBJ"
  run_case "run-direct-compiled-arithmetic-obj42" "$RUNNER" run-expect-exit "$ARITH_DIRECT_OBJ_EXE" 42
  run_case "compile-multi-func-elf64-obj43" "$RUNNER" compile-elf64-obj-code "$MULTI_SRC" "$MULTI_OBJ" nano_multi_entry
  log "multi.obj.bytes=$(bytes_of "$MULTI_OBJ")"
  run_case "tiny-link-multi-func-obj43" "$RUNNER" link-elf64-exe "$MULTI_LINK_EXE" nano_multi_entry "$MULTI_OBJ"
  log "multi.tiny.link.bytes=$(bytes_of "$MULTI_LINK_EXE")"
  run_case "run-tiny-linked-multi-func43" "$RUNNER" run-expect-exit "$MULTI_LINK_EXE" 43
  run_case "compile-multi-func-control-flow-elf64-obj43" "$RUNNER" compile-elf64-obj-code "$MULTI_CTRL_SRC" "$MULTI_CTRL_OBJ" nano_multi_ctrl
  log "multi.ctrl.obj.bytes=$(bytes_of "$MULTI_CTRL_OBJ")"
  run_case "tiny-link-multi-func-control-flow-obj43" "$RUNNER" link-elf64-exe "$MULTI_CTRL_LINK_EXE" nano_multi_ctrl "$MULTI_CTRL_OBJ"
  log "multi.ctrl.tiny.link.bytes=$(bytes_of "$MULTI_CTRL_LINK_EXE")"
  run_case "run-tiny-linked-multi-func-control-flow43" "$RUNNER" run-expect-exit "$MULTI_CTRL_LINK_EXE" 43
  run_case "compile-multi-func-ptr-elf64-obj1" "$RUNNER" compile-elf64-obj-code "$MULTI_PTR_SRC" "$MULTI_PTR_OBJ" nano_multi_ptr
  run_case "tiny-link-multi-func-ptr-obj1" "$RUNNER" link-elf64-exe "$MULTI_PTR_LINK_EXE" nano_multi_ptr "$MULTI_PTR_OBJ"
  run_case "run-tiny-linked-multi-func-ptr1" "$RUNNER" run-expect-exit "$MULTI_PTR_LINK_EXE" 1
  run_case "compile-multi-func-ptr-elf64-exe1" "$RUNNER" compile-elf64-exe "$MULTI_PTR_SRC" "$MULTI_PTR_DIRECT_EXE" nano_multi_ptr_direct
  run_case "run-direct-compiled-multi-func-ptr1" "$RUNNER" run-expect-exit "$MULTI_PTR_DIRECT_EXE" 1
  run_case "reject-ptr-op-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_PTR_OP_SRC" "$TYPE_BAD_PTR_OP_EXE"
  run_case "reject-ptr-op-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_PTR_OP_SRC" "$TYPE_BAD_PTR_OP_OBJ" nano_type_bad_ptr_op
  run_case "reject-ptr-op-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_PTR_OP_SRC" "$TYPE_BAD_PTR_OP_EXE" nano_type_bad_ptr_op
  run_case "reject-add-ptr-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_ADD_PTR_SRC" "$TYPE_BAD_ADD_PTR_OBJ" nano_type_bad_add_ptr
  run_case "reject-sub-ptr-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_SUB_PTR_SRC" "$TYPE_BAD_SUB_PTR_OBJ" nano_type_bad_sub_ptr
  run_case "reject-ptr-to-u64-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_PTR_TO_U64_SRC" "$TYPE_BAD_PTR_TO_U64_EXE"
  run_case "reject-ptr-to-u64-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_PTR_TO_U64_SRC" "$TYPE_BAD_PTR_TO_U64_OBJ" nano_type_bad_ptr_to_u64
  run_case "reject-ptr-to-u64-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_PTR_TO_U64_SRC" "$TYPE_BAD_PTR_TO_U64_EXE" nano_type_bad_ptr_to_u64
  run_case "reject-u64-to-ptr-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_U64_TO_PTR_SRC" "$TYPE_BAD_U64_TO_PTR_EXE"
  run_case "reject-u64-to-ptr-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_U64_TO_PTR_SRC" "$TYPE_BAD_U64_TO_PTR_OBJ" nano_type_bad_u64_to_ptr
  run_case "reject-u64-to-ptr-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_U64_TO_PTR_SRC" "$TYPE_BAD_U64_TO_PTR_EXE" nano_type_bad_u64_to_ptr
  run_case "reject-load-u8-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_LOAD_U8_SRC" "$TYPE_BAD_LOAD_U8_EXE"
  run_case "reject-load-u8-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_LOAD_U8_SRC" "$TYPE_BAD_LOAD_U8_OBJ" nano_type_bad_load_u8
  run_case "reject-load-u8-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_LOAD_U8_SRC" "$TYPE_BAD_LOAD_U8_EXE" nano_type_bad_load_u8
  run_case "reject-load-u16-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_LOAD_U16_SRC" "$TYPE_BAD_LOAD_U16_EXE"
  run_case "reject-load-u16-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_LOAD_U16_SRC" "$TYPE_BAD_LOAD_U16_OBJ" nano_type_bad_load_u16
  run_case "reject-load-u16-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_LOAD_U16_SRC" "$TYPE_BAD_LOAD_U16_EXE" nano_type_bad_load_u16
  run_case "reject-load-u32-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_LOAD_U32_SRC" "$TYPE_BAD_LOAD_U32_EXE"
  run_case "reject-load-u32-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_LOAD_U32_SRC" "$TYPE_BAD_LOAD_U32_OBJ" nano_type_bad_load_u32
  run_case "reject-load-u32-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_LOAD_U32_SRC" "$TYPE_BAD_LOAD_U32_EXE" nano_type_bad_load_u32
  run_case "reject-store-u8-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U8_SRC" "$TYPE_BAD_STORE_U8_EXE"
  run_case "reject-store-u8-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U8_SRC" "$TYPE_BAD_STORE_U8_OBJ" nano_type_bad_store_u8
  run_case "reject-store-u8-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U8_SRC" "$TYPE_BAD_STORE_U8_EXE" nano_type_bad_store_u8
  run_case "reject-store-u8-range-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U8_RANGE_SRC" "$TYPE_BAD_STORE_U8_RANGE_EXE"
  run_case "reject-store-u8-range-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U8_RANGE_SRC" "$TYPE_BAD_STORE_U8_RANGE_OBJ" nano_type_bad_store_u8_range
  run_case "reject-store-u8-range-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U8_RANGE_SRC" "$TYPE_BAD_STORE_U8_RANGE_EXE" nano_type_bad_store_u8_range
  run_case "reject-store-u16-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U16_SRC" "$TYPE_BAD_STORE_U16_EXE"
  run_case "reject-store-u16-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U16_SRC" "$TYPE_BAD_STORE_U16_OBJ" nano_type_bad_store_u16
  run_case "reject-store-u16-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U16_SRC" "$TYPE_BAD_STORE_U16_EXE" nano_type_bad_store_u16
  run_case "reject-store-u16-range-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U16_RANGE_SRC" "$TYPE_BAD_STORE_U16_RANGE_EXE"
  run_case "reject-store-u16-range-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U16_RANGE_SRC" "$TYPE_BAD_STORE_U16_RANGE_OBJ" nano_type_bad_store_u16_range
  run_case "reject-store-u16-range-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U16_RANGE_SRC" "$TYPE_BAD_STORE_U16_RANGE_EXE" nano_type_bad_store_u16_range
  run_case "reject-store-u32-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U32_SRC" "$TYPE_BAD_STORE_U32_EXE"
  run_case "reject-store-u32-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U32_SRC" "$TYPE_BAD_STORE_U32_OBJ" nano_type_bad_store_u32
  run_case "reject-store-u32-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U32_SRC" "$TYPE_BAD_STORE_U32_EXE" nano_type_bad_store_u32
  run_case "reject-store-u32-range-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U32_RANGE_SRC" "$TYPE_BAD_STORE_U32_RANGE_EXE"
  run_case "reject-store-u32-range-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U32_RANGE_SRC" "$TYPE_BAD_STORE_U32_RANGE_OBJ" nano_type_bad_store_u32_range
  run_case "reject-store-u32-range-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U32_RANGE_SRC" "$TYPE_BAD_STORE_U32_RANGE_EXE" nano_type_bad_store_u32_range
  run_case "reject-branch-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_BRANCH_SRC" "$TYPE_BAD_BRANCH_EXE"
  run_case "reject-expect-ptr-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_EXPECT_PTR_SRC" "$TYPE_BAD_EXPECT_PTR_OBJ" nano_type_bad_expect_ptr
  run_case "emit-elf64-obj-call42" "$RUNNER" emit-elf64-obj-call "$CALL42_OBJ" nano_call nano_ext
  log "call42.obj.bytes=$(bytes_of "$CALL42_OBJ")"
  run_case "emit-elf64-obj-callee42" "$RUNNER" emit-elf64-obj-ret "$CALL42_CALLEE_OBJ" nano_ext 42
  run_case "tiny-link-elf64-obj-call42" "$RUNNER" link-elf64-exe "$CALL42_LINK_EXE" nano_call "$CALL42_OBJ" "$CALL42_CALLEE_OBJ"
  log "call42.tiny.link.bytes=$(bytes_of "$CALL42_LINK_EXE")"
  run_case "run-tiny-linked-call42" "$RUNNER" run-expect-exit "$CALL42_LINK_EXE" 42
  run_case "emit-elf64-obj-duplicate-nano-ext" "$RUNNER" emit-elf64-obj-ret "$DUP42_OBJ" nano_ext 7
  run_case "tiny-link-reject-duplicate-symbol" "$RUNNER" link-expect-exit 2 "$BUILD_DIR/dup_should_fail" nano_call "$CALL42_OBJ" "$CALL42_CALLEE_OBJ" "$DUP42_OBJ"
else
  log ""
  log "## run-elf64-exit42"
  log "skip: host is not x86_64"
fi

run_case "compile-libc-smoke-lbin" "$RUNNER" compile "$SMOKE_SRC" "$SMOKE_BLOB"
log "smoke.blob.bytes=$(bytes_of "$SMOKE_BLOB")"

run_case "execute-libc-smoke-lbin" "$RUNNER" run "$SMOKE_BLOB"

run_case "generate-libc-resolve-manifest" "$RUNNER" gen-libc-resolve "$LIBC_SRC"
run_case "compile-libc-resolve-lbin" "$RUNNER" compile "$LIBC_SRC" "$LIBC_BLOB"
log "libc.resolve.blob.bytes=$(bytes_of "$LIBC_BLOB")"
run_case "resolve-libc-imports" "$RUNNER" resolve --quiet "$LIBC_BLOB"

log ""
log "results.file=$RESULTS"
