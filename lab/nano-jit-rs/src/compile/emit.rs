use super::parse::{InstrDef, Module, SrcForm};
use crate::lbin::{
    CONST_STRING, HEADER_SIZE, MAGIC_LBIN, OP_ADD_I64, OP_ADD_PTR, OP_ADD_U64,
    OP_AND_BOOL, OP_BRANCH_BOOL, OP_CALL_FUNC, OP_CALL_IMPORT_CONST, OP_CALL_IMPORT_CONST2,
    OP_CALL_IMPORT_IMM, OP_CALL_IMPORT_VOID, OP_CONST_BOOL, OP_CONST_I64, OP_CONST_PTR,
    OP_CONST_U64, OP_EQ_I64, OP_EXPECT_BOOL, OP_EXPECT_I64, OP_EXPECT_PTR, OP_EXPECT_U64,
    OP_GE_I64, OP_GT_I64, OP_IS_NONNULL_PTR, OP_IS_NULL_PTR, OP_LE_I64, OP_LOAD_ARG_I64,
    OP_LOAD_U16, OP_LOAD_U32, OP_LOAD_U8, OP_LT_I64, OP_MUL_I64, OP_NE_I64, OP_NOT_BOOL,
    OP_NULL_PTR, OP_OR_BOOL, OP_PTR_TO_U64, OP_RESOLVE_IMPORT, OP_RET_LAST, OP_STORE_U16,
    OP_STORE_U32, OP_STORE_U8, OP_SUB_I64, OP_SUB_PTR, OP_U64_TO_PTR, SIG_I32_I32, SIG_I32_PTR,
    SIG_I32_PTR_PTR, SIG_I32_VOID, SIG_U64_PTR,
};

#[derive(Debug)]
pub enum CompileError {
    ParseFail,
    ReadFail { path: String },
    WriteFail { path: String },
    LowerFail { reason: &'static str },
    UnsupportedSource { reason: &'static str },
}

impl std::fmt::Display for CompileError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            CompileError::ParseFail => write!(f, "compile=parse_fail"),
            CompileError::ReadFail { path } => write!(f, "compile=read_fail path={path}"),
            CompileError::WriteFail { path } => write!(f, "compile=write_fail path={path}"),
            CompileError::LowerFail { reason } => write!(f, "compile=lower_fail reason={reason}"),
            CompileError::UnsupportedSource { reason } => {
                write!(f, "compile=unsupported_source reason={reason}")
            }
        }
    }
}

impl std::error::Error for CompileError {}

struct StringPool {
    data: Vec<u8>,
}

impl StringPool {
    fn new() -> Self {
        Self { data: Vec::new() }
    }

    fn add(&mut self, s: &str) -> u32 {
        let off = self.data.len() as u32;
        self.data.extend_from_slice(s.as_bytes());
        self.data.push(0);
        off
    }

    fn len(&self) -> u32 {
        self.data.len() as u32
    }
}

fn emit_instr(out: &mut Vec<u8>, op: u8, arg0: u32, arg1: u32) {
    out.push(op);
    out.extend_from_slice(&[0u8; 3]);
    out.extend_from_slice(&arg0.to_le_bytes());
    out.extend_from_slice(&arg1.to_le_bytes());
}

fn emit_imm64(out: &mut Vec<u8>, op: u8, imm: u64) {
    emit_instr(
        out,
        op,
        (imm & 0xffff_ffff) as u32,
        (imm >> 32) as u32,
    );
}

fn pack_const_pair(a: u32, b: u32) -> Result<u32, CompileError> {
    if a > 0xffff || b > 0xffff {
        return Err(CompileError::LowerFail {
            reason: "const_pair_too_large",
        });
    }
    Ok(a | (b << 16))
}

fn find_const(m: &Module, name: &str) -> Option<usize> {
    m.consts.iter().position(|c| c.name == name)
}

fn find_import(m: &Module, name: &str) -> Option<usize> {
    m.imports.iter().position(|i| i.name == name)
}

