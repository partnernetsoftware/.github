//! Minimal nano-cc — C-subset → ELF (port of `nano_cc.c`).

use std::env;
use std::fs;
use std::path::{Path, PathBuf};

const CANONICAL_ADD_LISP: &str = "lab/nano-lisp-jit/lisp/core/nano-jit-slice-add.lisp";

fn env_flag(name: &str) -> bool {
    env::var(name).ok().is_some_and(|v| v == "1")
}

pub fn target_is_aarch64() -> bool {
    env::var("NANO_CC_ARCH")
        .ok()
        .is_some_and(|a| a == "aarch64" || a == "arm64")
}

fn skip_ws(src: &[u8], mut p: usize) -> Option<usize> {
    while p < src.len() && matches!(src[p], b' ' | b'\t' | b'\n' | b'\r') {
        p += 1;
    }
    if p < src.len() { Some(p) } else { None }
}

fn match_token(src: &[u8], p: &mut usize, tok: &[u8]) -> bool {
    let Some(mut q) = skip_ws(src, *p) else {
        return false;
    };
    if q + tok.len() > src.len() || &src[q..q + tok.len()] != tok {
        return false;
    }
    q += tok.len();
    *p = q;
    true
}

fn parse_int_lit(src: &[u8], p: &mut usize) -> Option<i32> {
    let mut q = skip_ws(src, *p)?;
    if !src[q].is_ascii_digit() {
        return None;
    }
    let mut v = 0i32;
    while q < src.len() && src[q].is_ascii_digit() {
        v = v * 10 + i32::from(src[q] - b'0');
        q += 1;
    }
    if !(0..=255).contains(&v) {
        return None;
    }
    *p = q;
    Some(v)
}

pub fn parse_main_return(src: &str) -> Option<u8> {
    let src = src.as_bytes();
    let sig = b"int main";
    let mut p = 0;
    while p + sig.len() <= src.len() {
        if &src[p..p + sig.len()] == sig {
            let mut q = p + sig.len();
            while q + 6 <= src.len() {
                if &src[q..q + 6] == b"return" {
                    let mut r = q;
                    if let Some(code) = parse_return_imm(src, &mut r) {
                        return Some(code);
                    }
                }
                q += 1;
            }
        }
        p += 1;
    }
    None
}

fn parse_return_imm(src: &[u8], p: &mut usize) -> Option<u8> {
    let mut q = skip_ws(src, *p)?;
    if q + 6 > src.len() || &src[q..q + 6] != b"return" {
        return None;
    }
    q += 6;
    q = skip_ws(src, q)?;
    if src[q] == b'(' {
        q += 1;
    }
    q = skip_ws(src, q)?;
    if !src[q].is_ascii_digit() {
        return None;
    }
    let mut v = 0u32;
    while q < src.len() && src[q].is_ascii_digit() {
        v = v * 10 + u32::from(src[q] - b'0');
        q += 1;
    }
    if v > 255 {
        return None;
    }
    *p = q;
    Some(v as u8)
}

pub fn parse_add_module(src: &str) -> Option<(i32, i32)> {
    let src = src.as_bytes();
    let add_sig = b"int add(int a,int b)";
    let mut p = 0;
    let mut saw_add = false;
    while p + add_sig.len() <= src.len() {
        if &src[p..p + add_sig.len()] == add_sig {
            let mut q = p + add_sig.len();
            q = skip_ws(src, q)?;
            if src[q] != b'{' {
                return None;
            }
            q += 1;
            if !match_token(src, &mut q, b"return") || !match_token(src, &mut q, b"a+b") {
                return None;
            }
            q = skip_ws(src, q)?;
            if src[q] != b';' {
                return None;
            }
            saw_add = true;
            break;
        }
        p += 1;
    }
    if !saw_add {
        return None;
    }
    p = 0;
    while p + 8 <= src.len() {
        if &src[p..p + 8] == b"int main" {
            let mut q = p + 8;
            while q + 6 <= src.len() {
                if &src[q..q + 6] == b"return" {
                    q += 6;
                    if !match_token(src, &mut q, b"add(") {
                        continue;
                    }
                    let a = parse_int_lit(src, &mut q)?;
                    q = skip_ws(src, q)?;
                    if src.get(q) != Some(&b',') {
                        return None;
                    }
                    q += 1;
                    let b = parse_int_lit(src, &mut q)?;
                    q = skip_ws(src, q)?;
                    if src.get(q) != Some(&b')') {
                        return None;
                    }
                    return Some((a, b));
                }
                q += 1;
            }
        }
        p += 1;
    }
    None
}

