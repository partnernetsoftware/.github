mod ape;
mod compile;
mod ffi;
mod lbin;
mod value;
mod vm;

use lbin::{fnv1a64, parse_blob};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const VERSION: &str = env!("CARGO_PKG_VERSION");

fn usage() -> &'static str {
    "nano-jit (Rust) — portable .lbin VM, multi-target CLI\n\
Usage:\n\
  nano-jit run <file.lbin>\n\
  nano-jit dump <file.lbin>\n\
  nano-jit hash <file.lbin>\n\
  nano-jit resolve-quiet <file.lbin>\n\
  nano-jit inspect-ape <file.com>\n\
  nano-jit compile <in.lisp> <out.lbin>   # native Rust compiler (legacy fallback)\n\
  nano-jit version\n\
Env:\n\
  NANO_JIT_LEGACY  force legacy COM compile when set\n"
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprint!("{}", usage());
        return ExitCode::from(1);
    }
    let rc = match args[1].as_str() {
        "version" | "--version" | "-V" => {
            println!("nano-jit-rs={VERSION}");
            println!("nano-jit.arch={}", std::env::consts::ARCH);
            println!("nano-jit.os={}", std::env::consts::OS);
            0
        }
        "run" if args.len() == 3 => cmd_run(Path::new(&args[2])),
        "dump" if args.len() == 3 => cmd_dump(Path::new(&args[2])),
        "hash" if args.len() == 3 => cmd_hash(Path::new(&args[2])),
        "resolve-quiet" if args.len() == 3 => cmd_resolve(Path::new(&args[2]), true),
        "inspect-ape" if args.len() == 3 => ape::inspect_ape(Path::new(&args[2])),
        "compile" if args.len() == 4 => cmd_compile(Path::new(&args[2]), Path::new(&args[3])),
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

#[cfg(test)]
mod tests {
    use super::*;
    use lbin::BlobError;

    #[test]
    fn parse_empty_rejects() {
        assert!(matches!(parse_blob(&[]), Err(BlobError::TooSmall)));
    }
}
