mod multi;
mod pure_eval;
mod x86;

use crate::compile::parse_module;
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

fn print_link_stats(result: &crate::elf64::LinkResult) {
    println!("link.code.bytes={}", result.code_bytes);
    if result.rodata_bytes > 0 {
        println!("link.rodata.bytes={}", result.rodata_bytes);
    }
    if result.data_bytes > 0 {
        println!("link.data.bytes={}", result.data_bytes);
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
    match x86::compile_pure_to_elf_via_link(&blob, out_path, "nano_main") {
        Ok(link) => {
            println!("link.output={}", out_path.display());
            println!("link.objects=1");
            print_link_stats(&link);
            println!("aot.code.output={}", out_path.display());
            println!("aot.code.symbol=nano_main");
            0
        }
        Err(e) => e,
    }
}

pub fn cmd_aot_elf64_obj_code(blob_path: &Path, out_path: &Path, symbol: &str) -> i32 {
    if symbol.is_empty() {
        eprintln!("aot-elf64-obj-code=bad_symbol");
        return 1;
    }
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
    match x86::compile_pure_to_elf64_obj(&blob, out_path, symbol) {
        Ok(code) => {
            println!("aot.obj.code.output={}", out_path.display());
            println!("aot.obj.code.symbol={symbol}");
            println!("aot.obj.code.bytes={}", code.len());
            0
        }
        Err(2) => {
            eprintln!("aot-elf64-obj-code=unsupported_blob");
            2
        }
        Err(3) => {
            eprintln!("aot-elf64-obj-code=write_fail path={}", out_path.display());
            3
        }
        Err(e) => e,
    }
}

pub fn cmd_compile_elf64_obj_code(lisp_path: &Path, out_path: &Path, symbol: &str) -> i32 {
    if symbol.is_empty() {
        eprintln!("compile-elf64-obj-code=bad_symbol");
        return 1;
    }
    let src = match std::fs::read_to_string(lisp_path) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("compile-elf64-obj-code=compile_fail");
            return 1;
        }
    };
    let module = match parse_module(&src) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("{e}");
            eprintln!("compile-elf64-obj-code=compile_fail");
            return 1;
        }
    };
    if module.funcs.is_empty() {
        match crate::compile::compile_to_blob(lisp_path) {
            Ok(data) => {
                let blob = match parse_blob(&data) {
                    Ok(b) => b,
                    Err(_) => {
                        eprintln!("compile-elf64-obj-code=compile_fail");
                        return 1;
                    }
                };
                match x86::compile_pure_to_elf64_obj(&blob, out_path, symbol) {
                    Ok(code) => {
                        println!("compile.obj.code.output={}", out_path.display());
                        println!("compile.obj.code.symbol={symbol}");
                        println!("compile.obj.code.mode=pure-blob");
                        println!("compile.obj.code.bytes={}", code.len());
                        0
                    }
                    Err(2) => {
                        eprintln!("compile-elf64-obj-code=unsupported_source");
                        2
                    }
                    Err(3) => {
                        eprintln!("compile-elf64-obj-code=write_fail path={}", out_path.display());
                        3
                    }
                    Err(e) => e,
                }
            }
            Err(e) => {
                eprintln!("{e}");
                eprintln!("compile-elf64-obj-code=compile_fail");
                1
            }
        }
    } else {
        match multi::compile_module_to_elf64_obj(&module, out_path, symbol) {
            Ok(code_bytes) => {
                println!("compile.obj.code.output={}", out_path.display());
                println!("compile.obj.code.symbol={symbol}");
                println!("compile.obj.code.mode=multi-func");
                println!("compile.obj.code.bytes={code_bytes}");
                0
            }
            Err(crate::compile::CompileError::LowerFail { .. }) => {
                eprintln!("compile-elf64-obj-code=unsupported_source");
                2
            }
            Err(e) => {
                eprintln!("{e}");
                eprintln!("compile-elf64-obj-code=compile_fail");
                1
            }
        }
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
            match x86::compile_pure_to_elf_via_link(&blob, out_path, "nano_main") {
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

pub fn cmd_compile_elf64_exe(lisp_path: &Path, out_path: &Path, entry_symbol: &str) -> i32 {
    let src = match std::fs::read_to_string(lisp_path) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("compile-elf64-exe=compile_fail");
            return 1;
        }
    };
    let module = match parse_module(&src) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("{e}");
            eprintln!("compile-elf64-exe=compile_fail");
            return 1;
        }
    };
    if module.funcs.is_empty() {
        match crate::compile::compile_to_blob(lisp_path) {
            Ok(data) => {
                let blob = match parse_blob(&data) {
                    Ok(b) => b,
                    Err(_) => {
                        eprintln!("compile-elf64-exe=compile_fail");
                        return 1;
                    }
                };
                let sym = if entry_symbol.is_empty() {
                    "nano_main"
                } else {
                    entry_symbol
                };
                match x86::compile_pure_to_elf_via_link(&blob, out_path, sym) {
                    Ok(_) => {
                        println!("compile.elf64.exe.output={}", out_path.display());
                        println!("compile.elf64.exe.symbol={sym}");
                        println!("compile.elf64.exe.mode=multi-func");
                        0
                    }
                    Err(2) => {
                        eprintln!("compile-elf64-exe=unsupported_source");
                        2
                    }
                    Err(e) => e,
                }
            }
            Err(e) => {
                eprintln!("{e}");
                eprintln!("compile-elf64-exe=compile_fail");
                1
            }
        }
    } else {
        match multi::compile_module_to_elf64_exe(&module, out_path, entry_symbol) {
            Ok(code_bytes) => {
                println!("link.code.bytes={code_bytes}");
                println!("compile.elf64.exe.output={}", out_path.display());
                println!("compile.elf64.exe.symbol={entry_symbol}");
                println!("compile.elf64.exe.mode=multi-func");
                0
            }
            Err(crate::compile::CompileError::LowerFail { .. }) => {
                eprintln!("compile-elf64-exe=unsupported_source");
                2
            }
            Err(e) => {
                eprintln!("{e}");
                eprintln!("compile-elf64-exe=compile_fail");
                1
            }
        }
    }
}

pub fn cmd_link_elf64_exe(out_path: &Path, entry: &str, obj_paths: &[&Path]) -> i32 {
    if entry.is_empty() || obj_paths.is_empty() {
        eprintln!("link-elf64-exe=bad_args");
        return 1;
    }
    match crate::elf64::link_exe(out_path, entry, obj_paths) {
        Ok(link) => {
            println!("link.output={}", out_path.display());
            println!("link.objects={}", obj_paths.len());
            print_link_stats(&link);
            0
        }
        Err(e) => {
            eprintln!("{e}");
            let msg = e.to_string();
            if msg.contains("entry_missing") {
                3
            } else if msg.contains("parse_fail") {
                2
            } else {
                4
            }
        }
    }
}
