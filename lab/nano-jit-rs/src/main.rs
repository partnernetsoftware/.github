mod ape;
mod aot;
mod bootstrap;
mod brand;
mod build_slice;
mod capsule;
mod compile;
mod elf64;
mod ffi;
mod lbin;
mod nano_cc;
mod run;
mod shell_embed;
mod value;
mod vm;

use lbin::{fnv1a64, parse_blob};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const VERSION: &str = env!("CARGO_PKG_VERSION");

fn usage() -> String {
    format!(
        "{} ({}) — .lisp source compiles to .lbin bytecode; VM runs .lbin only\n\
Usage:\n\
  {bin} compile <in.lisp> <out.lbin>   # source -> bytecode (like javac)\n\
  {bin} run <file.lbin>                # execute bytecode (like java)\n\
  {bin} dump <file.lbin>\n\
  {bin} hash <file.lbin>\n\
  {bin} resolve-quiet <file.lbin>\n\
  {bin} inspect-ape <file.com>\n\
  {bin} pack-ape <out.com> <x86.elf> <aarch64.elf>\n\
  {bin} pack-ape-bare <out.ape> <x86.elf> <aarch64.elf>\n\
  {bin} run-ape <file.com> [x86_64|aarch64]\n\
  {bin} run-ape-expect-exit <file.com> <exit> [arch]\n\
  {bin} emit-elf64-exit <out.elf> <exit_code>\n\
  {bin} emit-aarch64-exit <out.elf> <exit_code>\n\
  {bin} aot-aarch64-exit <file.lbin> <out.elf>\n\
  {bin} aot-aarch64-code <file.lbin> <out.elf>\n\
  {bin} compile-aarch64-code <in.lisp> <out.elf>\n\
  {bin} aot-elf64-exit <file.lbin> <out.elf>\n\
  {bin} aot-elf64-code <file.lbin> <out.elf>\n\
  {bin} aot-elf64-obj-code <file.lbin> <out.o> <symbol>\n\
  {bin} compile-elf64-code <in.lisp> <out.elf>\n\
  {bin} compile-elf64-obj-code <in.lisp> <out.o> <symbol>\n\
  {bin} compile-elf64-exe <in.lisp> <out.elf> <entry_symbol>\n\
  {bin} link-elf64-exe <out.elf> <entry_symbol> <obj.o>...\n\
  {bin} pack-capsule <out.nlcap> <in.lisp|in.lbin> [--compress] [--xbin <elf>] [--abin <ape>]\n\
  {bin} inspect-capsule <file.nlcap>\n\
  {bin} run-capsule <file.nlcap> [--tier auto|lbin|sbin|xbin|abin] [--expect <code>]\n\
  {bin} run-bootstrap-plan <plan.lisp>\n\
  {bin} run-expect-exit <executable> <expected_exit>\n\
  {bin} read-file <path>\n\
  {bin} spawn-wait <expected> <executable> [arg...]\n\
  {bin} shell                  # compile+run shell-script.lisp (Phase 1)\n\
  {bin} shell-repl             # minimal stdin REPL via /bin/sh -c\n\
  {bin} shell-ci               # run unified shell ladder bootstrap plan\n\
  {bin}                        # no args → run embedded shell.lbin\n\
  {bin} version\n\
Env:\n\
  NANO_JIT_LEGACY       force legacy COM compile when set\n\
  NANO_PACK_APE_MODE    stub (default) | bare\n",
        brand::PRODUCT,
        brand::PRODUCT_TITLE,
        bin = brand::BINARY_NAME,
    )
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        return ExitCode::from(cmd_shell_embedded() as u8);
    }
    let rc = match args[1].as_str() {
        "version" | "--version" | "-V" => {
            println!("{}", brand::version_line(VERSION));
            println!("{}", brand::arch_line(std::env::consts::ARCH));
            println!("{}", brand::os_line(std::env::consts::OS));
            println!("{}={}", brand::CRATE_NAME, VERSION);
            0
        }
        "run" if args.len() == 3 => cmd_run(Path::new(&args[2])),
        "dump" if args.len() == 3 => cmd_dump(Path::new(&args[2])),
        "hash" if args.len() == 3 => cmd_hash(Path::new(&args[2])),
        "resolve-quiet" if args.len() == 3 => cmd_resolve(Path::new(&args[2]), true),
        "inspect-ape" if args.len() == 3 => ape::inspect_ape(Path::new(&args[2])),
        "pack-ape" if args.len() == 5 => {
            ape::pack_ape(Path::new(&args[2]), Path::new(&args[3]), Path::new(&args[4]))
        }
        "pack-ape-bare" if args.len() == 5 => {
            ape::pack_ape_bare(Path::new(&args[2]), Path::new(&args[3]), Path::new(&args[4]))
        }
        "run-ape" if args.len() == 3 => ape::run_ape(Path::new(&args[2]), None),
        "run-ape" if args.len() == 4 => {
            ape::run_ape(Path::new(&args[2]), Some(args[3].as_str()))
        }
        "run-ape-expect-exit" if args.len() == 4 => {
            ape::run_ape_expect_exit(Path::new(&args[2]), &args[3], None)
        }
        "run-ape-expect-exit" if args.len() == 5 => {
            ape::run_ape_expect_exit(Path::new(&args[2]), &args[3], Some(args[4].as_str()))
        }
        "compile" if args.len() == 4 => cmd_compile(Path::new(&args[2]), Path::new(&args[3])),
        "emit-elf64-exit" if args.len() == 4 => {
            aot::cmd_emit_elf64_exit(Path::new(&args[2]), &args[3])
        }
        "emit-aarch64-exit" if args.len() == 4 => {
            aot::cmd_emit_aarch64_exit(Path::new(&args[2]), &args[3])
        }
        "aot-aarch64-exit" if args.len() == 4 => {
            aot::cmd_aot_aarch64_exit(Path::new(&args[2]), Path::new(&args[3]))
        }
        "aot-aarch64-code" if args.len() == 4 => {
            aot::cmd_aot_aarch64_code(Path::new(&args[2]), Path::new(&args[3]))
        }
        "compile-aarch64-code" if args.len() == 4 => {
            aot::cmd_compile_aarch64_code(Path::new(&args[2]), Path::new(&args[3]))
        }
        "aot-elf64-exit" if args.len() == 4 => {
            aot::cmd_aot_elf64_exit(Path::new(&args[2]), Path::new(&args[3]))
        }
        "aot-elf64-code" if args.len() == 4 => {
            aot::cmd_aot_elf64_code(Path::new(&args[2]), Path::new(&args[3]))
        }
        "aot-elf64-obj-code" if args.len() == 5 => {
            aot::cmd_aot_elf64_obj_code(Path::new(&args[2]), Path::new(&args[3]), &args[4])
        }
        "compile-elf64-code" if args.len() == 4 => {
            aot::cmd_compile_elf64_code(Path::new(&args[2]), Path::new(&args[3]))
        }
        "compile-elf64-obj-code" if args.len() == 5 => {
            aot::cmd_compile_elf64_obj_code(Path::new(&args[2]), Path::new(&args[3]), &args[4])
        }
        "compile-elf64-exe" if args.len() == 5 => {
            aot::cmd_compile_elf64_exe(Path::new(&args[2]), Path::new(&args[3]), &args[4])
        }
        "link-elf64-exe" if args.len() >= 5 => {
            let out = Path::new(&args[2]);
            let entry = &args[3];
            let objs: Vec<&Path> = args[4..].iter().map(|s| Path::new(s.as_str())).collect();
            aot::cmd_link_elf64_exe(out, entry, &objs)
        }
        "run-expect-exit" if args.len() == 4 => {
            run::run_expect_exit(Path::new(&args[2]), &args[3])
        }
        "read-file" if args.len() == 3 => run::read_file(Path::new(&args[2])),
        "spawn-wait" if args.len() >= 4 => {
            let extra: Vec<String> = args[4..].to_vec();
            run::spawn_wait(&args[2], Path::new(&args[3]), &extra)
        }
        "shell" if args.len() == 2 => cmd_shell(),
        "shell-repl" if args.len() == 2 => cmd_shell_repl(),
        "shell-ci" if args.len() == 2 => cmd_shell_ci(),
        "inspect-capsule" if args.len() == 3 => {
            capsule::inspect_capsule(Path::new(&args[2]))
        }
        "pack-capsule" if args.len() >= 4 => cmd_pack_capsule(&args),
        "run-capsule" if args.len() >= 3 => cmd_run_capsule(&args),
        "run-bootstrap-plan" if args.len() == 3 => {
            bootstrap::run_bootstrap_plan(Path::new(&args[2]))
        }
        _ => {
            eprint!("{}", usage());
            1
        }
    };
    ExitCode::from(rc as u8)
}