fn find_func(m: &Module, name: &str) -> Option<usize> {
    m.funcs.iter().position(|f| f.name == name)
}

fn label_pc(instrs: &[InstrDef], label: &str) -> Option<u32> {
    let mut emitted = 0u32;
    for ins in instrs {
        if ins.form == SrcForm::Label {
            if ins.name.as_deref() == Some(label) {
                return Some(emitted);
            }
        } else if ins.form != SrcForm::ParamI64 {
            emitted += 1;
        }
    }
    None
}

fn lower_instrs(
    m: &Module,
    body: &[InstrDef],
    out: &mut Vec<u8>,
) -> Result<(), CompileError> {
    for ins in body {
        match ins.form {
            SrcForm::Label | SrcForm::ParamI64 => {}
            SrcForm::LoadArgI64 => {
                emit_instr(out, OP_LOAD_ARG_I64, ins.imm as u32, 0);
            }
            SrcForm::ConstU64 | SrcForm::AddU64 | SrcForm::ConstI64 | SrcForm::AddI64
            | SrcForm::SubI64 | SrcForm::MulI64 | SrcForm::EqI64 | SrcForm::LtI64
            | SrcForm::GtI64 | SrcForm::NeI64 | SrcForm::LeI64 | SrcForm::GeI64 => {
                let op = match ins.form {
                    SrcForm::ConstU64 => OP_CONST_U64,
                    SrcForm::AddU64 => OP_ADD_U64,
                    SrcForm::ConstI64 => OP_CONST_I64,
                    SrcForm::AddI64 => OP_ADD_I64,
                    SrcForm::SubI64 => OP_SUB_I64,
                    SrcForm::MulI64 => OP_MUL_I64,
                    SrcForm::EqI64 => OP_EQ_I64,
                    SrcForm::LtI64 => OP_LT_I64,
                    SrcForm::GtI64 => OP_GT_I64,
                    SrcForm::NeI64 => OP_NE_I64,
                    SrcForm::LeI64 => OP_LE_I64,
                    _ => OP_GE_I64,
                };
                emit_imm64(out, op, ins.imm);
            }
            SrcForm::ExpectU64 => emit_imm64(out, OP_EXPECT_U64, ins.imm),
            SrcForm::ExpectI64 => emit_imm64(out, OP_EXPECT_I64, ins.imm),
            SrcForm::ExpectBool => emit_instr(out, OP_EXPECT_BOOL, ins.imm as u32, 0),
            SrcForm::ExpectPtr => emit_instr(out, OP_EXPECT_PTR, ins.imm as u32, 0),
            SrcForm::ConstBool => emit_instr(out, OP_CONST_BOOL, ins.imm as u32, 0),
            SrcForm::NullPtr => emit_instr(out, OP_NULL_PTR, 0, 0),
            SrcForm::AddPtr | SrcForm::SubPtr => {
                let op = if ins.form == SrcForm::AddPtr {
                    OP_ADD_PTR
                } else {
                    OP_SUB_PTR
                };
                emit_imm64(out, op, ins.imm);
            }
            SrcForm::PtrToU64 => emit_instr(out, OP_PTR_TO_U64, 0, 0),
            SrcForm::U64ToPtr => emit_instr(out, OP_U64_TO_PTR, 0, 0),
            SrcForm::ConstPtr => {
                let const_name = ins.const_name.as_deref().ok_or(CompileError::LowerFail {
                    reason: "missing_const",
                })?;
                let idx = find_const(m, const_name).ok_or(CompileError::LowerFail {
                    reason: "unknown_const",
                })? as u32;
                emit_instr(out, OP_CONST_PTR, idx, 0);
            }
            SrcForm::LoadU8 => emit_instr(out, OP_LOAD_U8, 0, 0),
            SrcForm::LoadU16 => emit_instr(out, OP_LOAD_U16, 0, 0),
            SrcForm::LoadU32 => emit_instr(out, OP_LOAD_U32, 0, 0),
            SrcForm::StoreU8 => emit_imm64(out, OP_STORE_U8, ins.imm),
            SrcForm::StoreU16 => emit_imm64(out, OP_STORE_U16, ins.imm),
            SrcForm::StoreU32 => emit_imm64(out, OP_STORE_U32, ins.imm),
            SrcForm::IsNullPtr => emit_instr(out, OP_IS_NULL_PTR, 0, 0),
            SrcForm::IsNonnullPtr => emit_instr(out, OP_IS_NONNULL_PTR, 0, 0),
            SrcForm::NotBool => emit_instr(out, OP_NOT_BOOL, 0, 0),
            SrcForm::AndBool => emit_instr(out, OP_AND_BOOL, ins.imm as u32, 0),
            SrcForm::OrBool => emit_instr(out, OP_OR_BOOL, ins.imm as u32, 0),
            SrcForm::Branch => {
                let label = ins.name.as_deref().ok_or(CompileError::LowerFail {
                    reason: "missing_label",
                })?;
                let pc = label_pc(body, label).ok_or(CompileError::LowerFail {
                    reason: "unknown_label",
                })?;
                emit_instr(out, OP_BRANCH_BOOL, pc, 0);
            }
            SrcForm::CallFunc => {
                let func_name = ins.name.as_deref().ok_or(CompileError::LowerFail {
                    reason: "missing_func",
                })?;
                let idx = find_func(m, func_name).ok_or(CompileError::LowerFail {
                    reason: "unknown_func",
                })? as u32;
                emit_instr(out, OP_CALL_FUNC, idx, 0);
            }
            SrcForm::Resolve => {
                let import_name = ins.name.as_deref().ok_or(CompileError::LowerFail {
                    reason: "missing_import",
                })?;
                let idx = find_import(m, import_name).ok_or(CompileError::LowerFail {
                    reason: "unknown_import",
                })? as u32;
                emit_instr(out, OP_RESOLVE_IMPORT, idx, 0);
            }
            SrcForm::CallImport => {
                let import_name = ins.name.as_deref().ok_or(CompileError::LowerFail {
                    reason: "missing_import",
                })?;
                let import_idx = find_import(m, import_name).ok_or(CompileError::LowerFail {
                    reason: "unknown_import",
                })?;
                let sig = m.imports[import_idx].sig;
                let import_idx = import_idx as u32;
                if sig == SIG_I32_VOID {
                    if ins.const_name.is_some() || ins.const2_name.is_some() {
                        return Err(CompileError::LowerFail {
                            reason: "void_call_extra_args",
                        });
                    }
                    emit_instr(out, OP_CALL_IMPORT_VOID, import_idx, 0);
                } else if sig == SIG_I32_I32 {
                    let atom = ins.const_name.as_deref().ok_or(CompileError::LowerFail {
                        reason: "missing_imm",
                    })?;
                    if ins.const2_name.is_some() {
                        return Err(CompileError::LowerFail {
                            reason: "imm_call_extra_args",
                        });
                    }
                    let imm: i32 = atom
                        .parse()
                        .map_err(|_| CompileError::LowerFail { reason: "bad_i32_imm" })?;
                    emit_instr(out, OP_CALL_IMPORT_IMM, import_idx, imm as u32);
                } else if sig == SIG_U64_PTR || sig == SIG_I32_PTR {
                    let const_name = ins.const_name.as_deref().ok_or(CompileError::LowerFail {
                        reason: "missing_const",
                    })?;
                    if ins.const2_name.is_some() {
                        return Err(CompileError::LowerFail {
                            reason: "single_const_expected",
                        });
                    }
                    let const_idx = find_const(m, const_name).ok_or(CompileError::LowerFail {
                        reason: "unknown_const",
                    })? as u32;
                    emit_instr(out, OP_CALL_IMPORT_CONST, import_idx, const_idx);
                } else if sig == SIG_I32_PTR_PTR {
                    let c0 = ins.const_name.as_deref().ok_or(CompileError::LowerFail {
                        reason: "missing_const",
                    })?;
                    let c1 = ins.const2_name.as_deref().ok_or(CompileError::LowerFail {
                        reason: "missing_const2",
                    })?;
                    let i0 = find_const(m, c0).ok_or(CompileError::LowerFail {
                        reason: "unknown_const",
                    })? as u32;
                    let i1 = find_const(m, c1).ok_or(CompileError::LowerFail {
                        reason: "unknown_const2",
                    })? as u32;
                    let packed = pack_const_pair(i0, i1)?;
                    emit_instr(out, OP_CALL_IMPORT_CONST2, import_idx, packed);
                } else {
                    return Err(CompileError::LowerFail {
                        reason: "unsupported_sig",
                    });
                }
            }
        }
    }
    Ok(())
}

