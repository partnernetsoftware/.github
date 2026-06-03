//! VM type inference — port of C `infer_vm_module` in `nano_lisp_parse.c`.

use super::parse::{InstrDef, Module, SrcForm};
use super::CompileError;

#[derive(Clone, Copy, PartialEq, Eq)]
enum ValKind {
    None,
    I64,
    U64,
}

fn infer_vm_body(
    m: &Module,
    instrs: &[InstrDef],
    func_param_count: u32,
) -> Result<(), CompileError> {
    let mut last = ValKind::None;
    for ins in instrs {
        match ins.form {
            SrcForm::Label | SrcForm::ParamI64 => continue,
            SrcForm::LoadArgI64 => {
                if func_param_count == 0 || ins.imm >= u64::from(func_param_count) {
                    return Err(CompileError::UnsupportedSource {
                        reason: "load_arg_i64",
                    });
                }
                last = ValKind::I64;
            }
            SrcForm::ConstI64 | SrcForm::AddI64 | SrcForm::SubI64 | SrcForm::MulI64 => {
                last = ValKind::I64;
            }
            SrcForm::ConstU64 | SrcForm::AddU64 => last = ValKind::U64,
            SrcForm::CallFunc => {
                let name = ins.name.as_deref().ok_or(CompileError::UnsupportedSource {
                    reason: "call_target",
                })?;
                let target = m
                    .funcs
                    .iter()
                    .find(|f| f.name == name)
                    .ok_or(CompileError::UnsupportedSource {
                        reason: "call_target",
                    })?;
                if target.param_count > 0 && last != ValKind::I64 {
                    return Err(CompileError::UnsupportedSource {
                        reason: "call_arity",
                    });
                }
                last = ValKind::I64;
            }
            SrcForm::ExpectI64 => {
                if last != ValKind::I64 {
                    return Err(CompileError::UnsupportedSource {
                        reason: "expect_kind",
                    });
                }
            }
            _ => {}
        }
    }
    Ok(())
}

pub fn validate_vm_module(m: &Module) -> Result<(), CompileError> {
    infer_vm_body(m, &m.instrs, 0)?;
    for func in &m.funcs {
        infer_vm_body(m, &func.instrs, func.param_count)?;
    }
    Ok(())
}
