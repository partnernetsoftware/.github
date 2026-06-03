//! Multi-function AOT from `compile::Module` — port of `compile_aot_module_to_elf64_obj`.

use crate::compile::{InstrDef, Module, SrcForm};
use crate::compile::CompileError;
use crate::elf64::{emit_obj_file, link_exe_from_obj, ObjRela, ObjSymbol};
use std::collections::HashMap;
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

struct BranchPatch {
    patch_off: u32,
    target_pc: u32,
}

struct LabelDef {
    name: String,
    pc: u32,
}

fn wr32(buf: &mut [u8], off: usize, v: u32) {
    buf[off..off + 4].copy_from_slice(&v.to_le_bytes());
}

fn find_label(labels: &[LabelDef], name: &str) -> Option<u32> {
    labels.iter().find(|l| l.name == name).map(|l| l.pc)
}

fn build_label_table(body: &[InstrDef]) -> (Vec<LabelDef>, u32) {
    let mut labels = Vec::new();
    let mut emitted = 0u32;
    for ins in body {
        if ins.form == SrcForm::Label {
            let name = ins.name.as_deref().unwrap_or("");
            if labels.iter().any(|l: &LabelDef| l.name == name) {
                return (Vec::new(), 0);
            }
            labels.push(LabelDef {
                name: name.to_string(),
                pc: emitted,
            });
        } else {
            emitted += 1;
        }
    }
    (labels, emitted)
}

fn infer_func_return_kind(m: &Module, func_idx: usize, kinds: &mut [LastKind], state: &mut [u8]) -> bool {
    if state[func_idx] == 2 {
        return kinds[func_idx] != LastKind::None;
    }
    if state[func_idx] == 1 {
        return false;
    }
    state[func_idx] = 1;
    let func = &m.funcs[func_idx];
    let mut last = LastKind::None;
    for ins in &func.instrs {
        if ins.form == SrcForm::Label {
            continue;
        }
        last = match ins.form {
            SrcForm::ConstU64 | SrcForm::AddU64 => LastKind::U64,
            SrcForm::ConstI64 | SrcForm::AddI64 | SrcForm::SubI64 | SrcForm::MulI64 => LastKind::I64,
            SrcForm::ConstBool | SrcForm::NotBool | SrcForm::AndBool | SrcForm::OrBool => {
                LastKind::Bool
            }
            SrcForm::NullPtr | SrcForm::AddPtr | SrcForm::SubPtr | SrcForm::U64ToPtr => LastKind::Ptr,
            SrcForm::PtrToU64 | SrcForm::LoadU8 | SrcForm::LoadU16 | SrcForm::LoadU32 => {
                LastKind::U64
            }
            SrcForm::EqI64
            | SrcForm::LtI64
            | SrcForm::GtI64
            | SrcForm::NeI64
            | SrcForm::LeI64
            | SrcForm::GeI64
            | SrcForm::IsNullPtr
            | SrcForm::IsNonnullPtr => LastKind::Bool,
            SrcForm::CallFunc => {
                let name = match ins.name.as_deref() {
                    Some(n) => n,
                    None => {
                        state[func_idx] = 0;
                        return false;
                    }
                };
                let ti = m.funcs.iter().position(|f| f.name == name);
                let ti = match ti {
                    Some(i) => i,
                    None => {
                        state[func_idx] = 0;
                        return false;
                    }
                };
                if !infer_func_return_kind(m, ti, kinds, state) {
                    state[func_idx] = 0;
                    return false;
                }
                kinds[ti]
            }
            SrcForm::ExpectU64 | SrcForm::ExpectI64 | SrcForm::ExpectBool | SrcForm::ExpectPtr
            | SrcForm::Branch | SrcForm::StoreU8 | SrcForm::StoreU16 | SrcForm::StoreU32 => last,
            _ => {
                state[func_idx] = 0;
                return false;
            }
        };
    }
    if last == LastKind::None {
        state[func_idx] = 0;
        return false;
    }
    kinds[func_idx] = last;
    state[func_idx] = 2;
    true
}

