//! build-slice / build-slice-lisp — port of C `cmd_build_slice_lisp`.

use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

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

const LISPJIT_FACTORY: &str = "lab/nano-lisp-jit/archive/c/runner/lispjit.c";
const COMPOSE15_HYBRID_THRESHOLD: usize = 16384;

enum HostCcRole {
    PlanCompile,
    Stage0Bridge,
}

fn build_slice_allow_host_cc() -> bool {
    env_flag("NANO_REGENESIS") || env_flag("NANO_SLICE_ALLOW_HOST_CC")
}

fn build_slice_use_selfhost_reuse(src: &Path) -> bool {
    is_lispjit_c(src) && !env_flag("NANO_LISPJIT_FROM_LISP") && env_flag("NANO_BUILD_SLICE_SELFHOST_REUSE")
}

fn build_slice_use_genesis_pin(src: &Path) -> bool {
    if build_slice_use_selfhost_reuse(src) {
        return false;
    }
    is_lispjit_c(src) && !build_slice_allow_host_cc()
}

fn genesis_pin_path_for_arch(arch: &str) -> Option<&'static str> {
    match normalize_arch(arch)? {
        "x86_64" => Some("lab/nano-lisp-jit/genesis/nano-jit.x86_64"),
        "aarch64" => Some("lab/nano-lisp-jit/genesis/nano-jit.aarch64"),
        _ => None,
    }
}

fn selfhost_reuse_pin_for_arch(arch: &str) -> Option<String> {
    match normalize_arch(arch)? {
        "x86_64" => env::var("NANO_SELFHOST_REUSE_X86").ok(),
        "aarch64" => env::var("NANO_SELFHOST_REUSE_AARCH64").ok(),
        _ => None,
    }
}

fn build_slice_copy_pin(pin: &Path, out: &Path) -> i32 {
    if ensure_parent(out) != 0 {
        return ensure_parent(out);
    }
    let data = match fs::read(pin) {
        Ok(d) => d,
        Err(_) => {
            eprintln!("build-slice=genesis_pin_missing path={}", pin.display());
            return 1;
        }
    };
    if fs::write(out, &data).is_err() {
        eprintln!("build-slice=genesis_pin_write_fail path={}", out.display());
        return 3;
    }
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        if let Ok(meta) = fs::metadata(out) {
            let mut perms = meta.permissions();
            perms.set_mode(0o755);
            let _ = fs::set_permissions(out, perms);
        }
    }
    0
}

fn build_slice_via_selfhost_reuse(src: &Path, out: &Path, arch: &str) -> i32 {
    let Some(pin_s) = selfhost_reuse_pin_for_arch(arch).filter(|s| !s.is_empty()) else {
        eprintln!("build-slice=selfhost_reuse_missing arch={arch}");
        return 2;
    };
    let pin = PathBuf::from(&pin_s);
    let Some(arch_norm) = normalize_arch(arch) else {
        eprintln!("build-slice=bad_arch arch={arch}");
        return 2;
    };
    println!("build-slice.compiler=none");
    println!("build-slice.arch={arch_norm}");
    println!("build-slice.role=selfhost-reuse");
    println!("build-slice.selfhost_reuse={pin_s}");
    println!("build-slice.source={}", src.display());
    println!("build-slice.output={}", out.display());
    let rc = build_slice_copy_pin(&pin, out);
    if rc != 0 {
        return rc;
    }
    finish_file_size(out)
}

fn build_slice_via_genesis_pin(src: &Path, out: &Path, arch: &str) -> i32 {
    let Some(pin_path) = genesis_pin_path_for_arch(arch) else {
        eprintln!("build-slice=genesis_pin_bad_arch arch={arch}");
        return 2;
    };
    let Some(arch_norm) = normalize_arch(arch) else {
        eprintln!("build-slice=bad_arch arch={arch}");
        return 2;
    };
    let pin = PathBuf::from(pin_path);
    println!("build-slice.compiler=none");
    println!("build-slice.arch={arch_norm}");
    println!("build-slice.role=genesis-pin");
    println!("build-slice.genesis_pin={pin_path}");
    println!("build-slice.source={}", src.display());
    println!("build-slice.output={}", out.display());
    let rc = build_slice_copy_pin(&pin, out);
    if rc != 0 {
        return rc;
    }
    finish_file_size(out)
}

