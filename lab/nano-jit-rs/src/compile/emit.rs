use super::parse::{InstrDef, Module, SrcForm};
use crate::lbin::{
    CONST_STRING, HEADER_SIZE, INSTR_SIZE, MAGIC_LBIN, OP_ADD_U64, OP_CALL_IMPORT_CONST,
    OP_CONST_U64, OP_EXPECT_U64, OP_RET_LAST, SIG_I32_I32, SIG_I32_PTR, SIG_I32_PTR_PTR,
    SIG_I32_VOID, SIG_U64_PTR,
};

#[derive(Debug)]
pub enum CompileError {
    ParseFail,
    ReadFail { path: String },
    WriteFail { path: String },
    LowerFail { reason: &'static str },
}

impl std::fmt::Display for CompileError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            CompileError::ParseFail => write!(f, "compile=parse_fail"),
            CompileError::ReadFail { path } => write!(f, "compile=read_fail path={path}"),
            CompileError::WriteFail { path } => write!(f, "compile=write_fail path={path}"),
            CompileError::LowerFail { reason } => write!(f, "compile=lower_fail reason={reason}"),
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

fn find_const(m: &Module, name: &str) -> Option<usize> {
    m.consts.iter().position(|c| c.name == name)
}

fn find_import(m: &Module, name: &str) -> Option<usize> {
    m.imports.iter().position(|i| i.name == name)
}

fn lower_instrs(m: &Module, instrs: &[InstrDef], out: &mut Vec<u8>) -> Result<(), CompileError> {
    for ins in instrs {
        match ins.form {
            SrcForm::ConstU64 => {
                emit_instr(
                    out,
                    OP_CONST_U64,
                    (ins.imm & 0xffff_ffff) as u32,
                    (ins.imm >> 32) as u32,
                );
            }
            SrcForm::AddU64 => {
                emit_instr(
                    out,
                    OP_ADD_U64,
                    (ins.imm & 0xffff_ffff) as u32,
                    (ins.imm >> 32) as u32,
                );
            }
            SrcForm::Expect => {
                emit_instr(
                    out,
                    OP_EXPECT_U64,
                    (ins.imm & 0xffff_ffff) as u32,
                    (ins.imm >> 32) as u32,
                );
            }
            SrcForm::CallImport => {
                let import_name = ins.target.as_deref().ok_or(CompileError::LowerFail {
                    reason: "missing_import",
                })?;
                let import_idx = find_import(m, import_name).ok_or(CompileError::LowerFail {
                    reason: "unknown_import",
                })?;
                let sig = m.imports[import_idx].sig;
                if sig == SIG_U64_PTR || sig == SIG_I32_PTR {
                    let const_name = ins.const_name.as_deref().ok_or(CompileError::LowerFail {
                        reason: "missing_const",
                    })?;
                    let const_idx = find_const(m, const_name).ok_or(CompileError::LowerFail {
                        reason: "unknown_const",
                    })? as u32;
                    emit_instr(out, OP_CALL_IMPORT_CONST, import_idx as u32, const_idx);
                } else if sig == SIG_I32_VOID {
                    emit_instr(out, crate::lbin::OP_CALL_IMPORT_VOID, import_idx as u32, 0);
                } else if sig == SIG_I32_I32 {
                    return Err(CompileError::LowerFail {
                        reason: "i32_imm_not_in_mvp",
                    });
                } else if sig == SIG_I32_PTR_PTR {
                    return Err(CompileError::LowerFail {
                        reason: "const2_not_in_mvp",
                    });
                } else {
                    return Err(CompileError::LowerFail {
                        reason: "unsupported_sig",
                    });
                }
            }
            SrcForm::CallFunc => {
                return Err(CompileError::LowerFail {
                    reason: "call_func_not_in_mvp",
                });
            }
        }
    }
    Ok(())
}

pub fn compile_module(m: &Module) -> Result<Vec<u8>, CompileError> {
    let mut strings = StringPool::new();
    let mut imports = Vec::new();
    let mut consts = Vec::new();
    let mut instrs = Vec::new();

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

    lower_instrs(m, &m.instrs, &mut instrs)?;
    emit_instr(&mut instrs, OP_RET_LAST, 0, 0);

    let instr_count = (instrs.len() / INSTR_SIZE) as u32;
    let mut out = Vec::with_capacity(
        HEADER_SIZE
            + imports.len()
            + consts.len()
            + instrs.len()
            + strings.data.len(),
    );
    out.extend_from_slice(&MAGIC_LBIN);
    out.extend_from_slice(&1u32.to_le_bytes());
    out.extend_from_slice(&0u32.to_le_bytes()); // func_count
    out.extend_from_slice(&(m.imports.len() as u32).to_le_bytes());
    out.extend_from_slice(&(m.consts.len() as u32).to_le_bytes());
    out.extend_from_slice(&instr_count.to_le_bytes());
    out.extend_from_slice(&strings.len().to_le_bytes());
    out.extend_from_slice(&imports);
    out.extend_from_slice(&consts);
    out.extend_from_slice(&instrs);
    out.extend_from_slice(&strings.data);
    Ok(out)
}
