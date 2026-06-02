//! Constexpr evaluation of pure `.lbin` blobs — port of `eval_pure_blob` in `nano_aot_x86.c`.

use crate::lbin::{
    rd32, Blob, OP_ADD_I64, OP_ADD_PTR, OP_ADD_U64, OP_AND_BOOL, OP_BRANCH_BOOL, OP_CONST_BOOL,
    OP_CONST_I64, OP_CONST_PTR, OP_CONST_U64, OP_EQ_I64, OP_EXPECT_BOOL, OP_EXPECT_I64,
    OP_EXPECT_PTR, OP_EXPECT_U64, OP_GE_I64, OP_GT_I64, OP_IS_NONNULL_PTR, OP_IS_NULL_PTR,
    OP_LE_I64, OP_LOAD_U16, OP_LOAD_U32, OP_LOAD_U8, OP_LT_I64, OP_MUL_I64, OP_NE_I64, OP_NOT_BOOL,
    OP_NULL_PTR, OP_OR_BOOL, OP_PTR_TO_U64, OP_RET_LAST, OP_STORE_U16, OP_STORE_U32, OP_STORE_U8,
    OP_SUB_I64, OP_SUB_PTR, OP_U64_TO_PTR,
};
use crate::value::{imm64, imm_i64, Value, ValueKind};

fn step<F>(ok: bool, f: F) -> Option<()>
where
    F: FnOnce() -> (),
{
    if ok {
        f();
        Some(())
    } else {
        None
    }
}

pub fn eval_pure(blob: &Blob) -> Option<Value> {
    let mut last = Value::u64(0);
    let mut pc = 0u32;
    while pc < blob.instr_count {
        let ins = blob.instr_row(pc)?;
        let op = ins[0];
        let arg0 = rd32(ins, 4);
        let arg1 = rd32(ins, 8);

        match op {
            OP_CONST_U64 => {
                last = Value::u64(imm64(arg0, arg1));
                pc += 1;
            }
            OP_CONST_I64 => {
                last = Value::i64(imm_i64(arg0, arg1));
                pc += 1;
            }
            OP_CONST_BOOL => {
                last = Value::bool(arg0 != 0);
                pc += 1;
            }
            OP_NULL_PTR => {
                last = Value::ptr(std::ptr::null());
                pc += 1;
            }
            OP_ADD_PTR => {
                step(last.add_ptr(imm64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_SUB_PTR => {
                step(last.sub_ptr(imm64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_PTR_TO_U64 => {
                step(last.ptr_to_u64(), || ())?;
                pc += 1;
            }
            OP_U64_TO_PTR => {
                step(last.u64_to_ptr(), || ())?;
                pc += 1;
            }
            OP_CONST_PTR => {
                let s = blob.const_string_ref(arg0)?;
                last = Value::ptr(s.as_ptr());
                pc += 1;
            }
            OP_LOAD_U8 => {
                step(last.load_u8(), || ())?;
                pc += 1;
            }
            OP_LOAD_U16 => {
                step(last.load_u16(), || ())?;
                pc += 1;
            }
            OP_LOAD_U32 => {
                step(last.load_u32(), || ())?;
                pc += 1;
            }
            OP_STORE_U8 => {
                step(last.store_u8(imm64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_STORE_U16 => {
                step(last.store_u16(imm64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_STORE_U32 => {
                step(last.store_u32(imm64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_IS_NULL_PTR => {
                step(last.is_null_ptr(), || ())?;
                pc += 1;
            }
            OP_IS_NONNULL_PTR => {
                step(last.is_nonnull_ptr(), || ())?;
                pc += 1;
            }
            OP_NOT_BOOL => {
                step(last.not_bool(), || ())?;
                pc += 1;
            }
            OP_AND_BOOL => {
                step(last.and_bool(arg0 != 0), || ())?;
                pc += 1;
            }
            OP_OR_BOOL => {
                step(last.or_bool(arg0 != 0), || ())?;
                pc += 1;
            }
            OP_ADD_U64 => {
                step(last.add_u64(imm64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_ADD_I64 => {
                step(last.add_i64(imm_i64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_SUB_I64 => {
                step(last.sub_i64(imm_i64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_MUL_I64 => {
                step(last.mul_i64(imm_i64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_EQ_I64 => {
                step(last.eq_i64(imm_i64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_LT_I64 => {
                step(last.lt_i64(imm_i64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_GT_I64 => {
                step(last.gt_i64(imm_i64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_NE_I64 => {
                step(last.ne_i64(imm_i64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_LE_I64 => {
                step(last.le_i64(imm_i64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_GE_I64 => {
                step(last.ge_i64(imm_i64(arg0, arg1)), || ())?;
                pc += 1;
            }
            OP_EXPECT_U64 => {
                if !last.expect_u64(imm64(arg0, arg1)) {
                    return None;
                }
                pc += 1;
            }
            OP_EXPECT_I64 => {
                if !last.expect_i64(imm_i64(arg0, arg1)) {
                    return None;
                }
                pc += 1;
            }
            OP_EXPECT_BOOL => {
                if !last.expect_bool(arg0 != 0) {
                    return None;
                }
                pc += 1;
            }
            OP_EXPECT_PTR => {
                if !last.expect_ptr(arg0 != 0) {
                    return None;
                }
                pc += 1;
            }
            OP_BRANCH_BOOL => {
                if last.kind != ValueKind::Bool || arg0 >= blob.instr_count {
                    return None;
                }
                pc = if last.bits != 0 { arg0 } else { pc + 1 };
            }
            OP_RET_LAST => return Some(last),
            _ => return None,
        }
    }
    None
}

pub fn value_to_exit_code(v: Value) -> Option<u8> {
    match v.kind {
        ValueKind::U64 | ValueKind::Bool => Some((v.bits & 0xff) as u8),
        ValueKind::I64 => Some((v.bits as i64 as i8) as u8),
        _ => None,
    }
}