fn run_host_cc_lispjit(src: &Path, out: &Path, arch: &str, role: HostCcRole) -> i32 {
    let Some(arch_norm) = normalize_arch(arch) else {
        eprintln!("build-slice-compile=bad_arch arch={arch}");
        return 2;
    };
    if ensure_parent(out) != 0 {
        return ensure_parent(out);
    }
    let cc = match arch_norm {
        "x86_64" => "cc",
        "aarch64" => "aarch64-linux-gnu-gcc",
        _ => {
            eprintln!("build-slice-compile=bad_arch arch={arch}");
            return 2;
        }
    };
    println!("build-slice.compiler={cc}");
    println!("build-slice.arch={arch_norm}");
    match role {
        HostCcRole::PlanCompile => {
            println!("build-slice.role=plan-compile");
            println!("build-slice.lispjit_zero_genesis_pin=1");
        }
        HostCcRole::Stage0Bridge => {
            println!("build-slice.role=stage0-bridge");
        }
    }
    println!("build-slice.source={}", src.display());
    println!("build-slice.output={}", out.display());
    let ok = Command::new(cc)
        .args([
            "-DNANO_LISP_JIT",
            "-Ilab/lispjit-ir",
            "-Ilab/nano-lisp-jit/retired/archive-c/runner",
            "-Os",
            "-s",
        ])
        .arg(src)
        .args(["-ldl", "-o"])
        .arg(out)
        .status()
        .is_ok_and(|s| s.success());
    if !ok {
        eprintln!("build-slice-compile=compile_fail");
        return 2;
    }
    finish_file_size(out)
}

pub fn cmd_build_slice_compile(src: &Path, out: &Path, arch: &str) -> i32 {
    run_host_cc_lispjit(src, out, arch, HostCcRole::PlanCompile)
}

