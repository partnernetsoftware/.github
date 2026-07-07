//! aarch64 codegen for pure `.lbin` blobs (exit-style VM lowering).

use crate::elf64;
use crate::lbin::{
    rd32, Blob, OP_ADD_I64, OP_ADD_U64, OP_CONST_BOOL, OP_CONST_I64, OP_CONST_U64, OP_EXPECT_BOOL,
    OP_EXPECT_I64, OP_EXPECT_U64, OP_RET_LAST,
};
use crate::value::{imm64, imm_i64};
use std::path::Path;

#[derive(Clone, Copy, PartialEq, Eq)]
enum LastKind {
    None,
    U64,
    I64,
    Bool,
}

struct CodeBuf {
    data: Vec<u8>,
}

impl CodeBuf {
    fn new() -> Self {
        Self { data: Vec::new() }
    }

    fn emit_u32(&mut self, insn: u32) {
        self.data.extend_from_slice(&insn.to_le_bytes());
    }

    fn patch_u32(&mut self, off: usize, v: u32) {
        self.data[off..off + 4].copy_from_slice(&v.to_le_bytes());
    }

    fn len(&self) -> usize {
        self.data.len()
    }
}

fn movz_x(rd: u8, imm16: u32) -> u32 {
    0xd280_0000 | ((imm16 & 0xffff) << 5) | u32::from(rd)
}

fn add_imm_x(rd: u8, rn: u8, imm12: u32) -> u32 {
    0x9100_0000 | ((imm12 & 0xfff) << 10) | (u32::from(rn) << 5) | u32::from(rd)
}

fn subs_xzr_xn_imm(xn: u8, imm12: u32) -> u32 {
    0xf100_0000 | ((imm12 & 0xfff) << 10) | (u32::from(xn) << 5) | 31
}

fn b_ne(rel19: i32) -> u32 {
    let enc = ((rel19 >> 2) as u32) & 0x7ffff;
    0x5400_0001 | (enc << 5)
}

fn emit_exit_syscall(code: &mut CodeBuf) {
    code.emit_u32(movz_x(8, 93));
    code.emit_u32(0xd400_0001); // svc #0
}

fn compile_pure_blob_to_aarch64_exit(b: &Blob, code: &mut CodeBuf) -> bool {
    let mut last_kind = LastKind::None;
    let mut saw_ret = false;
    let mut expect_patches: Vec<u32> = Vec::new();

    for pc in 0..b.instr_count {
        let ins = match b.instr_row(pc) {
            Some(r) => r,
            None => return false,
        };
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
                if imm_u64 > 0xffff {
                    fail!();
                }
                code.emit_u32(movz_x(0, imm_u64 as u32));
                last_kind = LastKind::U64;
            }
            OP_CONST_I64 => {
                if imm_i64 < 0 || imm_i64 > 0xffff {
                    fail!();
                }
                code.emit_u32(movz_x(0, imm_i64 as u32));
                last_kind = LastKind::I64;
            }
            OP_CONST_BOOL => {
                code.emit_u32(movz_x(0, if arg0 != 0 { 1 } else { 0 }));
                last_kind = LastKind::Bool;
            }
            OP_ADD_U64 => {
                if last_kind != LastKind::U64 || imm_u64 > 0xfff {
                    fail!();
                }
                code.emit_u32(add_imm_x(0, 0, imm_u64 as u32));
            }
            OP_ADD_I64 => {
                if last_kind != LastKind::I64
                    || imm_i64 < 0
                    || imm_i64 > 0xfff
                {
                    fail!();
                }
                code.emit_u32(add_imm_x(0, 0, imm_i64 as u32));
            }
            OP_EXPECT_U64 => {
                if last_kind != LastKind::U64 || imm_u64 > 0xfff {
                    fail!();
                }
                code.emit_u32(subs_xzr_xn_imm(0, imm_u64 as u32));
                let patch_off = code.len();
                code.emit_u32(b_ne(0));
                expect_patches.push(patch_off as u32);
            }
            OP_EXPECT_I64 => {
                if last_kind != LastKind::I64
                    || imm_i64 < 0
                    || imm_i64 > 0xfff
                {
                    fail!();
                }
                code.emit_u32(subs_xzr_xn_imm(0, imm_i64 as u32));
                let patch_off = code.len();
                code.emit_u32(b_ne(0));
                expect_patches.push(patch_off as u32);
            }
            OP_EXPECT_BOOL => {
                if last_kind != LastKind::Bool {
                    fail!();
                }
                code.emit_u32(subs_xzr_xn_imm(0, if arg0 != 0 { 1 } else { 0 }));
                let patch_off = code.len();
                code.emit_u32(b_ne(0));
                expect_patches.push(patch_off as u32);
            }
            OP_RET_LAST => {
                emit_exit_syscall(code);
                saw_ret = true;
                break;
            }
            _ => fail!(),
        }
    }

    if !saw_ret {
        return false;
    }

    if !expect_patches.is_empty() {
        let fail_off = code.len() as u32;
        code.emit_u32(movz_x(0, 125));
        emit_exit_syscall(code);
        for patch_off in expect_patches {
            let rel = fail_off as i32 - patch_off as i32;
            if rel < -0x100000 || rel > 0xfffff || (rel & 3) != 0 {
                return false;
            }
            code.patch_u32(patch_off as usize, b_ne(rel));
        }
    }

    true
}

pub fn compile_pure_to_elf_exit(b: &Blob, path: &Path) -> Result<(usize, u8), i32> {
    use super::pure_eval::{eval_pure, value_to_exit_code};
    let v = eval_pure(b).ok_or_else(|| {
        eprintln!("aot-aarch64-exit=unsupported_blob");
        2
    })?;
    let exit = value_to_exit_code(v).ok_or_else(|| {
        eprintln!("aot-aarch64-exit=unsupported_blob");
        2
    })?;
    let mut code = CodeBuf::new();
    if !compile_pure_blob_to_aarch64_exit(b, &mut code) {
        eprintln!("aot-aarch64-exit=unsupported_blob");
        return Err(2);
    }
    let logical = elf64::emit_exec_rx_aarch64(path, &code.data)
        .map_err(|_| {
            eprintln!("aot-aarch64-exit=write_fail path={}", path.display());
            3
        })?
        .0;
    Ok((logical, exit))
}

pub fn compile_pure_to_elf_code(b: &Blob, path: &Path) -> Result<usize, i32> {
    let mut code = CodeBuf::new();
    if !compile_pure_blob_to_aarch64_exit(b, &mut code) {
        eprintln!("aot-aarch64-code=unsupported_blob");
        return Err(2);
    }
    elf64::emit_exec_rx_aarch64(path, &code.data)
        .map(|(n, _)| n)
        .map_err(|_| {
            eprintln!("aot-aarch64-code=write_fail path={}", path.display());
            3
        })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lbin::parse_blob;

    #[test]
    fn min_slice_vm_aot_smoke() {
        let root = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"));
        let lisp = root.join("../nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp");
        let tmp = std::env::temp_dir().join("nano-rs-min-a64.lbin");
        crate::compile::compile_path(&lisp, &tmp).unwrap();
        let data = std::fs::read(&tmp).unwrap();
        let blob = parse_blob(&data).unwrap();
        let mut code = CodeBuf::new();
        assert!(compile_pure_blob_to_aarch64_exit(&blob, &mut code));
        assert!(code.len() >= 16);
    }
}
