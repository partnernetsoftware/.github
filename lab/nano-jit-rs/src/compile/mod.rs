mod emit;
pub mod parse;
mod validate;

pub use emit::CompileError;
pub use parse::{parse_module, InstrDef, Module, SrcForm};
use std::path::Path;

pub fn compile_source(src: &str) -> Result<Vec<u8>, CompileError> {
    let module = parse::parse_module(src)?;
    validate::validate_vm_module(&module)?;
    emit::compile_module(&module)
}

pub fn compile_path(lisp: &Path, lbin: &Path) -> Result<(), CompileError> {
    let blob = compile_to_blob(lisp)?;
    std::fs::write(lbin, &blob).map_err(|_| CompileError::WriteFail {
        path: lbin.display().to_string(),
    })?;
    Ok(())
}

pub fn compile_to_blob(lisp: &Path) -> Result<Vec<u8>, CompileError> {
    let src = std::fs::read_to_string(lisp).map_err(|_| CompileError::ReadFail {
        path: lisp.display().to_string(),
    })?;
    compile_source(&src)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lbin::fnv1a64;

    fn assert_hash(lisp_path: &str, expected_hash: u64, expected_len: usize) {
        let src = std::fs::read_to_string(lisp_path).expect("read lisp");
        let blob = compile_source(&src).expect("compile");
        assert_eq!(blob.len(), expected_len, "{lisp_path} len");
        assert_eq!(fnv1a64(&blob), expected_hash, "{lisp_path} hash");
    }

    #[test]
    fn bootstrap_smoke_hashes_match_c_com() {
        let root = concat!(env!("CARGO_MANIFEST_DIR"), "/../nano-lisp-jit/lisp/core/");
        let cases: &[(&str, u64, usize)] = &[
            ("arithmetic.lisp", 0x75f41532f506a13f, 80),
            ("arithmetic-i64.lisp", 0x138a59218f2fe963, 368),
            ("control-flow.lisp", 0x90bca2e8bbbd6968, 764),
            ("strlen.lisp", 0x4f3170c08f7fcd9c, 116),
            ("typed-values.lisp", 0xc464394db1145451, 752),
            ("ptr-values.lisp", 0x40bba0b9cb5248ff, 368),
            ("const-ptr-load-u8.lisp", 0xba265e2700d093f5, 425),
            ("libc-smoke.lisp", 0xb6fa78a006774f64, 406),
        ];
        for (file, hash, len) in cases {
            let path = format!("{root}{file}");
            assert_hash(&path, *hash, *len);
        }
    }
}