fn load_blob(path: &Path) -> Result<Vec<u8>, i32> {
    fs::read(path).map_err(|_| {
        eprintln!("blob=read_fail path={}", path.display());
        1
    })
}

fn cmd_run(path: &Path) -> i32 {
    let data = match load_blob(path) {
        Ok(d) => d,
        Err(e) => return e,
    };
    cmd_run_bytes(&data)
}

fn cmd_run_bytes(data: &[u8]) -> i32 {
    let blob = match parse_blob(data) {
        Ok(b) => b,
        Err(e) => {
            eprintln!("blob=parse_fail err={e:?}");
            return 1;
        }
    };
    vm::execute(&blob)
}

fn cmd_dump(path: &Path) -> i32 {
    let data = match load_blob(path) {
        Ok(d) => d,
        Err(e) => return e,
    };
    let blob = match parse_blob(&data) {
        Ok(b) => b,
        Err(_) => {
            eprintln!("blob=parse_fail path={}", path.display());
            return 1;
        }
    };
    print!("{}", blob.dump());
    0
}

fn cmd_hash(path: &Path) -> i32 {
    let data = match load_blob(path) {
        Ok(d) => d,
        Err(e) => return e,
    };
    println!("{:016x}", fnv1a64(&data));
    0
}

fn cmd_resolve(path: &Path, quiet: bool) -> i32 {
    let data = match load_blob(path) {
        Ok(d) => d,
        Err(e) => return e,
    };
    let blob = match parse_blob(&data) {
        Ok(b) => b,
        Err(_) => {
            eprintln!("blob=parse_fail path={}", path.display());
            return 1;
        }
    };
    ffi::resolve_all(&blob, quiet).err().unwrap_or(0)
}

