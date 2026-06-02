//! Multi-function AOT from `compile::Module` — port of `compile_aot_module_to_elf64_obj`.

use crate::compile::{InstrDef, Module, SrcForm};
use crate::compile::CompileError;
use crate::elf64::{emit_obj_file, link_exe_from_obj, ObjRela, ObjSymbol};
use std::collections::HashMap;
use std::path::Path;

struct CodeBuf {
    data: Vec<u8>,
}

impl CodeBuf {
    fn new() -> Self {
        Self { data: Vec::new() }
    }
    fn put(&mut self, b: &[u8]) {
        self.data.extend_from_slice(b);
    }
    fn len(&self) -> usize {
        self.data.len()
    }
    fn patch_u32(&mut self, off: usize, v: u32) {
        self.data[off..off + 4].copy_from_slice(&v.to_le_bytes());
    }
}

struct CallPatch {
    patch_off: u32,
    target: String,
}

fn wr32(buf: &mut [u8], off: usize, v: u32) {
    buf[off..off + 4].copy_from_slice(&v.to_le_bytes());
}

fn compile_body(
    m: &Module,
    body: &[InstrDef],
    code: &mut CodeBuf,
    calls: &mut Vec<CallPatch>,
    expect_patches: &mut Vec<u32>,
) -> Result<(), ()> {
    let mut last_is_u64 = false;
    for ins in body {
        if ins.form == SrcForm::Label || ins.form == SrcForm::ParamI64 {
            continue;
        }
        match ins.form {
            SrcForm::ConstU64 => {
                if ins.imm > u32::MAX as u64 {
                    return Err(());
                }
                let mut mov = [0xb8, 0, 0, 0, 0];
                wr32(&mut mov, 1, ins.imm as u32);
                code.put(&mov);
                last_is_u64 = true;
            }
            SrcForm::ConstI64 => {
                let v = ins.imm as i64;
                if v < i32::MIN as i64 || v > i32::MAX as i64 {
                    return Err(());
                }
                let mut mov = [0xb8, 0, 0, 0, 0];
                wr32(&mut mov, 1, ins.imm as i32 as u32);
                code.put(&mov);
                last_is_u64 = true;
            }
            SrcForm::AddU64 => {
                if !last_is_u64 || ins.imm > u32::MAX as u64 {
                    return Err(());
                }
                let mut add = [0x05, 0, 0, 0, 0];
                wr32(&mut add, 1, ins.imm as u32);
                code.put(&add);
            }
            SrcForm::ExpectU64 => {
                if !last_is_u64 || ins.imm > u32::MAX as u64 {
                    return Err(());
                }
                let mut cmp = [0x3d, 0, 0, 0, 0];
                wr32(&mut cmp, 1, ins.imm as u32);
                let patch_off = (code.len() + cmp.len() + 2) as u32;
                code.put(&cmp);
                code.put(&[0x0f, 0x85, 0, 0, 0, 0]);
                expect_patches.push(patch_off);
            }
            SrcForm::CallFunc => {
                let name = ins.name.as_deref().ok_or(())?;
                if !m.funcs.iter().any(|f| f.name == name) {
                    return Err(());
                }
                let patch_off = (code.len() + 1) as u32;
                code.put(&[0xe8, 0, 0, 0, 0]);
                calls.push(CallPatch {
                    patch_off,
                    target: name.to_string(),
                });
                last_is_u64 = true;
            }
            _ => return Err(()),
        }
    }
    Ok(())
}

pub fn compile_module_to_elf64_exe(
    m: &Module,
    out_path: &Path,
    entry_symbol: &str,
) -> Result<usize, CompileError> {
    if entry_symbol.is_empty() {
        return Err(CompileError::LowerFail {
            reason: "bad_entry_symbol",
        });
    }
    if m.funcs.is_empty() {
        return Err(CompileError::LowerFail {
            reason: "not_multi_func",
        });
    }
    if m.funcs.iter().any(|f| f.name == entry_symbol) {
        return Err(CompileError::LowerFail {
            reason: "entry_is_local",
        });
    }

    let mut text = CodeBuf::new();
    let mut syms: Vec<ObjSymbol> = Vec::new();
    let mut sym_idx: HashMap<String, u32> = HashMap::new();
    let mut relas: Vec<ObjRela> = Vec::new();
    let mut main_calls: Vec<CallPatch> = Vec::new();
    let mut main_expects: Vec<u32> = Vec::new();

    for (i, func) in m.funcs.iter().enumerate() {
        let off = text.len();
        let mut dummy = Vec::new();
        compile_body(m, &func.instrs, &mut text, &mut dummy, &mut Vec::new()).map_err(|_| {
            CompileError::LowerFail {
                reason: "unsupported_func",
            }
        })?;
        text.put(&[0xc3]);
        let idx = (i + 1) as u32;
        sym_idx.insert(func.name.clone(), idx);
        syms.push(ObjSymbol {
            name: func.name.clone(),
            info: 0x02,
            shndx: 1,
            value: off as u64,
            size: (text.len() - off) as u64,
        });
    }

    let main_off = text.len();
    compile_body(
        m,
        &m.instrs,
        &mut text,
        &mut main_calls,
        &mut main_expects,
    )
    .map_err(|_| CompileError::LowerFail {
        reason: "unsupported_main",
    })?;
    text.put(&[0xc3]);

    let entry_idx = (syms.len() + 1) as u32;
    sym_idx.insert(entry_symbol.to_string(), entry_idx);
    syms.push(ObjSymbol {
        name: entry_symbol.to_string(),
        info: 0x12,
        shndx: 1,
        value: main_off as u64,
        size: (text.len() - main_off) as u64,
    });

    for cp in &main_calls {
        let target_idx = *sym_idx.get(&cp.target).ok_or(CompileError::LowerFail {
            reason: "call_target_missing",
        })?;
        relas.push(ObjRela {
            offset: u64::from(cp.patch_off),
            sym_idx: target_idx,
            r#type: 4,
            addend: -4,
        });
    }

    if !main_expects.is_empty() {
        let fail_off = text.len() as u32;
        text.put(&[0xb8, 125, 0, 0, 0, 0xc3]);
        for patch_off in main_expects {
            let rel = fail_off as i64 - (patch_off as i64 + 4);
            if rel < i32::MIN as i64 || rel > i32::MAX as i64 {
                return Err(CompileError::LowerFail {
                    reason: "expect_oob",
                });
            }
            text.patch_u32(patch_off as usize, rel as u32);
        }
    }

    let tmp = std::env::temp_dir().join(format!("nano-jit-rs-mf-{}.o", std::process::id()));
    emit_obj_file(&tmp, &text.data, &syms, &relas).map_err(|_| CompileError::WriteFail {
        path: tmp.display().to_string(),
    })?;
    let code_bytes = link_exe_from_obj(out_path, entry_symbol, &tmp).map_err(|_| {
        CompileError::WriteFail {
            path: out_path.display().to_string(),
        }
    })?;
    let _ = std::fs::remove_file(&tmp);
    Ok(code_bytes)
}
