//! x86_64 codegen for pure `.lbin` blobs — port of `compile_pure_blob_to_x86`.

use crate::elf64;
use crate::lbin::{
    rd32, Blob, OP_ADD_I64, OP_ADD_PTR, OP_ADD_U64, OP_AND_BOOL, OP_BRANCH_BOOL, OP_CONST_BOOL,
    OP_CONST_I64, OP_CONST_PTR, OP_CONST_U64, OP_EQ_I64, OP_EXPECT_BOOL, OP_EXPECT_I64,
    OP_EXPECT_PTR, OP_EXPECT_U64, OP_GE_I64, OP_GT_I64, OP_IS_NONNULL_PTR, OP_IS_NULL_PTR,
    OP_LE_I64, OP_LOAD_U16, OP_LOAD_U32, OP_LOAD_U8, OP_LT_I64, OP_MUL_I64, OP_NE_I64, OP_NOT_BOOL,
    OP_NULL_PTR, OP_OR_BOOL, OP_PTR_TO_U64, OP_RET_LAST, OP_STORE_U16, OP_STORE_U32, OP_STORE_U8,
    OP_SUB_I64, OP_SUB_PTR, OP_U64_TO_PTR,
};
use crate::value::{imm64, imm_i64};
use std::path::Path;

#[derive(Clone, Copy, PartialEq, Eq)]
enum LastKind {
    None,
    U64,
    I64,
    Bool,
    Ptr,
}

struct CodeBuf {
    data: Vec<u8>,
}

impl CodeBuf {
    fn new() -> Self {
        Self { data: Vec::new() }
    }

    fn put(&mut self, bytes: &[u8]) {
        self.data.extend_from_slice(bytes);
    }

    fn patch_u32(&mut self, off: usize, v: u32) {
        self.data[off..off + 4].copy_from_slice(&v.to_le_bytes());
    }

    fn len(&self) -> usize {
        self.data.len()
    }
}

struct PcPatch {
    patch_off: u32,
    target_pc: u32,
}

struct DataPatch {
    patch_off: u32,
    sec_off: u32,
    sec: u8, // 1=.rodata 2=.data
}

fn wr32(buf: &mut [u8], off: usize, v: u32) {
    buf[off..off + 4].copy_from_slice(&v.to_le_bytes());
}

fn wr16(buf: &mut [u8], off: usize, v: u16) {
    buf[off..off + 2].copy_from_slice(&v.to_le_bytes());
}

fn blob_has_store_ops(b: &Blob) -> bool {
    for pc in 0..b.instr_count {
        if let Some(ins) = b.instr_row(pc) {
            match ins[0] {
                OP_STORE_U8 | OP_STORE_U16 | OP_STORE_U32 => return true,
                _ => {}
            }
        }
    }
    false
}