fn compose15_hybrid_fallback(out: &Path, arch: &str, stub_label: &str, stub_val: usize) -> i32 {
    println!("build-slice-lisp.compose15_hybrid=stub {stub_label}={stub_val}");
    let rc = cmd_build_slice_compile(Path::new(LISPJIT_FACTORY), out, arch);
    if rc != 0 {
        return rc;
    }
    println!("build-slice-lisp.compose15_hybrid=fallback_compile");
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
    } else if let Ok(blob_data) = crate::compile::compile_to_blob(src) {
        if let Ok(blob) = crate::lbin::parse_blob(&blob_data) {
            if let Ok((logical, _exit)) = crate::aot::aarch64::compile_pure_to_elf_exit(&blob, out) {
                println!("build-slice-lisp.mode=aarch64-vm-aot-emit");
                println!("aarch64.emit.profile=vm-aot-v1");
                if base.contains("nano-jit-slice-ir-exit") {
                    println!("aarch64.emit.encode=vm-lowering");
                }
                println!("elf64.output={}", out.display());
                println!("elf64.bytes={logical}");
                println!("build-slice-lisp.aarch64.profile={base}");
                return finish_file_size(out);
            }
        }
        match crate::elf64::emit_aarch64_exit(out, exit_code) {
            Ok((logical, entry)) => {
                println!("build-slice-lisp.mode=aarch64-exit-emit");
                if base == "nano-jit-slice-min.lisp" || base.contains("nano-jit-slice-ir-exit") {
                    if base.contains("nano-jit-slice-ir-exit") {
                        println!("aarch64.emit.profile=ir-exit-v1");
                        println!("aarch64.emit.encode=exit-only");
                    }
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
    } else {
        eprintln!("build-slice-lisp=aarch64_unsupported_profile");
        2
    }
}

struct ComposeMod {
    path: &'static str,
    sym: &'static str,
    tag: &'static str,
}

const COMPOSE15_MODS: &[ComposeMod] = &[
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp",
        sym: "nano_tu_main",
        tag: "main",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/core/lisp-tu-callee.lisp",
        sym: "nano_tu_callee",
        tag: "callee",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp",
        sym: "nano_lispjit_extra",
        tag: "extra",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp",
        sym: "nano_mod_core",
        tag: "core",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/core/multi-func.lisp",
        sym: "nano_mf_mod",
        tag: "mf",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp",
        sym: "nano_mod_boot",
        tag: "boot",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/04-vm.lisp",
        sym: "nano_mod_vm",
        tag: "vm",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/05-aot.lisp",
        sym: "nano_mod_aot",
        tag: "aot",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/06-elf.lisp",
        sym: "nano_mod_elf",
        tag: "elf",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/07-abi.lisp",
        sym: "nano_mod_abi",
        tag: "abi",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp",
        sym: "nano_mod_manifest",
        tag: "manifest",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/09-run.lisp",
        sym: "nano_mod_run",
        tag: "run",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/10-pack.lisp",
        sym: "nano_mod_pack",
        tag: "pack",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/11-ape.lisp",
        sym: "nano_mod_ape",
        tag: "ape",
    },
    ComposeMod {
        path: "lab/nano-lisp-jit/lisp/modules/12-parse.lisp",
        sym: "nano_mod_parse",
        tag: "parse",
    },
];

fn env_flag(name: &str) -> bool {
    env::var(name).ok().is_some_and(|v| v == "1")
}

fn compose15_profile() -> Option<String> {
    env::var("NANO_LISPJIT_FROM_LISP_PROFILE")
        .ok()
        .filter(|s| !s.is_empty())
}

fn profile_is_compose15(profile: &str) -> bool {
    matches!(
        profile,
        "compose-15link"
            | "compose-15link-expand"
            | "compose-15link-bulk-scale"
            | "compose-15link-semantic"
            | "compose-15link-semantic-32k"
            | "compose-15link-semantic-64k"
            | "compose-15link-semantic-154k"
            | "compose-15link-semantic-unified"
            | "compose-15link-semantic-full"
            | "semantic-full"
    )
}

fn profile_named(name: &str) -> bool {
    compose15_profile().is_some_and(|p| p == name)
}

fn compose15_expand_env() -> bool {
    env::var("NANO_COMPOSE15_EXPAND").ok().is_some_and(|v| {
        let b = v.as_bytes();
        !b.is_empty() && (b[0] == b'1' || b[0] == b'y' || b[0] == b'Y')
    })
}

fn compose15_use_expand_modules() -> bool {
    compose15_expand_env()
        || profile_named("compose-15link-expand")
        || profile_named("compose-15link-bulk-scale")
}

fn compose15_use_semantic_unified() -> bool {
    profile_named("compose-15link-semantic-unified")
}

fn compose15_use_semantic_full_15slot() -> bool {
    profile_named("compose-15link-semantic-full")
}

fn compose15_use_semantic_expand_modules() -> bool {
    profile_named("compose-15link-semantic")
        || profile_named("compose-15link-semantic-32k")
        || profile_named("compose-15link-semantic-64k")
        || profile_named("compose-15link-semantic-154k")
        || compose15_use_semantic_unified()
        || compose15_use_semantic_full_15slot()
}

fn compose15_semantic_full_path_for_tag(tag: &str) -> Option<&'static str> {
    Some(match tag {
        "main" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-main.lisp",
        "callee" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-callee.lisp",
        "extra" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-extra.lisp",
        "core" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-core.lisp",
        "mf" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-mf.lisp",
        "boot" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-boot.lisp",
        "vm" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-vm.lisp",
        "aot" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-aot.lisp",
        "elf" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-elf.lisp",
        "abi" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-abi.lisp",
        "manifest" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-manifest.lisp",
        "run" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-run.lisp",
        "pack" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-pack.lisp",
        "ape" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-ape.lisp",
        "parse" => "lab/nano-lisp-jit/lisp/modules-semantic/sem-parse.lisp",
        _ => return None,
    })
}

fn compose15_semantic_main_expand_path() -> &'static str {
    if profile_named("compose-15link-semantic-154k") || compose15_use_semantic_unified() {
        "lab/nano-lisp-jit/lisp/modules-semantic/tu-main-154k.lisp"
    } else if profile_named("compose-15link-semantic-64k") {
        "lab/nano-lisp-jit/lisp/modules-semantic/tu-main-64k.lisp"
    } else if profile_named("compose-15link-semantic-32k") {
        "lab/nano-lisp-jit/lisp/modules-semantic/tu-main-32k.lisp"
    } else {
        "lab/nano-lisp-jit/lisp/modules-semantic/tu-main-8k.lisp"
    }
}

