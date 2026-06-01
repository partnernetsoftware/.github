mod emit;
mod parse;

pub use emit::CompileError;
use std::path::Path;

pub fn compile_source(src: &str) -> Result<Vec<u8>, CompileError> {
    let module = parse::parse_module(src)?;
    emit::compile_module(&module)
}

pub fn compile_path(lisp: &Path, lbin: &Path) -> Result<(), CompileError> {
    let src = std::fs::read_to_string(lisp).map_err(|_| CompileError::ReadFail {
        path: lisp.display().to_string(),
    })?;
    let blob = compile_source(&src)?;
    std::fs::write(lbin, &blob).map_err(|_| CompileError::WriteFail {
        path: lbin.display().to_string(),
    })?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lbin::fnv1a64;

    #[test]
    fn arithmetic_hash_matches_c_com() {
        let src = include_str!("../../../nano-lisp-jit/lisp/core/arithmetic.lisp");
        let blob = compile_source(src).expect("compile arithmetic");
        assert_eq!(blob.len(), 80);
        assert_eq!(fnv1a64(&blob), 0x75f41532f506a13f);
    }

    #[test]
    fn strlen_hash_matches_c_com() {
        let src = include_str!("../../../nano-lisp-jit/lisp/core/strlen.lisp");
        let blob = compile_source(src).expect("compile strlen");
        assert_eq!(blob.len(), 116);
        assert_eq!(fnv1a64(&blob), 0x4f3170c08f7fcd9c);
    }
}
