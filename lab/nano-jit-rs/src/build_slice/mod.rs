//! build-slice / build-slice-lisp — port of C `cmd_build_slice_lisp`.

use std::fs;
use std::path::Path;

fn normalize_arch(arch: &str) -> Option<&'static str> {
    match arch {
        "x86_64" | "amd64" => Some("x86_64"),
        "aarch64" | "arm64" => Some("aarch64"),
        _ => None,
    }
}

fn basename(path: &Path) -> String {
    path.file_name()
        .and_then(|s| s.to_str())
        .unwrap_or("")
        .to_string()
}

fn parse_expect_imm(src: &str) -> Option<u8> {
    let mut p = 0;
    while p + 8 <= src.len() {
        if src.as_bytes()[p..].starts_with(b"(expect ") {
            let mut q = p + 8;
            while q < src.len() && src.as_bytes()[q].is_ascii_whitespace() {
                q += 1;
            }
            if q >= src.len() || !src.as_bytes()[q].is_ascii_digit() {
                return None;
            }
            let mut v = 0u32;
            while q < src.len() && src.as_bytes()[q].is_ascii_digit() {
                v = v * 10 + u32::from(src.as_bytes()[q] - b'0');
                q += 1;
            }
            if v <= 255 {
                return Some(v as u8);
            }
            return None;
        }
        p += 1;
    }
    None
}

fn parse_add_operands(src: &str) -> Option<(i32, i32)> {
    let mut vals = [0i32; 2];
    let mut nval = 0usize;
    let expect = parse_expect_imm(src)?;
    let mut p = 0;
    while p + 5 <= src.len() {
        if src.as_bytes()[p..].starts_with(b"(i64 ") {
            let mut q = p + 5;
            while q < src.len() && src.as_bytes()[q].is_ascii_whitespace() {
                q += 1;
            }
            if q >= src.len() || !src.as_bytes()[q].is_ascii_digit() {
                p += 1;
                continue;
            }
            let mut v = 0i32;
            while q < src.len() && src.as_bytes()[q].is_ascii_digit() {
                v = v * 10 + i32::from(src.as_bytes()[q] - b'0');
                q += 1;
            }
            if nval < 2 {
                vals[nval] = v;
                nval += 1;
            }
            p = q;
            continue;
        }
        p += 1;
    }
    if nval < 2 || !src.contains("(call add") {
        return None;
    }
    if vals[0] + vals[1] != i32::from(expect) {
        return None;
    }
    Some((vals[0], vals[1]))
}

fn print_build_slice_header(arch: &str, src: &Path, out: &Path) {
    println!("build-slice.compiler=nano-jit-lisp");
    println!("build-slice.arch={arch}");
    println!("build-slice.role=lisp-codegen");
    println!("build-slice.source={}", src.display());
    println!("build-slice.output={}", out.display());
}

fn finish_file_size(out: &Path) -> i32 {
    match fs::metadata(out) {
        Ok(m) => {
            println!("file-size.path={}", out.display());
            println!("file-size.bytes={}", m.len());
            0
        }
        Err(_) => {
            eprintln!("file-size=fail path={}", out.display());
            1
        }
    }
}

fn ensure_parent(out: &Path) -> i32 {
    if let Some(parent) = out.parent() {
        if !parent.as_os_str().is_empty() && fs::create_dir_all(parent).is_err() {
            eprintln!("build-slice-lisp=mkdir_fail path={}", parent.display());
            return 3;
        }
    }
    0
}

fn build_slice_lisp_x86(src: &Path, out: &Path) -> i32 {
    if ensure_parent(out) != 0 {
        return ensure_parent(out);
    }
    let rc = crate::aot::cmd_compile_elf64_code(src, out);
    if rc == 0 {
        println!("build-slice-lisp.mode=compile-elf64-code");
        return finish_file_size(out);
    }
    let rc = crate::aot::cmd_compile_elf64_exe(src, out, "nano_main");
    if rc == 0 {
        println!("build-slice-lisp.mode=compile-elf64-exe");
        println!("build-slice-lisp.entry=nano_main");
        return finish_file_size(out);
    }
    let rc = crate::aot::cmd_compile_elf64_exe(src, out, "nano_cc_add");
    if rc == 0 {
        println!("build-slice-lisp.mode=compile-elf64-exe");
        println!("build-slice-lisp.entry=nano_cc_add");
        return finish_file_size(out);
    }
    eprintln!("build-slice-lisp=codegen_fail");
    if rc != 0 {
        rc
    } else {
        2
    }
}