fn compile_pure_blob_to_x86(
    b: &Blob,
    exit_style: bool,
    code: &mut CodeBuf,
    rodata: &mut CodeBuf,
    data_sec: &mut CodeBuf,
) -> bool {
    let mut last_kind = LastKind::None;
    let mut saw_ret = false;
    let mut expect_patches: Vec<u32> = Vec::new();
    let mut branch_patches: Vec<PcPatch> = Vec::new();
    let mut data_patches: Vec<DataPatch> = Vec::new();
    let mut pc_offs = vec![0u32; b.instr_count.max(1) as usize];
    let mut const_sec_off = vec![u32::MAX; b.const_count as usize];

    for pc in 0..b.instr_count {
        let ins = match b.instr_row(pc) {
            Some(r) => r,
            None => return false,
        };
        pc_offs[pc as usize] = code.len() as u32;
        let op = ins[0];
        let arg0 = rd32(ins, 4);
        let arg1 = rd32(ins, 8);
        let imm_u64 = imm64(arg0, arg1);
        let imm_i64 = imm_i64(arg0, arg1);

        macro_rules! fail {
            () => {
                return false
            };
        }

        match op {
            OP_CONST_U64 => {
                if imm_u64 > u32::MAX as u64 {
                    fail!();
                }
                if exit_style {
                    let mut mov_edi = [0xbf, 0, 0, 0, 0];
                    wr32(&mut mov_edi, 1, imm_u64 as u32);
                    code.put(&mov_edi);
                } else {
                    let mut mov_eax = [0xb8, 0, 0, 0, 0];
                    wr32(&mut mov_eax, 1, imm_u64 as u32);
                    code.put(&mov_eax);
                }
                last_kind = LastKind::U64;
            }
            OP_CONST_I64 => {
                if imm_i64 < i32::MIN as i64 || imm_i64 > i32::MAX as i64 {
                    fail!();
                }
                if exit_style {
                    let mut mov_edi = [0xbf, 0, 0, 0, 0];
                    wr32(&mut mov_edi, 1, imm_i64 as i32 as u32);
                    code.put(&mov_edi);
                } else {
                    let mut mov_eax = [0xb8, 0, 0, 0, 0];
                    wr32(&mut mov_eax, 1, imm_i64 as i32 as u32);
                    code.put(&mov_eax);
                }
                last_kind = LastKind::I64;
            }
            OP_CONST_BOOL => {
                let v = if arg0 != 0 { 1u32 } else { 0u32 };
                if exit_style {
                    let mut mov_edi = [0xbf, 0, 0, 0, 0];
                    wr32(&mut mov_edi, 1, v);
                    code.put(&mov_edi);
                } else {
                    let mut mov_eax = [0xb8, 0, 0, 0, 0];
                    wr32(&mut mov_eax, 1, v);
                    code.put(&mov_eax);
                }
                last_kind = LastKind::Bool;
            }
            OP_NULL_PTR => {
                if exit_style {
                    code.put(&[0xbf, 0, 0, 0, 0]);
                } else {
                    code.put(&[0xb8, 0, 0, 0, 0]);
                }
                last_kind = LastKind::Ptr;
            }
            OP_ADD_PTR => {
                if last_kind != LastKind::Ptr || imm_u64 > u32::MAX as u64 {
                    fail!();
                }
                if exit_style {
                    let mut add_edi = [0x81, 0xc7, 0, 0, 0, 0];
                    wr32(&mut add_edi, 2, imm_u64 as u32);
                    code.put(&add_edi);
                } else {
                    let mut add_eax = [0x05, 0, 0, 0, 0];
                    wr32(&mut add_eax, 1, imm_u64 as u32);
                    code.put(&add_eax);
                }
            }
            OP_SUB_PTR => {
                if last_kind != LastKind::Ptr || imm_u64 > u32::MAX as u64 {
                    fail!();
                }
                if exit_style {
                    let mut sub_edi = [0x81, 0xef, 0, 0, 0, 0];
                    wr32(&mut sub_edi, 2, imm_u64 as u32);
                    code.put(&sub_edi);
                } else {
                    let mut sub_eax = [0x2d, 0, 0, 0, 0];
                    wr32(&mut sub_eax, 1, imm_u64 as u32);
                    code.put(&sub_eax);
                }
            }
            OP_PTR_TO_U64 => {
                if last_kind != LastKind::Ptr {
                    fail!();
                }
                last_kind = LastKind::U64;
            }
            OP_U64_TO_PTR => {
                if last_kind != LastKind::U64 {
                    fail!();
                }
                last_kind = LastKind::Ptr;
            }
            OP_CONST_PTR => {
                let s = match b.const_string_ref(arg0) {
                    Some(v) => v,
                    None => fail!(),
                };
                let use_data = blob_has_store_ops(b);
                let sec: &mut CodeBuf = if use_data { data_sec } else { rodata };
                let sec_id = if use_data { 2u8 } else { 1u8 };
                if arg0 as usize >= const_sec_off.len() {
                    fail!();
                }
                let lea = [0x48, 0x8d, if exit_style { 0x3d } else { 0x05 }, 0, 0, 0, 0];
                let sec_off = if const_sec_off[arg0 as usize] == u32::MAX {
                    let off = sec.len() as u32;
                    const_sec_off[arg0 as usize] = off;
                    sec.put(s.as_bytes());
                    sec.put(&[0]);
                    off
                } else {
                    const_sec_off[arg0 as usize]
                };
                let patch = DataPatch {
                    patch_off: (code.len() + 3) as u32,
                    sec_off,
                    sec: sec_id,
                };
                code.put(&lea);
                data_patches.push(patch);
                last_kind = LastKind::Ptr;
            }
            OP_LOAD_U8 => {
                if last_kind != LastKind::Ptr {
                    fail!();
                }
                if exit_style {
                    code.put(&[0x0f, 0xb6, 0x3f]);
                } else {
                    code.put(&[0x0f, 0xb6, 0x00]);
                }
                last_kind = LastKind::U64;
            }
            OP_LOAD_U16 => {
                if last_kind != LastKind::Ptr {
                    fail!();
                }
                if exit_style {
                    code.put(&[0x0f, 0xb7, 0x3f]);
                } else {
                    code.put(&[0x0f, 0xb7, 0x00]);
                }
                last_kind = LastKind::U64;
            }
            OP_LOAD_U32 => {
                if last_kind != LastKind::Ptr {
                    fail!();
                }
                if exit_style {
                    code.put(&[0x8b, 0x3f]);
                } else {
                    code.put(&[0x8b, 0x00]);
                }
                last_kind = LastKind::U64;
            }
            OP_STORE_U8 => {
                if last_kind != LastKind::Ptr || imm_u64 > 255 {
                    fail!();
                }
                if exit_style {
                    code.put(&[0xc6, 0x07, imm_u64 as u8]);
                } else {
                    code.put(&[0xc6, 0x00, imm_u64 as u8]);
                }
            }
            OP_STORE_U16 => {
                if last_kind != LastKind::Ptr || imm_u64 > 65535 {
                    fail!();
                }
                if exit_style {
                    let mut insn = [0x66, 0xc7, 0x07, 0, 0];
                    wr16(&mut insn, 3, imm_u64 as u16);
                    code.put(&insn);
                } else {
                    let mut insn = [0x66, 0xc7, 0x00, 0, 0];
                    wr16(&mut insn, 3, imm_u64 as u16);
                    code.put(&insn);
                }
            }
            OP_STORE_U32 => {
                if last_kind != LastKind::Ptr || imm_u64 > u32::MAX as u64 {
                    fail!();
                }
                if exit_style {
                    let mut insn = [0xc7, 0x07, 0, 0, 0, 0];
                    wr32(&mut insn, 2, imm_u64 as u32);
                    code.put(&insn);
                } else {
                    let mut insn = [0xc7, 0x00, 0, 0, 0, 0];
                    wr32(&mut insn, 2, imm_u64 as u32);
                    code.put(&insn);
                }
            }
            OP_IS_NULL_PTR | OP_IS_NONNULL_PTR => {
                if last_kind != LastKind::Ptr {
                    fail!();
                }
                if exit_style {
                    code.put(&[0x85, 0xff]);
                    code.put(&[
                        0x0f,
                        if op == OP_IS_NULL_PTR { 0x94 } else { 0x95 },
                        0xc0,
                    ]);
                    code.put(&[0x0f, 0xb6, 0xf8]);
                } else {
                    code.put(&[0x85, 0xc0]);
                    code.put(&[
                        0x0f,
                        if op == OP_IS_NULL_PTR { 0x94 } else { 0x95 },
                        0xc0,
                    ]);
                    code.put(&[0x0f, 0xb6, 0xc0]);
                }
                last_kind = LastKind::Bool;
            }
            OP_NOT_BOOL => {
                if last_kind != LastKind::Bool {
                    fail!();
                }
                if exit_style {
                    code.put(&[0x83, 0xf7, 0x01]);
                } else {
                    code.put(&[0x83, 0xf0, 0x01]);
                }
            }
            OP_AND_BOOL => {
                if last_kind != LastKind::Bool || arg0 > 1 {
                    fail!();
                }
                if exit_style {
                    code.put(&[0x83, 0xe7, arg0 as u8]);
                } else {
                    code.put(&[0x83, 0xe0, arg0 as u8]);
                }
            }
            OP_OR_BOOL => {
                if last_kind != LastKind::Bool || arg0 > 1 {
                    fail!();
                }
                if exit_style {
                    code.put(&[0x83, 0xcf, arg0 as u8]);
                } else {
                    code.put(&[0x83, 0xc8, arg0 as u8]);
                }
            }
            OP_ADD_U64 => {
                if last_kind != LastKind::U64 || imm_u64 > u32::MAX as u64 {
                    fail!();
                }
                if exit_style {
                    let mut add_edi = [0x81, 0xc7, 0, 0, 0, 0];
                    wr32(&mut add_edi, 2, imm_u64 as u32);
                    code.put(&add_edi);
                } else {
                    let mut add_eax = [0x05, 0, 0, 0, 0];
                    wr32(&mut add_eax, 1, imm_u64 as u32);
                    code.put(&add_eax);
                }
            }
            OP_ADD_I64 => {
                if last_kind != LastKind::I64
                    || imm_i64 < i32::MIN as i64
                    || imm_i64 > i32::MAX as i64
                {
                    fail!();
                }
                if exit_style {
                    let mut add_edi = [0x81, 0xc7, 0, 0, 0, 0];
                    wr32(&mut add_edi, 2, imm_i64 as i32 as u32);
                    code.put(&add_edi);
                } else {
                    let mut add_eax = [0x05, 0, 0, 0, 0];
                    wr32(&mut add_eax, 1, imm_i64 as i32 as u32);
                    code.put(&add_eax);
                }
            }
            OP_SUB_I64 => {
                if last_kind != LastKind::I64
                    || imm_i64 < i32::MIN as i64
                    || imm_i64 > i32::MAX as i64
                {
                    fail!();
                }
                if exit_style {
                    let mut sub_edi = [0x81, 0xef, 0, 0, 0, 0];
                    wr32(&mut sub_edi, 2, imm_i64 as i32 as u32);
                    code.put(&sub_edi);
                } else {
                    let mut sub_eax = [0x2d, 0, 0, 0, 0];
                    wr32(&mut sub_eax, 1, imm_i64 as i32 as u32);
                    code.put(&sub_eax);
                }
            }
            OP_MUL_I64 => {
                if last_kind != LastKind::I64
                    || imm_i64 < i32::MIN as i64
                    || imm_i64 > i32::MAX as i64
                {
                    fail!();
                }
                if exit_style {
                    let mut imul_edi = [0x69, 0xff, 0, 0, 0, 0];
                    wr32(&mut imul_edi, 2, imm_i64 as i32 as u32);
                    code.put(&imul_edi);
                } else {
                    let mut imul_eax = [0x69, 0xc0, 0, 0, 0, 0];
                    wr32(&mut imul_eax, 2, imm_i64 as i32 as u32);
                    code.put(&imul_eax);
                }
            }
            OP_EQ_I64 | OP_LT_I64 | OP_GT_I64 | OP_NE_I64 | OP_LE_I64 | OP_GE_I64 => {
                if last_kind != LastKind::I64
                    || imm_i64 < i32::MIN as i64
                    || imm_i64 > i32::MAX as i64
                {
                    fail!();
                }
                let setcc = match op {
                    OP_EQ_I64 => 0x94,
                    OP_LT_I64 => 0x9c,
                    OP_GT_I64 => 0x9f,
                    OP_NE_I64 => 0x95,
                    OP_LE_I64 => 0x9e,
                    OP_GE_I64 => 0x9d,
                    _ => unreachable!(),
                };
                if exit_style {
                    let mut cmp_edi = [0x81, 0xff, 0, 0, 0, 0];
                    wr32(&mut cmp_edi, 2, imm_i64 as i32 as u32);
                    code.put(&cmp_edi);
                    code.put(&[0x0f, setcc, 0xc0]);
                    code.put(&[0x0f, 0xb6, 0xf8]);
                } else {
                    let mut cmp_eax = [0x3d, 0, 0, 0, 0];
                    wr32(&mut cmp_eax, 1, imm_i64 as i32 as u32);
                    code.put(&cmp_eax);
                    code.put(&[0x0f, setcc, 0xc0]);
                    code.put(&[0x0f, 0xb6, 0xc0]);
                }
                last_kind = LastKind::Bool;
            }
            OP_EXPECT_U64 | OP_EXPECT_I64 | OP_EXPECT_BOOL | OP_EXPECT_PTR => {
                let patch_off = match op {
                    OP_EXPECT_U64 => {
                        if last_kind != LastKind::U64 && last_kind != LastKind::I64 {
                            fail!();
                        }
                        if imm_u64 > u32::MAX as u64 {
                            fail!();
                        }
                        if last_kind == LastKind::I64 && imm_u64 > i32::MAX as u64 {
                            fail!();
                        }
                        if exit_style {
                            let mut cmp_edi = [0x81, 0xff, 0, 0, 0, 0];
                            wr32(&mut cmp_edi, 2, imm_u64 as u32);
                            let off = (code.len() + cmp_edi.len() + 2) as u32;
                            code.put(&cmp_edi);
                            off
                        } else {
                            let mut cmp_eax = [0x3d, 0, 0, 0, 0];
                            wr32(&mut cmp_eax, 1, imm_u64 as u32);
                            let off = (code.len() + cmp_eax.len() + 2) as u32;
                            code.put(&cmp_eax);
                            off
                        }
                    }
                    OP_EXPECT_I64 => {
                        if last_kind != LastKind::I64
                            || imm_i64 < i32::MIN as i64
                            || imm_i64 > i32::MAX as i64
                        {
                            fail!();
                        }
                        if exit_style {
                            let mut cmp_edi = [0x81, 0xff, 0, 0, 0, 0];
                            wr32(&mut cmp_edi, 2, imm_i64 as i32 as u32);
                            let off = (code.len() + cmp_edi.len() + 2) as u32;
                            code.put(&cmp_edi);
                            off
                        } else {
                            let mut cmp_eax = [0x3d, 0, 0, 0, 0];
                            wr32(&mut cmp_eax, 1, imm_i64 as i32 as u32);
                            let off = (code.len() + cmp_eax.len() + 2) as u32;
                            code.put(&cmp_eax);
                            off
                        }
                    }
                    OP_EXPECT_BOOL => {
                        if last_kind != LastKind::Bool {
                            fail!();
                        }
                        if exit_style {
                            let mut cmp_edi = [0x81, 0xff, 0, 0, 0, 0];
                            wr32(&mut cmp_edi, 2, if arg0 != 0 { 1 } else { 0 });
                            let off = (code.len() + cmp_edi.len() + 2) as u32;
                            code.put(&cmp_edi);
                            off
                        } else {
                            let mut cmp_eax = [0x3d, 0, 0, 0, 0];
                            wr32(&mut cmp_eax, 1, if arg0 != 0 { 1 } else { 0 });
                            let off = (code.len() + cmp_eax.len() + 2) as u32;
                            code.put(&cmp_eax);
                            off
                        }
                    }
                    OP_EXPECT_PTR => {
                        if last_kind != LastKind::Ptr || arg0 > 1 {
                            fail!();
                        }
                        if exit_style {
                            let cmp_edi_zero = [0x83, 0xff, 0];
                            let off = (code.len() + cmp_edi_zero.len() + 2) as u32;
                            code.put(&cmp_edi_zero);
                            off
                        } else {
                            let cmp_eax_zero = [0x83, 0xf8, 0];
                            let off = (code.len() + cmp_eax_zero.len() + 2) as u32;
                            code.put(&cmp_eax_zero);
                            off
                        }
                    }
                    _ => unreachable!(),
                };
                let mut fail_jump = [0x0f, 0x85, 0, 0, 0, 0];
                if op == OP_EXPECT_PTR && arg0 != 0 {
                    fail_jump[1] = 0x84;
                }
                code.put(&fail_jump);
                expect_patches.push(patch_off);
            }
            OP_BRANCH_BOOL => {
                if last_kind != LastKind::Bool || arg0 >= b.instr_count {
                    fail!();
                }
                if exit_style {
                    code.put(&[0x85, 0xff]);
                } else {
                    code.put(&[0x85, 0xc0]);
                }
                let patch_off = (code.len() + 2) as u32;
                code.put(&[0x0f, 0x85, 0, 0, 0, 0]);
                branch_patches.push(PcPatch {
                    patch_off,
                    target_pc: arg0,
                });
            }
            OP_RET_LAST => {
                if exit_style {
                    code.put(&[0xb8, 0x3c, 0, 0, 0, 0x0f, 0x05]);
                } else {
                    code.put(&[0xc3]);
                }
                saw_ret = true;
                break;
            }
            _ => fail!(),
        }
    }

    if !saw_ret {
        return false;
    }

    for patch in &branch_patches {
        let rel = pc_offs[patch.target_pc as usize] as i64 - (patch.patch_off as i64 + 4);
        if rel < i32::MIN as i64 || rel > i32::MAX as i64 {
            return false;
        }
        code.patch_u32(patch.patch_off as usize, rel as u32);
    }

    if !expect_patches.is_empty() {
        let fail_off = code.len() as u32;
        if exit_style {
            code.put(&[
                0xbf, 125, 0, 0, 0, 0xb8, 0x3c, 0, 0, 0, 0x0f, 0x05,
            ]);
        } else {
            code.put(&[0xb8, 125, 0, 0, 0, 0xc3]);
        }
        for patch_off in expect_patches {
            let rel = fail_off as i64 - (patch_off as i64 + 4);
            if rel < i32::MIN as i64 || rel > i32::MAX as i64 {
                return false;
            }
            code.patch_u32(patch_off as usize, rel as u32);
        }
    }

    if !data_patches.is_empty() {
        let layout = elf64::layout_for_codegen(code.len(), rodata.len(), data_sec.len());
        for patch in &data_patches {
            let target = if patch.sec == 2 {
                layout.data_va + patch.sec_off as u64
            } else {
                layout.rodata_va + patch.sec_off as u64
            };
            let rip_next = layout.text_va + patch.patch_off as u64 + 4;
            if !elf64::patch_pc32(&mut code.data, patch.patch_off as usize, target, rip_next) {
                return false;
            }
        }
    }

    true
}