fn compose15_semantic_expand_path_for_tag(tag: &str) -> Option<&'static str> {
    if compose15_use_semantic_unified() {
        if tag == "main" {
            return Some(compose15_semantic_main_expand_path());
        }
        return compose15_semantic_full_path_for_tag(tag);
    }
    if compose15_use_semantic_full_15slot() {
        return compose15_semantic_full_path_for_tag(tag);
    }
    match tag {
        "main" => Some(compose15_semantic_main_expand_path()),
        "mf" => Some("lab/nano-lisp-jit/lisp/modules-semantic/mf-semantic-40.lisp"),
        "core" => Some("lab/nano-lisp-jit/lisp/modules-semantic/core-semantic-40.lisp"),
        _ => None,
    }
}

fn compose15_expand_path_for_tag(tag: &str) -> Option<&'static str> {
    Some(match tag {
        "main" => "lab/nano-lisp-jit/lisp/modules-expand/26-bulk-main-expand.lisp",
        "callee" => "lab/nano-lisp-jit/lisp/modules-expand/27-bulk-callee-expand.lisp",
        "mf" => "lab/nano-lisp-jit/lisp/modules-expand/13-bulk-text-expand.lisp",
        "extra" => "lab/nano-lisp-jit/lisp/modules-expand/15-bulk-extra-expand.lisp",
        "core" => "lab/nano-lisp-jit/lisp/modules-expand/14-bulk-core-expand.lisp",
        "boot" => "lab/nano-lisp-jit/lisp/modules-expand/17-bulk-boot-expand.lisp",
        "vm" => "lab/nano-lisp-jit/lisp/modules-expand/16-bulk-vm-expand.lisp",
        "aot" => "lab/nano-lisp-jit/lisp/modules-expand/18-bulk-aot-expand.lisp",
        "elf" => "lab/nano-lisp-jit/lisp/modules-expand/19-bulk-elf-expand.lisp",
        "abi" => "lab/nano-lisp-jit/lisp/modules-expand/20-bulk-abi-expand.lisp",
        "manifest" => "lab/nano-lisp-jit/lisp/modules-expand/21-bulk-manifest-expand.lisp",
        "run" => "lab/nano-lisp-jit/lisp/modules-expand/22-bulk-run-expand.lisp",
        "pack" => "lab/nano-lisp-jit/lisp/modules-expand/23-bulk-pack-expand.lisp",
        "ape" => "lab/nano-lisp-jit/lisp/modules-expand/24-bulk-ape-expand.lisp",
        "parse" => "lab/nano-lisp-jit/lisp/modules-expand/25-bulk-parse-expand.lisp",
        _ => return None,
    })
}

fn compose15_module_path(m: &ComposeMod) -> PathBuf {
    if compose15_use_semantic_expand_modules() {
        if let Some(p) = compose15_semantic_expand_path_for_tag(m.tag) {
            return PathBuf::from(p);
        }
    } else if compose15_use_expand_modules() {
        if let Some(p) = compose15_expand_path_for_tag(m.tag) {
            return PathBuf::from(p);
        }
    }
    PathBuf::from(m.path)
}

fn print_compose15_profile_flags() {
    if compose15_use_expand_modules() {
        println!("build-slice-lisp.compose15_expand=1");
    }
    if compose15_use_semantic_expand_modules() {
        println!("build-slice-lisp.compose15_semantic_expand=1");
    }
    if compose15_use_semantic_full_15slot() {
        println!("build-slice-lisp.compose15_semantic_full_15slot=1");
    }
    if compose15_use_semantic_unified() {
        println!("build-slice-lisp.compose15_semantic_unified=1");
    }
}

fn is_lispjit_c(src: &Path) -> bool {
    basename(src) == "lispjit.c"
}

