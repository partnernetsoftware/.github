//! Portable `.lbin` VM — port of `nano_blob_vm.c::execute_blob`.

use crate::ffi::RuntimeImport;
use crate::lbin::{
    rd32, Blob, OP_ADD_I64, OP_ADD_PTR, OP_ADD_U64, OP_AND_BOOL, OP_BRANCH_BOOL, OP_CALL_FUNC,
    OP_CALL_IMPORT_CONST, OP_CALL_IMPORT_CONST2, OP_CALL_IMPORT_IMM, OP_CALL_IMPORT_VOID,
    OP_CONST_BOOL, OP_CONST_I64, OP_CONST_PTR, OP_CONST_U64, OP_EQ_I64, OP_EXPECT_BOOL,
    OP_EXPECT_I64, OP_EXPECT_PTR, OP_EXPECT_U64, OP_GE_I64, OP_GT_I64, OP_IS_NONNULL_PTR,
    OP_IS_NULL_PTR, OP_LE_I64, OP_LOAD_ARG_I64, OP_LOAD_U16, OP_LOAD_U32, OP_LOAD_U8, OP_LT_I64,
    OP_MUL_I64, OP_NE_I64, OP_NOT_BOOL, OP_NULL_PTR, OP_OR_BOOL, OP_PTR_TO_U64, OP_RESOLVE_IMPORT,
    OP_RET_LAST, OP_STORE_U16, OP_STORE_U32, OP_STORE_U8, OP_SUB_I64, OP_SUB_PTR, OP_U64_TO_PTR,
};
use crate::value::{imm_i64, imm64, Value};
use std::io;

