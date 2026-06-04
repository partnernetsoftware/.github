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
mod run;
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
        eprint!("{}", usage());
        return ExitCode::from(1);
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
    let blob = match parse_blob(&data) {
        Ok(b) => b,
        Err(e) => {
            eprintln!("blob=parse_fail path={} err={e:?}", path.display());
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

#[cfg(test)]
mod tests {
    use super::*;
    use lbin::BlobError;

    #[test]
    fn parse_empty_rejects() {
        assert!(matches!(parse_blob(&[]), Err(BlobError::TooSmall)));
    }
}