fn is_nano_cc_sample_c(base: &str) -> bool {
    base.len() > 10 && base.starts_with("nano-cc-") && base.ends_with(".c")
}

fn resolve_add_lisp_path(src_path: &Path) -> Option<PathBuf> {
    let base = src_path.file_name()?.to_str()?;
    if base == "nano-cc-add.c" {
        return Some(PathBuf::from(CANONICAL_ADD_LISP));
    }
    if env_flag("NANO_CC_LEGACY_COMPANION") {
        let s = src_path.to_str()?;
        let dot = s.rfind('.')?;
        if s[dot..].eq(".c") {
            return Some(PathBuf::from(format!("{}.lisp", &s[..dot])));
        }
    }
    None
}

pub fn can_compile_path(src_path: &Path) -> bool {
    let src = match fs::read_to_string(src_path) {
        Ok(s) => s,
        Err(_) => return false,
    };
    if parse_main_return(&src).is_some() {
        return true;
    }
    if let Some(lisp) = resolve_add_lisp_path(src_path) {
        if parse_add_module(&src).is_some() && lisp.is_file() {
            return true;
        }
    }
    false
}

pub fn build_slice_use_nano_cc(src_path: &Path) -> bool {
    let base = src_path
        .file_name()
        .and_then(|s| s.to_str())
        .unwrap_or("");
    if base == "nano-cc-hello.c" || base == "nano-cc-add.c" {
        return true;
    }
    let codegen_on = env_flag("NANO_BUILD_SLICE_CODEGEN") || env_flag("NANO_V35_CODEGEN_DEFAULT");
    codegen_on && is_nano_cc_sample_c(base) && can_compile_path(src_path)
}

fn compile_via_companion_lisp(src_path: &Path, out_path: &Path) -> i32 {
    let src = match fs::read_to_string(src_path) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("nano-cc=read_fail path={}", src_path.display());
            return 1;
        }
    };
    let (a, b) = match parse_add_module(&src) {
        Some(v) => v,
        None => {
            eprintln!(
                "nano-cc=add_parse_fail reason=unsupported_stmt path={}",
                src_path.display()
            );
            return -1;
        }
    };
    let Some(lisp_path) = resolve_add_lisp_path(src_path) else {
        eprintln!("nano-cc=add_lisp_path_fail path={}", src_path.display());
        return 2;
    };
    if !lisp_path.is_file() {
        eprintln!("nano-cc=add_lisp_missing path={}", lisp_path.display());
        return 2;
    }
    let rc = crate::aot::cmd_compile_elf64_exe(&lisp_path, out_path, "nano_cc_add");
    if rc != 0 {
        return rc;
    }
    println!("nano-cc.source={}", src_path.display());
    println!("nano-cc.lisp.canonical={}", lisp_path.display());
    println!("nano-cc.output={}", out_path.display());
    println!("nano-cc.exit_code={}", a + b);
    0
}

pub fn cmd_nano_cc_compile(src_path: &Path, out_path: &Path) -> i32 {
    let src = match fs::read_to_string(src_path) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("nano-cc=read_fail path={}", src_path.display());
            return 1;
        }
    };
    if let Some(code) = parse_main_return(&src) {
        let ok = if target_is_aarch64() {
            crate::elf64::emit_aarch64_exit(out_path, code).is_ok()
        } else {
            crate::elf64::emit_exit(out_path, code).is_ok()
        };
        if !ok {
            eprintln!("nano-cc=emit_fail path={}", out_path.display());
            return 3;
        }
        println!("nano-cc.source={}", src_path.display());
        println!("nano-cc.output={}", out_path.display());
        println!(
            "nano-cc.arch={}",
            if target_is_aarch64() {
                "aarch64"
            } else {
                "x86_64"
            }
        );
        println!("nano-cc.exit_code={code}");
        return 0;
    }
    let rc = compile_via_companion_lisp(src_path, out_path);
    if rc == 0 {
        return 0;
    }
    if rc == -1 {
        eprintln!("nano-cc=unsupported_source path={}", src_path.display());
        return 2;
    }
    rc
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_hello_main_return() {
        assert_eq!(parse_main_return("int main(void) { return 42; }"), Some(42));
    }

    #[test]
    fn parse_add_module_smoke() {
        let src = "int add(int a,int b){return a+b;}\nint main(void){return add(40,2);}";
        assert_eq!(parse_add_module(src), Some((40, 2)));
    }
}