pub fn execute(blob: &Blob) -> i32 {
    let mut last = Value::u64(0);
    let mut pc = 0u32;
    while pc < blob.instr_count {
        let ins = match blob.instr_row(pc) {
            Some(r) => r,
            None => return 10,
        };
        let op = ins[0];
        let arg0 = rd32(ins, 4);
        let arg1 = rd32(ins, 8);

        match op {
            OP_RET_LAST => {
                print!("ret=");
                let _ = last.print(&mut io::stdout());
                println!();
                return 0;
            }
            OP_RESOLVE_IMPORT => {
                let ri = match RuntimeImport::resolve(blob, arg0) {
                    Ok(r) => r,
                    Err(e) => return e,
                };
                last = Value::ptr(ri.fn_addr as *const u8);
                println!(
                    "resolve.{pc}={}:{} sig={} ok",
                    ri.lib,
                    ri.sym,
                    crate::lbin::sig_name(ri.sig)
                );
                pc += 1;
            }
            OP_EXPECT_U64 => {
                let expected = imm64(arg0, arg1);
                if !last.expect_u64(expected) {
                    eprint!("expect.{pc}=fail expected={expected} actual=");
                    let _ = last.print(&mut io::stderr());
                    eprintln!();
                    return 19;
                }
                println!("expect.{pc}=ok expected={expected}");
                pc += 1;
            }
            OP_EXPECT_I64 => {
                let expected = imm_i64(arg0, arg1);
                if !last.expect_i64(expected) {
                    eprint!("expect.{pc}=fail expected={expected} actual=");
                    let _ = last.print(&mut io::stderr());
                    eprintln!();
                    return 19;
                }
                println!("expect.{pc}=ok expected={expected}");
                pc += 1;
            }
            OP_EXPECT_BOOL => {
                if !last.expect_bool(arg0 != 0) {
                    eprint!("expect.{pc}=fail expected={} actual=", arg0 != 0);
                    let _ = last.print(&mut io::stderr());
                    eprintln!();
                    return 19;
                }
                println!("expect.{pc}=ok expected={}", arg0 != 0);
                pc += 1;
            }
            OP_EXPECT_PTR => {
                if !last.expect_ptr(arg0 != 0) {
                    eprint!("expect.{pc}=fail expected={} actual=", if arg0 != 0 { "nonnull" } else { "null" });
                    let _ = last.print(&mut io::stderr());
                    eprintln!();
                    return 19;
                }
                println!("expect.{pc}=ok expected={}", if arg0 != 0 { "nonnull" } else { "null" });
                pc += 1;
            }
            OP_BRANCH_BOOL => {
                if last.kind != crate::value::ValueKind::Bool {
                    eprint!("type.branch={pc} actual=");
                    let _ = last.print(&mut io::stderr());
                    eprintln!();
                    return 21;
                }
                if arg0 >= blob.instr_count {
                    eprintln!("branch.{pc}=bad_target {arg0}");
                    return 22;
                }
                println!(
                    "branch.{pc}={} target={arg0}",
                    if last.bits != 0 { "taken" } else { "not-taken" }
                );
                pc = if last.bits != 0 { arg0 } else { pc + 1 };
            }
            OP_CONST_U64 => {
                last = Value::u64(imm64(arg0, arg1));
                print!("u64.{pc}=");
                let _ = last.print(&mut io::stdout());
                println!();
                pc += 1;
            }
            OP_CONST_I64 => {
                last = Value::i64(imm_i64(arg0, arg1));
                print!("i64.{pc}=");
                let _ = last.print(&mut io::stdout());
                println!();
                pc += 1;
            }
            OP_CONST_BOOL => {
                last = Value::bool(arg0 != 0);
                print!("bool.{pc}=");
                let _ = last.print(&mut io::stdout());
                println!();
                pc += 1;
            }
            OP_NULL_PTR => {
                last = Value::ptr(std::ptr::null());
                print!("null-ptr.{pc}=");
                let _ = last.print(&mut io::stdout());
                println!();
                pc += 1;
            }
            OP_ADD_PTR => {
                if !last.add_ptr(imm64(arg0, arg1)) {
                    return type_err(pc, "add-ptr", &last);
                }
                print_op(pc, "add-ptr", &last);
                pc += 1;
            }
            OP_SUB_PTR => {
                if !last.sub_ptr(imm64(arg0, arg1)) {
                    return type_err(pc, "sub-ptr", &last);
                }
                print_op(pc, "sub-ptr", &last);
                pc += 1;
            }
            OP_PTR_TO_U64 => {
                if !last.ptr_to_u64() {
                    return type_err(pc, "ptr-to-u64", &last);
                }
                print_op(pc, "ptr-to-u64", &last);
                pc += 1;
            }
            OP_U64_TO_PTR => {
                if !last.u64_to_ptr() {
                    return type_err(pc, "u64-to-ptr", &last);
                }
                print_op(pc, "u64-to-ptr", &last);
                pc += 1;
            }
            OP_CONST_PTR => {
                let s = match blob.const_string_ref(arg0) {
                    Some(v) => v,
                    None => {
                        eprintln!("const-ptr.{pc}=bad_const {arg0}");
                        return 23;
                    }
                };
                last = Value::ptr(s.as_ptr());
                print_op(pc, "const-ptr", &last);
                pc += 1;
            }
            OP_LOAD_U8 => {
                if !last.load_u8() {
                    return type_err(pc, "load-u8", &last);
                }
                print_op(pc, "load-u8", &last);
                pc += 1;
            }
            OP_LOAD_U16 => {
                if !last.load_u16() {
                    return type_err(pc, "load-u16", &last);
                }
                print_op(pc, "load-u16", &last);
                pc += 1;
            }
            OP_LOAD_U32 => {
                if !last.load_u32() {
                    return type_err(pc, "load-u32", &last);
                }
                print_op(pc, "load-u32", &last);
                pc += 1;
            }
            OP_STORE_U8 => {
                if !last.store_u8(imm64(arg0, arg1)) {
                    return type_err(pc, "store-u8", &last);
                }
                print_op(pc, "store-u8", &last);
                pc += 1;
            }
            OP_STORE_U16 => {
                if !last.store_u16(imm64(arg0, arg1)) {
                    return type_err(pc, "store-u16", &last);
                }
                print_op(pc, "store-u16", &last);
                pc += 1;
            }
            OP_STORE_U32 => {
                if !last.store_u32(imm64(arg0, arg1)) {
                    return type_err(pc, "store-u32", &last);
                }
                print_op(pc, "store-u32", &last);
                pc += 1;
            }
            OP_IS_NULL_PTR => {
                if !last.is_null_ptr() {
                    return type_err(pc, "is-null-ptr", &last);
                }
                print_op(pc, "is-null-ptr", &last);
                pc += 1;
            }
            OP_IS_NONNULL_PTR => {
                if !last.is_nonnull_ptr() {
                    return type_err(pc, "is-nonnull-ptr", &last);
                }
                print_op(pc, "is-nonnull-ptr", &last);
                pc += 1;
            }
            OP_NOT_BOOL => {
                if !last.not_bool() {
                    return type_err(pc, "not-bool", &last);
                }
                print_op(pc, "not-bool", &last);
                pc += 1;
            }
            OP_AND_BOOL => {
                if !last.and_bool(arg0 != 0) {
                    return type_err(pc, "and-bool", &last);
                }
                print_op(pc, "and-bool", &last);
                pc += 1;
            }
            OP_OR_BOOL => {
                if !last.or_bool(arg0 != 0) {
                    return type_err(pc, "or-bool", &last);
                }
                print_op(pc, "or-bool", &last);
                pc += 1;
            }
            OP_ADD_U64 => {
                if !last.add_u64(imm64(arg0, arg1)) {
                    return type_err(pc, "add-u64", &last);
                }
                print_op(pc, "add-u64", &last);
                pc += 1;
            }
            OP_ADD_I64 => {
                if !last.add_i64(imm_i64(arg0, arg1)) {
                    return type_err(pc, "add-i64", &last);
                }
                print_op(pc, "add-i64", &last);
                pc += 1;
            }
            OP_SUB_I64 => {
                if !last.sub_i64(imm_i64(arg0, arg1)) {
                    return type_err(pc, "sub-i64", &last);
                }
                print_op(pc, "sub-i64", &last);
                pc += 1;
            }
            OP_MUL_I64 => {
                if !last.mul_i64(imm_i64(arg0, arg1)) {
                    return type_err(pc, "mul-i64", &last);
                }
                print_op(pc, "mul-i64", &last);
                pc += 1;
            }
            OP_EQ_I64 => {
                if !last.eq_i64(imm_i64(arg0, arg1)) {
                    return type_err(pc, "eq-i64", &last);
                }
                print_op(pc, "eq-i64", &last);
                pc += 1;
            }
            OP_LT_I64 => {
                if !last.lt_i64(imm_i64(arg0, arg1)) {
                    return type_err(pc, "lt-i64", &last);
                }
                print_op(pc, "lt-i64", &last);
                pc += 1;
            }
            OP_GT_I64 => {
                if !last.gt_i64(imm_i64(arg0, arg1)) {
                    return type_err(pc, "gt-i64", &last);
                }
                print_op(pc, "gt-i64", &last);
                pc += 1;
            }
            OP_NE_I64 => {
                if !last.ne_i64(imm_i64(arg0, arg1)) {
                    return type_err(pc, "ne-i64", &last);
                }
                print_op(pc, "ne-i64", &last);
                pc += 1;
            }
            OP_LE_I64 => {
                if !last.le_i64(imm_i64(arg0, arg1)) {
                    return type_err(pc, "le-i64", &last);
                }
                print_op(pc, "le-i64", &last);
                pc += 1;
            }
            OP_GE_I64 => {
                if !last.ge_i64(imm_i64(arg0, arg1)) {
                    return type_err(pc, "ge-i64", &last);
                }
                print_op(pc, "ge-i64", &last);
                pc += 1;
            }
            OP_CALL_FUNC => {
                let entry = match blob.func_entry_row(arg0) {
                    Some(e) => e,
                    None => {
                        eprintln!("call-func.{pc}=bad_index {arg0}");
                        return 24;
                    }
                };
                let call_arg = match last.as_call_arg() {
                    Some(v) => v,
                    None => return type_err(pc, "call-func", &last),
                };
                let start = rd32(entry, 0);
                let len = rd32(entry, 4);
                if start + len > blob.instr_count {
                    eprintln!("call-func.{pc}=bad_range start={start} len={len}");
                    return 24;
                }
                match execute_func_range(blob, start, start + len, call_arg) {
                    Ok(v) => last = v,
                    Err(e) => return e,
                }
                print!("call-func.{pc}=idx{arg0} result=");
                let _ = last.print(&mut io::stdout());
                println!();
                pc += 1;
            }
            OP_CALL_IMPORT_CONST | OP_CALL_IMPORT_CONST2 | OP_CALL_IMPORT_VOID | OP_CALL_IMPORT_IMM => {
                let ri = match RuntimeImport::resolve(blob, arg0) {
                    Ok(r) => r,
                    Err(e) => return e,
                };
                let rc = match op {
                    OP_CALL_IMPORT_CONST => {
                        let s = match blob.const_string_ref(arg1) {
                            Some(v) => v,
                            None => return 13,
                        };
                        ri.call1(s)
                    }
                    OP_CALL_IMPORT_CONST2 => {
                        let c0 = arg1 & 0xffff;
                        let c1 = arg1 >> 16;
                        let s0 = match blob.const_string_ref(c0) {
                            Some(v) => v,
                            None => return 13,
                        };
                        let s1 = match blob.const_string_ref(c1) {
                            Some(v) => v,
                            None => return 13,
                        };
                        ri.call2(s0, s1)
                    }
                    OP_CALL_IMPORT_VOID => ri.call0(),
                    OP_CALL_IMPORT_IMM => ri.call_i32(arg1 as i32),
                    _ => unreachable!(),
                };
                last = match rc {
                    Ok(v) => v,
                    Err(e) => return e,
                };
                print!("call.{pc}={}:{} result=", ri.lib, ri.sym);
                let _ = last.print(&mut io::stdout());
                println!();
                pc += 1;
            }
            _ => {
                eprintln!("unsupported.op={op}");
                return 11;
            }
        }
    }
    eprintln!("missing.ret");
    18
}