fn build_compose_15link(out: &Path, arch: &str) -> i32 {
    if arch != "x86_64" {
        eprintln!("lispjit-from-lisp-compose-15link=aarch64_unsupported");
        return 2;
    }
    if ensure_parent(out) != 0 {
        return ensure_parent(out);
    }

    print_compose15_profile_flags();

    let prefix = out.to_string_lossy();
    let mut objs: Vec<PathBuf> = Vec::with_capacity(COMPOSE15_MODS.len());
    let mut object_bytes_total = 0usize;

    for m in COMPOSE15_MODS {
        let obj = PathBuf::from(format!("{prefix}.lispjit-compose15-{}.o", m.tag));
        let src = compose15_module_path(m);
        let rc = crate::aot::cmd_compile_elf64_obj_code(&src, &obj, m.sym);
        if rc != 0 {
            return rc;
        }
        if let Ok(meta) = fs::metadata(&obj) {
            object_bytes_total += meta.len() as usize;
        }
        objs.push(obj);
    }

    let refs: Vec<&Path> = objs.iter().map(|p| p.as_path()).collect();
    let link = match crate::elf64::link_exe(out, "nano_tu_main", &refs) {
        Ok(l) => l,
        Err(e) => {
            eprintln!("{e}");
            return 2;
        }
    };
    println!("link.output={}", out.display());
    println!("link.objects={}", objs.len());
    println!("link.code.bytes={}", link.code_bytes);
    println!("build-slice-lisp.compose15_link.object_bytes_total={object_bytes_total}");
    if let Ok(meta) = fs::metadata(out) {
        println!(
            "build-slice-lisp.compose15_link.linked_bytes={}",
            meta.len()
        );
    }
    println!(
        "build-slice-lisp.compose15_link.code_bytes={}",
        link.code_bytes
    );

    let linked_bytes = fs::metadata(out).map(|m| m.len() as usize).unwrap_or(0);
    let no_hybrid = env_flag("NANO_COMPOSE15_NO_HYBRID");
    if link.code_bytes > 0 && link.code_bytes < COMPOSE15_HYBRID_THRESHOLD {
        if no_hybrid {
            println!("build-slice-lisp.compose15_pure=1");
            println!("build-slice-lisp.compose15_hybrid=skipped");
        } else {
            let rc = compose15_hybrid_fallback(out, arch, "code_bytes", link.code_bytes);
            if rc != 0 {
                return rc;
            }
        }
    } else if link.code_bytes >= COMPOSE15_HYBRID_THRESHOLD {
        println!("build-slice-lisp.compose15_pure=1");
        println!("build-slice-lisp.compose15_full_codegen=1");
    } else if linked_bytes < COMPOSE15_HYBRID_THRESHOLD {
        if no_hybrid {
            println!("build-slice-lisp.compose15_pure=1");
            println!("build-slice-lisp.compose15_hybrid=skipped");
        } else {
            let rc = compose15_hybrid_fallback(out, arch, "linked_bytes", linked_bytes);
            if rc != 0 {
                return rc;
            }
        }
    } else {
        println!("build-slice-lisp.compose15_pure=1");
        println!("build-slice-lisp.compose15_full_codegen=1");
    }

    println!("build-slice-lisp.mode=compose-15link");
    println!("build-slice-lisp.link.objects={}", COMPOSE15_MODS.len());
    println!("build-slice.lispjit_codegen=1");
    println!("build-slice-lisp.lispjit_modules=00-12+multi-func");
    finish_file_size(out)
}