fn legacy_com() -> Option<PathBuf> {
    env::var("NANO_JIT_LEGACY")
        .ok()
        .map(PathBuf::from)
        .or_else(|| {
            let candidates = [
                "lab/nano-lisp-jit/release/nano-lisp.com",
                "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com",
            ];
            for c in candidates {
                let p = PathBuf::from(c);
                if p.is_file() {
                    return Some(p);
                }
            }
            None
        })
}

fn cmd_compile(lisp: &Path, lbin: &Path) -> i32 {
    if env::var("NANO_JIT_LEGACY").is_ok() {
        return cmd_compile_legacy(lisp, lbin);
    }
    match compile::compile_path(lisp, lbin) {
        Ok(()) => {
            println!("compile.engine=rust");
            println!("compile.output={}", lbin.display());
            0
        }
        Err(e) => {
            eprintln!("{e}");
            if let compile::CompileError::UnsupportedSource { .. } = e {
                return 2;
            }
            if let Some(com) = legacy_com() {
                eprintln!("compile.fallback=legacy");
                return cmd_compile_legacy_with(com, lisp, lbin);
            }
            1
        }
    }
}

fn cmd_compile_legacy(lisp: &Path, lbin: &Path) -> i32 {
    let com = match legacy_com() {
        Some(p) => p,
        None => {
            eprintln!("compile=fail reason=no_legacy_com set NANO_JIT_LEGACY");
            return 1;
        }
    };
    cmd_compile_legacy_with(com, lisp, lbin)
}

fn cmd_compile_legacy_with(com: PathBuf, lisp: &Path, lbin: &Path) -> i32 {
    let status = Command::new(&com)
        .arg("compile")
        .arg(lisp)
        .arg(lbin)
        .status();
    match status {
        Ok(s) if s.success() => {
            println!("compile.engine=legacy");
            println!("compile.output={}", lbin.display());
            0
        }
        Ok(s) => s.code().unwrap_or(1),
        Err(e) => {
            eprintln!("compile=fail err={e}");
            1
        }
    }
}

