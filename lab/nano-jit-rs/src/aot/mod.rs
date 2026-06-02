mod pure_eval;
mod x86;

use crate::lbin::parse_blob;
use std::path::Path;

pub fn cmd_emit_elf64_exit(out_path: &Path, exit_s: &str) -> i32 {
    let code: u64 = match exit_s.parse() {
        Ok(v) if v <= 255 => v,
        _ => {
            eprintln!("emit-elf64-exit=bad_exit_code");
            return 1;
        }
    };
    match crate::elf64::emit_exit(out_path, code as u8) {
        Ok((logical, entry)) => {
            println!("elf64.output={}", out_path.display());
            println!("elf64.bytes={logical}");
            println!("elf64.entry=0x{entry:x}");
            println!("elf64.exit={code}");
            0
        }
        Err(_) => {
            eprintln!("emit-elf64-exit=write_fail path={}", out_path.display());
            2
        }
    }
}

pub fn cmd_aot_elf64_exit(blob_path: &Path, out_path: &Path) -> i32 {
    let data = match std::fs::read(blob_path) {
        Ok(d) => d,
        Err(_) => {
            eprintln!("blob=parse_fail path={}", blob_path.display());
            return 1;
        }
    };
    let blob = match parse_blob(&data) {
        Ok(b) => b,
        Err(_) => {
            eprintln!("blob=parse_fail path={}", blob_path.display());
            return 1;
        }
    };
    match x86::compile_pure_to_elf_exit_direct(&blob, out_path) {
        Ok(exit) => {
            println!("aot.elf64.output={}", out_path.display());
            println!("aot.elf64.bytes=132");
            println!("aot.elf64.exit={exit}");
            0
        }
        Err(e) => e,
    }
}

pub fn cmd_aot_elf64_code(blob_path: &Path, out_path: &Path) -> i32 {
    let data = match std::fs::read(blob_path) {
        Ok(d) => d,
        Err(_) => {
            eprintln!("blob=parse_fail path={}", blob_path.display());
            return 1;
        }
    };
    let blob = match parse_blob(&data) {
        Ok(b) => b,
        Err(_) => {
            eprintln!("blob=parse_fail path={}", blob_path.display());
            return 1;
        }
    };
    match x86::compile_pure_to_elf_exit(&blob, out_path) {
        Ok(code_bytes) => {
            println!("link.output={}", out_path.display());
            println!("link.objects=1");
            println!("link.code.bytes={code_bytes}");
            println!("aot.code.output={}", out_path.display());
            println!("aot.code.symbol=nano_main");
            0
        }
        Err(e) => e,
    }
}

pub fn cmd_compile_elf64_code(lisp_path: &Path, out_path: &Path) -> i32 {
    match crate::compile::compile_to_blob(lisp_path) {
        Ok(data) => {
            let blob = match parse_blob(&data) {
                Ok(b) => b,
                Err(_) => {
                    eprintln!("compile-elf64-code=compile_fail");
                    return 1;
                }
            };
            match x86::compile_pure_to_elf_exit(&blob, out_path) {
                Ok(_) => {
                    println!("compile.elf64.output={}", out_path.display());
                    println!("compile.elf64.symbol=nano_main");
                    0
                }
                Err(2) => {
                    eprintln!("compile-elf64-code=unsupported_source");
                    2
                }
                Err(e) => e,
            }
        }
        Err(e) => {
            eprintln!("{e}");
            eprintln!("compile-elf64-code=compile_fail");
            1
        }
    }
}