fn infer_main_return_kind(m: &Module, func_kinds: &[LastKind]) -> LastKind {
    let mut last = LastKind::None;
    for ins in &m.instrs {
        if ins.form == SrcForm::Label {
            continue;
        }
        last = match ins.form {
            SrcForm::ConstU64 | SrcForm::AddU64 => LastKind::U64,
            SrcForm::ConstI64 | SrcForm::AddI64 | SrcForm::SubI64 | SrcForm::MulI64 => LastKind::I64,
            SrcForm::ConstBool | SrcForm::NotBool | SrcForm::AndBool | SrcForm::OrBool => {
                LastKind::Bool
            }
            SrcForm::NullPtr | SrcForm::AddPtr | SrcForm::SubPtr | SrcForm::U64ToPtr => LastKind::Ptr,
            SrcForm::PtrToU64 | SrcForm::LoadU8 | SrcForm::LoadU16 | SrcForm::LoadU32 => {
                LastKind::U64
            }
            SrcForm::EqI64
            | SrcForm::LtI64
            | SrcForm::GtI64
            | SrcForm::NeI64
            | SrcForm::LeI64
            | SrcForm::GeI64
            | SrcForm::IsNullPtr
            | SrcForm::IsNonnullPtr => LastKind::Bool,
            SrcForm::CallFunc => {
                let name = ins.name.as_deref().unwrap_or("");
                m.funcs
                    .iter()
                    .position(|f| f.name == name)
                    .map(|i| func_kinds[i])
                    .unwrap_or(LastKind::None)
            }
            SrcForm::ExpectU64 | SrcForm::ExpectI64 | SrcForm::ExpectBool | SrcForm::ExpectPtr
            | SrcForm::Branch | SrcForm::StoreU8 | SrcForm::StoreU16 | SrcForm::StoreU32 => last,
            _ => return LastKind::None,
        };
    }
    last
}