fn emitted_count(instrs: &[InstrDef]) -> u32 {
    instrs
        .iter()
        .filter(|i| i.form != SrcForm::Label && i.form != SrcForm::ParamI64)
        .count() as u32
}

fn compile_body(m: &Module, body: &[InstrDef], out: &mut Vec<u8>) -> Result<u32, CompileError> {
    lower_instrs(m, body, out)?;
    Ok(emitted_count(body))
}

pub fn compile_module(m: &Module) -> Result<Vec<u8>, CompileError> {
    let mut strings = StringPool::new();
    let mut imports = Vec::new();
    let mut consts = Vec::new();
    let mut instrs = Vec::new();
    let mut func_entries = Vec::new();

    for imp in &m.imports {
        imports.extend_from_slice(&strings.add(&imp.lib).to_le_bytes());
        imports.extend_from_slice(&strings.add(&imp.symbol).to_le_bytes());
        imports.extend_from_slice(&imp.sig.to_le_bytes());
        imports.extend_from_slice(&0u32.to_le_bytes());
    }

    for c in &m.consts {
        consts.extend_from_slice(&CONST_STRING.to_le_bytes());
        consts.extend_from_slice(&strings.add(&c.value).to_le_bytes());
        consts.extend_from_slice(&(c.value.len() as u32).to_le_bytes());
        consts.extend_from_slice(&0u32.to_le_bytes());
    }

    let main_emitted = compile_body(m, &m.instrs, &mut instrs)?;
    emit_instr(&mut instrs, OP_RET_LAST, 0, 0);
    let mut total_emitted = main_emitted + 1;

    for func in &m.funcs {
        let start_pc = total_emitted;
        let func_emitted = compile_body(m, &func.instrs, &mut instrs)?;
        func_entries.extend_from_slice(&start_pc.to_le_bytes());
        func_entries.extend_from_slice(&func_emitted.to_le_bytes());
        func_entries.extend_from_slice(&0u32.to_le_bytes());
        total_emitted += func_emitted;
    }

    let instr_count = total_emitted;
    let mut out = Vec::with_capacity(
        HEADER_SIZE
            + imports.len()
            + consts.len()
            + instrs.len()
            + strings.data.len()
            + func_entries.len(),
    );
    out.extend_from_slice(&MAGIC_LBIN);
    out.extend_from_slice(&1u32.to_le_bytes());
    out.extend_from_slice(&(m.funcs.len() as u32).to_le_bytes());
    out.extend_from_slice(&(m.imports.len() as u32).to_le_bytes());
    out.extend_from_slice(&(m.consts.len() as u32).to_le_bytes());
    out.extend_from_slice(&instr_count.to_le_bytes());
    out.extend_from_slice(&strings.len().to_le_bytes());
    out.extend_from_slice(&imports);
    out.extend_from_slice(&consts);
    out.extend_from_slice(&instrs);
    out.extend_from_slice(&strings.data);
    out.extend_from_slice(&func_entries);
    Ok(out)
}