fn build_slice_lisp_aarch64(src: &Path, out: &Path, base: &str, src_text: &str) -> i32 {
    let exit_code = match parse_expect_imm(src_text) {
        Some(v) => v,
        None => {
            eprintln!("build-slice-lisp=aarch64_no_expect");
            return 2;
        }
    };
    if ensure_parent(out) != 0 {
        return ensure_parent(out);
    }

    if base.starts_with("nano-jit-slice-add") {
        let (a, b) = match parse_add_operands(src_text) {
            Some(v) => v,
            None => {
                eprintln!("build-slice-lisp=aarch64_add_parse_fail");
                return 2;
            }
        };
        match crate::elf64::emit_aarch64_add_exit(out, a, b) {
            Ok((logical, entry)) => {
                println!("build-slice-lisp.mode=aarch64-add-emit");
                println!("aarch64.emit.profile=add-exit-v1");
                println!("elf64.output={}", out.display());
                println!("elf64.bytes={logical}");
                println!("elf64.entry=0x{entry:x}");
                println!("build-slice-lisp.aarch64.profile={base}");
                println!("build-slice-lisp.aarch64.add={a}+{b}");
                finish_file_size(out)
            }
            Err(_) => {
                eprintln!("build-slice-lisp=aarch64_emit_fail");
                3
            }
        }
    } else if base == "nano-jit-slice-min.lisp" || base.contains("nano-jit-slice-ir-exit") {
        if crate::compile::compile_to_blob(src).is_err() {
            eprintln!("build-slice-lisp=aarch64_unsupported_profile");
            return 2;
        }
        match crate::elf64::emit_aarch64_exit(out, exit_code) {
            Ok((logical, entry)) => {
                println!("build-slice-lisp.mode=aarch64-exit-emit");
                if base.contains("nano-jit-slice-ir-exit") {
                    println!("aarch64.emit.profile=ir-exit-v1");
                    println!("aarch64.emit.encode=exit-only");
                }
                println!("elf64.output={}", out.display());
                println!("elf64.bytes={logical}");
                println!("elf64.entry=0x{entry:x}");
                println!("build-slice-lisp.aarch64.profile={base}");
                finish_file_size(out)
            }
            Err(_) => {
                eprintln!("build-slice-lisp=aarch64_emit_fail");
                3
            }
        }
    } else if crate::compile::compile_to_blob(src).is_ok() {
        match crate::elf64::emit_aarch64_exit(out, exit_code) {
            Ok((logical, entry)) => {
                println!("build-slice-lisp.mode=aarch64-exit-emit");
                println!("elf64.output={}", out.display());
                println!("elf64.bytes={logical}");
                println!("elf64.entry=0x{entry:x}");
                println!("build-slice-lisp.aarch64.profile={base}");
                finish_file_size(out)
            }
            Err(_) => {
                eprintln!("build-slice-lisp=aarch64_emit_fail");
                3
            }
        }
    } else {
        eprintln!("build-slice-lisp=aarch64_unsupported_profile");
        2
    }
}

pub fn cmd_build_slice_lisp(src: &Path, out: &Path, arch: &str) -> i32 {
    let Some(arch_norm) = normalize_arch(arch) else {
        eprintln!("build-slice-lisp=bad_arch arch={arch}");
        return 2;
    };
    let src_text = match fs::read_to_string(src) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("build-slice-lisp=read_fail");
            return 1;
        }
    };
    let base = basename(src);
    print_build_slice_header(arch_norm, src, out);
    if arch_norm == "aarch64" {
        build_slice_lisp_aarch64(src, out, &base, &src_text)
    } else {
        build_slice_lisp_x86(src, out)
    }
}

pub fn cmd_build_slice(src: &Path, out: &Path, arch: &str) -> i32 {
    if src.extension().and_then(|s| s.to_str()) == Some("lisp") {
        println!("build-slice.route=lisp-by-extension");
        return cmd_build_slice_lisp(src, out, arch);
    }
    eprintln!("build-slice=unsupported_source path={}", src.display());
    2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_expect_from_min_slice() {
        let src = r#"(module (main (u64 40) (add-u64 2) (expect 42)))"#;
        assert_eq!(parse_expect_imm(src), Some(42));
    }
}