fn compile_body(
    m: &Module,
    body: &[InstrDef],
    func_kinds: &[LastKind],
    code: &mut CodeBuf,
    calls: &mut Vec<CallPatch>,
    expect_patches: &mut Vec<u32>,
    branch_patches: &mut Vec<BranchPatch>,
    pc_offs: &mut [u32],
) -> Result<(), ()> {
    let (labels, emitted_stmts) = build_label_table(body);
    if pc_offs.len() != emitted_stmts as usize + 1 {
        return Err(());
    }
    let mut last_kind = LastKind::None;
    let mut emitted_pc = 0usize;
    for ins in body {
        if ins.form == SrcForm::Label {
            continue;
        }
        pc_offs[emitted_pc] = code.len() as u32;
        emitted_pc += 1;

        macro_rules! fail {
            () => {
                return Err(())
            };
        }

        match ins.form {
            SrcForm::ConstU64 => {
                if ins.imm > u32::MAX as u64 {
                    fail!();
                }
                let mut mov = [0xb8, 0, 0, 0, 0];
                wr32(&mut mov, 1, ins.imm as u32);
                code.put(&mov);
                last_kind = LastKind::U64;
            }
            SrcForm::ConstI64 => {
                let v = ins.imm as i64;
                if v < i32::MIN as i64 || v > i32::MAX as i64 {
                    fail!();
                }
                let mut mov = [0xb8, 0, 0, 0, 0];
                wr32(&mut mov, 1, ins.imm as i32 as u32);
                code.put(&mov);
                last_kind = LastKind::I64;
            }
            SrcForm::ConstBool => {
                let mut mov = [0xb8, 0, 0, 0, 0];
                wr32(&mut mov, 1, if ins.imm != 0 { 1 } else { 0 });
                code.put(&mov);
                last_kind = LastKind::Bool;
            }
            SrcForm::AddU64 => {
                if last_kind != LastKind::U64 || ins.imm > u32::MAX as u64 {
                    fail!();
                }
                let mut add = [0x05, 0, 0, 0, 0];
                wr32(&mut add, 1, ins.imm as u32);
                code.put(&add);
            }
            SrcForm::AddI64 => {
                let v = ins.imm as i64;
                if last_kind != LastKind::I64 || v < i32::MIN as i64 || v > i32::MAX as i64 {
                    fail!();
                }
                let mut add = [0x05, 0, 0, 0, 0];
                wr32(&mut add, 1, ins.imm as i32 as u32);
                code.put(&add);
            }
            SrcForm::SubI64 => {
                let v = ins.imm as i64;
                if last_kind != LastKind::I64 || v < i32::MIN as i64 || v > i32::MAX as i64 {
                    fail!();
                }
                let mut sub = [0x2d, 0, 0, 0, 0];
                wr32(&mut sub, 1, ins.imm as i32 as u32);
                code.put(&sub);
            }
            SrcForm::MulI64 => {
                let v = ins.imm as i64;
                if last_kind != LastKind::I64 || v < i32::MIN as i64 || v > i32::MAX as i64 {
                    fail!();
                }
                let mut imul = [0x69, 0xc0, 0, 0, 0, 0];
                wr32(&mut imul, 2, ins.imm as i32 as u32);
                code.put(&imul);
            }
            SrcForm::LtI64 => {
                let v = ins.imm as i64;
                if last_kind != LastKind::I64 || v < i32::MIN as i64 || v > i32::MAX as i64 {
                    fail!();
                }
                let mut cmp = [0x3d, 0, 0, 0, 0];
                wr32(&mut cmp, 1, ins.imm as i32 as u32);
                code.put(&cmp);
                code.put(&[0x0f, 0x9c, 0xc0]);
                code.put(&[0x0f, 0xb6, 0xc0]);
                last_kind = LastKind::Bool;
            }
            SrcForm::EqI64 => {
                let v = ins.imm as i64;
                if last_kind != LastKind::I64 || v < i32::MIN as i64 || v > i32::MAX as i64 {
                    fail!();
                }
                let mut cmp = [0x3d, 0, 0, 0, 0];
                wr32(&mut cmp, 1, ins.imm as i32 as u32);
                code.put(&cmp);
                code.put(&[0x0f, 0x94, 0xc0]);
                code.put(&[0x0f, 0xb6, 0xc0]);
                last_kind = LastKind::Bool;
            }
            SrcForm::GtI64 | SrcForm::NeI64 | SrcForm::LeI64 | SrcForm::GeI64 => {
                let v = ins.imm as i64;
                if last_kind != LastKind::I64 || v < i32::MIN as i64 || v > i32::MAX as i64 {
                    fail!();
                }
                let setcc = match ins.form {
                    SrcForm::GtI64 => 0x9f,
                    SrcForm::NeI64 => 0x95,
                    SrcForm::LeI64 => 0x9e,
                    SrcForm::GeI64 => 0x9d,
                    _ => fail!(),
                };
                let mut cmp = [0x3d, 0, 0, 0, 0];
                wr32(&mut cmp, 1, ins.imm as i32 as u32);
                code.put(&cmp);
                code.put(&[0x0f, setcc, 0xc0]);
                code.put(&[0x0f, 0xb6, 0xc0]);
                last_kind = LastKind::Bool;
            }
            SrcForm::NotBool => {
                if last_kind != LastKind::Bool {
                    fail!();
                }
                code.put(&[0x83, 0xf0, 0x01]);
            }
            SrcForm::AndBool => {
                if last_kind != LastKind::Bool || ins.imm > 1 {
                    fail!();
                }
                code.put(&[0x83, 0xe0, ins.imm as u8]);
            }
            SrcForm::OrBool => {
                if last_kind != LastKind::Bool || ins.imm > 1 {
                    fail!();
                }
                code.put(&[0x83, 0xc8, ins.imm as u8]);
            }
            SrcForm::ExpectU64 => {
                if last_kind != LastKind::U64 && last_kind != LastKind::I64 {
                    fail!();
                }
                if ins.imm > u32::MAX as u64 {
                    fail!();
                }
                let mut cmp = [0x3d, 0, 0, 0, 0];
                wr32(&mut cmp, 1, ins.imm as u32);
                let patch_off = (code.len() + cmp.len() + 2) as u32;
                code.put(&cmp);
                code.put(&[0x0f, 0x85, 0, 0, 0, 0]);
                expect_patches.push(patch_off);
            }
            SrcForm::ExpectI64 => {
                let v = ins.imm as i64;
                if last_kind != LastKind::I64 || v < i32::MIN as i64 || v > i32::MAX as i64 {
                    fail!();
                }
                let mut cmp = [0x3d, 0, 0, 0, 0];
                wr32(&mut cmp, 1, ins.imm as i32 as u32);
                let patch_off = (code.len() + cmp.len() + 2) as u32;
                code.put(&cmp);
                code.put(&[0x0f, 0x85, 0, 0, 0, 0]);
                expect_patches.push(patch_off);
            }
            SrcForm::ExpectBool => {
                if last_kind != LastKind::Bool {
                    fail!();
                }
                let mut cmp = [0x3d, 0, 0, 0, 0];
                wr32(&mut cmp, 1, if ins.imm != 0 { 1 } else { 0 });
                let patch_off = (code.len() + cmp.len() + 2) as u32;
                code.put(&cmp);
                code.put(&[0x0f, 0x85, 0, 0, 0, 0]);
                expect_patches.push(patch_off);
            }
            SrcForm::Branch => {
                if last_kind != LastKind::Bool {
                    fail!();
                }
                let label = ins.name.as_deref().ok_or(())?;
                let target_pc = find_label(&labels, label).ok_or(())?;
                code.put(&[0x85, 0xc0]);
                let patch_off = (code.len() + 2) as u32;
                code.put(&[0x0f, 0x85, 0, 0, 0, 0]);
                branch_patches.push(BranchPatch {
                    patch_off,
                    target_pc,
                });
            }
            SrcForm::CallFunc => {
                let name = ins.name.as_deref().ok_or(())?;
                if !m.funcs.iter().any(|f| f.name == name) {
                    fail!();
                }
                let patch_off = (code.len() + 1) as u32;
                code.put(&[0xe8, 0, 0, 0, 0]);
                calls.push(CallPatch {
                    patch_off,
                    target: name.to_string(),
                });
                let ti = m.funcs.iter().position(|f| f.name == name).ok_or(())?;
                last_kind = func_kinds[ti];
            }
            _ => fail!(),
        }
    }
    Ok(())
}