pub fn compile_pure_to_elf64_obj(b: &Blob, obj_path: &Path, symbol: &str) -> Result<Vec<u8>, i32> {
    let mut code = CodeBuf::new();
    let mut rodata = CodeBuf::new();
    let mut data = CodeBuf::new();
    if !compile_pure_blob_to_x86(b, false, &mut code, &mut rodata, &mut data) {
        return Err(2);
    }
    if !rodata.data.is_empty() || !data.data.is_empty() {
        // rodata/data objects need section relocs — fall back to direct exec emit for now
        if !compile_pure_blob_to_x86(b, true, &mut code, &mut rodata, &mut data) {
            return Err(2);
        }
        return Err(2);
    }
    let sym = crate::elf64::ObjSymbol {
        name: symbol.to_string(),
        info: 0x12,
        shndx: 1,
        value: 0,
        size: code.len() as u64,
    };
    crate::elf64::emit_obj_file(obj_path, &code.data, &[sym], &[]).map_err(|_| 3)?;
    Ok(code.data)
}

pub fn compile_pure_to_elf_via_link(b: &Blob, path: &Path, symbol: &str) -> Result<usize, i32> {
    let tmp = std::env::temp_dir().join(format!(
        "nano-jit-rs-{}.o",
        std::process::id()
    ));
    let _code = match compile_pure_to_elf64_obj(b, &tmp, symbol) {
        Ok(c) => c,
        Err(2) => {
            // blobs with rodata/data: direct exec (exit_style) still correct
            return compile_pure_to_elf_exit(b, path);
        }
        Err(e) => return Err(e),
    };
    let n = crate::elf64::link_exe_from_obj(path, symbol, &tmp)
        .map_err(|_| {
            eprintln!("aot-elf64-code=write_fail path={}", path.display());
            3
        })?;
    let _ = std::fs::remove_file(&tmp);
    Ok(n)
}