fn cmd_pack_capsule(args: &[String]) -> i32 {
    if args.len() < 4 {
        eprint!("{}", usage());
        return 1;
    }
    let out = Path::new(&args[2]);
    let input = Path::new(&args[3]);
    let mut compress = false;
    let mut xbin: Option<&Path> = None;
    let mut abin: Option<&Path> = None;
    let mut i = 4;
    while i < args.len() {
        match args[i].as_str() {
            "--compress" => compress = true,
            "--xbin" => {
                i += 1;
                if i >= args.len() {
                    eprintln!("pack-capsule=missing_xbin");
                    return 1;
                }
                xbin = Some(Path::new(&args[i]));
            }
            "--abin" => {
                i += 1;
                if i >= args.len() {
                    eprintln!("pack-capsule=missing_abin");
                    return 1;
                }
                abin = Some(Path::new(&args[i]));
            }
            other => {
                eprintln!("pack-capsule=unknown_flag {other}");
                return 1;
            }
        }
        i += 1;
    }
    capsule::cmd_pack_capsule(out, input, xbin, abin, compress)
}

fn cmd_run_capsule(args: &[String]) -> i32 {
    if args.len() < 3 {
        eprint!("{}", usage());
        return 1;
    }
    let path = Path::new(&args[2]);
    let mut tier = "auto";
    let mut expect: Option<&str> = None;
    let mut i = 3;
    while i < args.len() {
        match args[i].as_str() {
            "--tier" => {
                i += 1;
                if i >= args.len() {
                    eprintln!("run-capsule=missing_tier");
                    return 1;
                }
                tier = &args[i];
            }
            "--expect" => {
                i += 1;
                if i >= args.len() {
                    eprintln!("run-capsule=missing_expect");
                    return 1;
                }
                expect = Some(&args[i]);
            }
            other => {
                eprintln!("run-capsule=unknown_flag {other}");
                return 1;
            }
        }
        i += 1;
    }
    capsule::cmd_run_capsule(path, tier, expect)
}

const SHELL_SCRIPT_LISP: &str = "lab/nano-lisp-jit/lisp/shell/shell-script.lisp";
const SHELL_SCRIPT_LBIN: &str = "lab/nano-lisp-jit/.build/nanolisp-shell-script.lbin";
const SHELL_CI_PLAN: &str = "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-ci.lisp";

fn cmd_shell_ci() -> i32 {
    let plan = Path::new(SHELL_CI_PLAN);
    if !plan.is_file() {
        eprintln!("shell-ci=missing_plan path={}", plan.display());
        return 1;
    }
    println!("shell-ci.plan={}", plan.display());
    bootstrap::run_bootstrap_plan(plan)
}

fn cmd_shell_embedded() -> i32 {
    println!("shell.mode=embedded-lbin");
    println!("shell.embed.bytes={}", shell_embed::SHELL_SCRIPT_LBIN.len());
    cmd_run_bytes(shell_embed::SHELL_SCRIPT_LBIN)
}

fn cmd_shell() -> i32 {
    let lisp = Path::new(SHELL_SCRIPT_LISP);
    let lbin = Path::new(SHELL_SCRIPT_LBIN);
    if !lisp.is_file() {
        eprintln!("shell=missing_script path={}", lisp.display());
        return 1;
    }
    if let Some(parent) = lbin.parent() {
        let _ = fs::create_dir_all(parent);
    }
    let rc = cmd_compile(lisp, lbin);
    if rc != 0 {
        return rc;
    }
    println!("shell.mode=lbin-script");
    println!("shell.lisp={}", lisp.display());
    println!("shell.lbin={}", lbin.display());
    cmd_run(lbin)
}

fn cmd_shell_repl() -> i32 {
    use std::io::{self, BufRead, Write};

    println!("nanolisp-shell-repl=begin");
    let stdin = io::stdin();
    let mut stdout = io::stdout();
    for line in stdin.lock().lines() {
        let line = match line {
            Ok(l) => l,
            Err(_) => break,
        };
        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }
        if trimmed == "exit" || trimmed == "quit" {
            break;
        }
        let _ = write!(stdout, "shell> {trimmed}\n");
        let _ = stdout.flush();
        let status = match Command::new("/bin/sh").arg("-c").arg(trimmed).status() {
            Ok(s) => s,
            Err(e) => {
                eprintln!("shell-repl=exec_fail err={e}");
                continue;
            }
        };
        if let Some(code) = status.code() {
            println!("shell-repl.exit={code}");
        }
    }
    println!("nanolisp-shell-repl=ok");
    0
}

#[cfg(test)]
mod tests {
    use super::*;
    use lbin::BlobError;

    #[test]
    fn parse_empty_rejects() {
        assert!(matches!(parse_blob(&[]), Err(BlobError::TooSmall)));
    }
}