fn execute_func_range(blob: &Blob, start: u32, end: u32, arg: u64) -> Result<Value, i32> {
    let slots = [Value::i64(arg as i64), Value::i64(0)];
    let mut last = Value::u64(arg);
    let mut pc = start;
    while pc < end {
        let ins = blob.instr_row(pc).ok_or(10)?;
        let op = ins[0];
        let arg0 = rd32(ins, 4);
        let arg1 = rd32(ins, 8);
        match op {
            OP_LOAD_ARG_I64 => {
                if arg0 >= 2 {
                    eprintln!("func.load-arg-i64.{pc}=bad_index {arg0}");
                    return Err(24);
                }
                last = slots[arg0 as usize];
                print!("func.load-arg-i64.{pc}=");
                let _ = last.print(&mut io::stdout());
                println!();
                pc += 1;
            }
            OP_CONST_U64 => {
                last = Value::u64(imm64(arg0, arg1));
                print!("func.u64.{pc}=");
                let _ = last.print(&mut io::stdout());
                println!();
                pc += 1;
            }
            OP_CONST_I64 => {
                last = Value::i64(imm_i64(arg0, arg1));
                print!("func.i64.{pc}=");
                let _ = last.print(&mut io::stdout());
                println!();
                pc += 1;
            }
            OP_ADD_U64 => {
                if !last.add_u64(imm64(arg0, arg1)) {
                    return Err(type_err(pc, "func.add-u64", &last));
                }
                print_op(pc, "func.add-u64", &last);
                pc += 1;
            }
            OP_ADD_I64 => {
                if !last.add_i64(imm_i64(arg0, arg1)) {
                    return Err(type_err(pc, "func.add-i64", &last));
                }
                print_op(pc, "func.add-i64", &last);
                pc += 1;
            }
            _ => {
                eprintln!("func.unsupported.op={op}");
                return Err(11);
            }
        }
    }
    Ok(last)
}

fn type_err(pc: u32, name: &str, v: &Value) -> i32 {
    eprint!("type.{name}={pc} actual=");
    let _ = v.print(&mut io::stderr());
    eprintln!();
    20
}

fn print_op(pc: u32, name: &str, v: &Value) {
    print!("{name}.{pc}=");
    let _ = v.print(&mut io::stdout());
    println!();
}