pub fn compile_pure_to_elf_exit(b: &Blob, path: &Path) -> Result<usize, i32> {
    let mut code = CodeBuf::new();
    let mut rodata = CodeBuf::new();
    let mut data = CodeBuf::new();
    if !compile_pure_blob_to_x86(b, true, &mut code, &mut rodata, &mut data) {
        eprintln!("aot-elf64-code=unsupported_blob");
        return Err(2);
    }
    elf64::emit_exec_sections(path, &code.data, &rodata.data, &data.data).map_err(|_| {
        eprintln!("aot-elf64-code=write_fail path={}", path.display());
        3
    })?;
    Ok(code.len())
}

pub fn compile_pure_to_elf_exit_direct(b: &Blob, path: &Path) -> Result<u8, i32> {
    use super::pure_eval::{eval_pure, value_to_exit_code};
    let v = eval_pure(b).ok_or_else(|| {
        eprintln!("aot-elf64-exit=unsupported_blob");
        2
    })?;
    let exit = value_to_exit_code(v).ok_or_else(|| {
        eprintln!("aot-elf64-exit=unsupported_blob");
        2
    })?;
    elf64::emit_exit(path, exit).map_err(|_| {
        eprintln!("aot-elf64-exit=write_fail path={}", path.display());
        3
    })?;
    Ok(exit)
}