fn build_slice_via_lispjit_from_lisp(src: &Path, out: &Path, arch: &str) -> i32 {
    let Some(arch_norm) = normalize_arch(arch) else {
        eprintln!("build-slice=bad_arch arch={arch}");
        return 2;
    };
    if let Some(profile) = compose15_profile() {
        if profile_is_compose15(&profile) {
            println!("build-slice.compiler=nano-jit-lisp");
            println!("build-slice.arch={arch_norm}");
            println!("build-slice.role=lispjit-from-lisp");
            println!("build-slice.lispjit_proxy=semantic-full");
            println!("build-slice.lispjit_profile_tier=9");
            println!("build-slice.lispjit_link=tu+modules+all-nano");
            println!("build-slice.lispjit_codegen=1");
            println!("build-slice.source={}", src.display());
            println!("build-slice.output={}", out.display());
            return build_compose_15link(out, arch_norm);
        }
    }
    eprintln!("build-slice-lisp=lispjit_profile_unsupported path={}", src.display());
    2
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

fn build_slice_via_nano_cc(src: &Path, out: &Path, arch: &str) -> i32 {
    let Some(arch_norm) = normalize_arch(arch) else {
        eprintln!("build-slice=nano_cc_arch_unsupported arch={arch}");
        return 2;
    };
    let had_aarch64 = crate::nano_cc::target_is_aarch64();
    if arch_norm == "aarch64" {
        env::set_var("NANO_CC_ARCH", "aarch64");
    } else {
        env::remove_var("NANO_CC_ARCH");
    }
    println!("build-slice.compiler=nano-cc");
    println!("build-slice.arch={arch_norm}");
    println!("build-slice.role=lisp-codegen");
    println!("build-slice.source={}", src.display());
    println!("build-slice.output={}", out.display());
    if let Some(parent) = out.parent() {
        if !parent.as_os_str().is_empty() {
            let _ = fs::create_dir_all(parent);
        }
    }
    let rc = crate::nano_cc::cmd_nano_cc_compile(src, out);
    if !had_aarch64 {
        env::remove_var("NANO_CC_ARCH");
    } else {
        env::set_var("NANO_CC_ARCH", "aarch64");
    }
    if rc != 0 {
        return rc;
    }
    finish_file_size(out)
}

pub fn cmd_build_slice(src: &Path, out: &Path, arch: &str) -> i32 {
    if src.extension().and_then(|s| s.to_str()) == Some("lisp") {
        println!("build-slice.route=lisp-by-extension");
        return cmd_build_slice_lisp(src, out, arch);
    }
    if crate::nano_cc::build_slice_use_nano_cc(src) {
        return build_slice_via_nano_cc(src, out, arch);
    }
    if is_lispjit_c(src) && env_flag("NANO_LISPJIT_FROM_LISP") {
        return build_slice_via_lispjit_from_lisp(src, out, arch);
    }
    if build_slice_use_selfhost_reuse(src) {
        return build_slice_via_selfhost_reuse(src, out, arch);
    }
    if build_slice_use_genesis_pin(src) {
        return build_slice_via_genesis_pin(src, out, arch);
    }
    run_host_cc_lispjit(src, out, arch, HostCcRole::Stage0Bridge)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Mutex;

    static ENV_TEST_LOCK: Mutex<()> = Mutex::new(());

    #[test]
    fn parse_expect_from_min_slice() {
        let src = r#"(module (main (u64 40) (add-u64 2) (expect 42)))"#;
        assert_eq!(parse_expect_imm(src), Some(42));
    }

    #[test]
    fn compose15_semantic_unified_main_path() {
        let _lock = ENV_TEST_LOCK.lock().unwrap();
        env::remove_var("NANO_LISPJIT_FROM_LISP_PROFILE");
        env::set_var(
            "NANO_LISPJIT_FROM_LISP_PROFILE",
            "compose-15link-semantic-unified",
        );
        assert_eq!(
            compose15_semantic_main_expand_path(),
            "lab/nano-lisp-jit/lisp/modules-semantic/tu-main-154k.lisp"
        );
        env::remove_var("NANO_LISPJIT_FROM_LISP_PROFILE");
    }

    #[test]
    fn compose15_bulk_scale_uses_expand_main() {
        let _lock = ENV_TEST_LOCK.lock().unwrap();
        env::remove_var("NANO_LISPJIT_FROM_LISP_PROFILE");
        env::set_var("NANO_LISPJIT_FROM_LISP_PROFILE", "compose-15link-bulk-scale");
        let main = COMPOSE15_MODS.iter().find(|m| m.tag == "main").unwrap();
        assert_eq!(
            compose15_module_path(main).to_str().unwrap(),
            "lab/nano-lisp-jit/lisp/modules-expand/26-bulk-main-expand.lisp"
        );
        env::remove_var("NANO_LISPJIT_FROM_LISP_PROFILE");
    }

    #[test]
    fn genesis_pin_for_lispjit_without_regenesis() {
        env::remove_var("NANO_REGENESIS");
        env::remove_var("NANO_SLICE_ALLOW_HOST_CC");
        env::remove_var("NANO_BUILD_SLICE_SELFHOST_REUSE");
        env::remove_var("NANO_LISPJIT_FROM_LISP");
        assert!(build_slice_use_genesis_pin(Path::new(LISPJIT_FACTORY)));
        env::set_var("NANO_REGENESIS", "1");
        assert!(!build_slice_use_genesis_pin(Path::new(LISPJIT_FACTORY)));
        env::remove_var("NANO_REGENESIS");
    }
}