fn patch_expects(code: &mut CodeBuf, expect_patches: &[u32]) -> Result<(), ()> {
    if expect_patches.is_empty() {
        return Ok(());
    }
    let fail_off = code.len() as u32;
    code.put(&[0xb8, 125, 0, 0, 0, 0xc3]);
    for &patch_off in expect_patches {
        let rel = fail_off as i64 - (i64::from(patch_off) + 4);
        if rel < i32::MIN as i64 || rel > i32::MAX as i64 {
            return Err(());
        }
        code.patch_u32(patch_off as usize, rel as u32);
    }
    Ok(())
}

fn patch_branches(code: &mut CodeBuf, branch_patches: &[BranchPatch], pc_offs: &[u32]) -> Result<(), ()> {
    for patch in branch_patches {
        let target = pc_offs.get(patch.target_pc as usize).copied().ok_or(())?;
        let rel = target as i64 - (patch.patch_off as i64 + 4);
        if rel < i32::MIN as i64 || rel > i32::MAX as i64 {
            return Err(());
        }
        code.patch_u32(patch.patch_off as usize, rel as u32);
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

    let n = m.funcs.len();
    let mut func_kinds = vec![LastKind::None; n];
    let mut state = vec![0u8; n];
    for i in 0..n {
        if !infer_func_return_kind(m, i, &mut func_kinds, &mut state) {
            return Err(CompileError::LowerFail {
                reason: "infer_return_kind",
            });
        }
    }
    if infer_main_return_kind(m, &func_kinds) == LastKind::None {
        return Err(CompileError::LowerFail {
            reason: "infer_main_return",
        });
    }

    let mut text = CodeBuf::new();
    let mut syms: Vec<ObjSymbol> = Vec::new();
    let mut sym_idx: HashMap<String, u32> = HashMap::new();
    let mut relas: Vec<ObjRela> = Vec::new();
    let mut func_starts: Vec<usize> = Vec::new();
    let mut all_calls: Vec<CallPatch> = Vec::new();

    for (i, func) in m.funcs.iter().enumerate() {
        func_starts.push(text.len());
        let (_, emitted) = build_label_table(&func.instrs);
        let mut pc_offs = vec![0u32; emitted as usize + 1];
        let mut calls = Vec::new();
        let mut expects = Vec::new();
        let mut branches = Vec::new();
        compile_body(
            m,
            &func.instrs,
            &func_kinds,
            &mut text,
            &mut calls,
            &mut expects,
            &mut branches,
            &mut pc_offs,
        )
        .map_err(|_| CompileError::LowerFail {
            reason: "unsupported_func",
        })?;
        patch_branches(&mut text, &branches, &pc_offs).map_err(|_| CompileError::LowerFail {
            reason: "branch_oob",
        })?;
        text.put(&[0xc3]);
        patch_expects(&mut text, &expects).map_err(|_| CompileError::LowerFail {
            reason: "expect_oob",
        })?;
        let idx = (i + 1) as u32;
        sym_idx.insert(func.name.clone(), idx);
        syms.push(ObjSymbol {
            name: func.name.clone(),
            info: 0x02,
            shndx: 1,
            value: func_starts[i] as u64,
            size: (text.len() - func_starts[i]) as u64,
        });
        for cp in calls {
            all_calls.push(cp);
        }
    }

    let main_off = text.len();
    let (_, main_emitted) = build_label_table(&m.instrs);
    let mut main_pc = vec![0u32; main_emitted as usize + 1];
    let mut main_calls = Vec::new();
    let mut main_expects = Vec::new();
    let mut main_branches = Vec::new();
    compile_body(
        m,
        &m.instrs,
        &func_kinds,
        &mut text,
        &mut main_calls,
        &mut main_expects,
        &mut main_branches,
        &mut main_pc,
    )
    .map_err(|_| CompileError::LowerFail {
        reason: "unsupported_main",
    })?;
    patch_branches(&mut text, &main_branches, &main_pc).map_err(|_| CompileError::LowerFail {
        reason: "main_branch_oob",
    })?;
    text.put(&[0xc3]);
    patch_expects(&mut text, &main_expects).map_err(|_| CompileError::LowerFail {
        reason: "main_expect_oob",
    })?;

    let entry_idx = (syms.len() + 1) as u32;
    sym_idx.insert(entry_symbol.to_string(), entry_idx);
    syms.push(ObjSymbol {
        name: entry_symbol.to_string(),
        info: 0x12,
        shndx: 1,
        value: main_off as u64,
        size: (text.len() - main_off) as u64,
    });

    all_calls.extend(main_calls);

    for cp in all_calls {
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

    let tmp = std::env::temp_dir().join(format!("nano-jit-rs-mf-{}.o", std::process::id()));
    emit_obj_file(&tmp, &text.data, &syms, &relas).map_err(|_| CompileError::WriteFail {
        path: tmp.display().to_string(),
    })?;
    let link = link_exe_from_obj(out_path, entry_symbol, &tmp).map_err(|_| {
        CompileError::WriteFail {
            path: out_path.display().to_string(),
        }
    })?;
    let _ = std::fs::remove_file(&tmp);
    Ok(link.code_bytes)
}
