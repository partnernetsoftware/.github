//! Bootstrap plan DSL — `run-bootstrap-plan` for compose-link, APE pack, proc I/O.

use std::fs;
use std::path::{Path, PathBuf};

use crate::compile::CompileError;

#[derive(Debug, Clone)]
pub(crate) enum Step {
    CompileObjCode {
        lisp: PathBuf,
        out: PathBuf,
        symbol: String,
    },
    CompileElf64Exe {
        lisp: PathBuf,
        out: PathBuf,
        symbol: String,
    },
    Compile {
        lisp: PathBuf,
        lbin: PathBuf,
    },
    Run {
        lbin: PathBuf,
    },
    LinkElf64Exe {
        out: PathBuf,
        entry: String,
        objs: Vec<PathBuf>,
    },
    RunExpectExit {
        exe: PathBuf,
        exit: String,
    },
    RunApeExpectExit {
        path: PathBuf,
        exit: String,
        arch: Option<String>,
    },
    FileSize {
        path: PathBuf,
    },
    FileHash {
        path: PathBuf,
    },
    Hash {
        path: PathBuf,
    },
    PackApe {
        out: PathBuf,
        x86: PathBuf,
        arm: PathBuf,
    },
    PackApeBare {
        out: PathBuf,
        x86: PathBuf,
        arm: PathBuf,
    },
    InspectApe {
        path: PathBuf,
    },
    RunApe {
        path: PathBuf,
        arch: Option<String>,
    },
    EmitElf64Exit {
        out: PathBuf,
        exit: String,
    },
    ReadFile {
        path: PathBuf,
    },
    SpawnWait {
        expected: String,
        path: PathBuf,
        args: Vec<String>,
    },
    ResultsMin {
        path: PathBuf,
        key: String,
        min: String,
    },
    CompileExpectExit {
        expected: String,
        mode: String,
        src: PathBuf,
        out: PathBuf,
        extra: Vec<String>,
    },
    BuildSliceLisp {
        src: PathBuf,
        out: PathBuf,
        arch: String,
    },
    BuildSlice {
        src: PathBuf,
        out: PathBuf,
        arch: String,
    },
    BuildSliceCompile {
        src: PathBuf,
        out: PathBuf,
        arch: String,
    },
    NanoCcCompile {
        src: PathBuf,
        out: PathBuf,
    },
}

struct Parser<'a> {
    input: &'a str,
    pos: usize,
}

impl<'a> Parser<'a> {
    fn new(input: &'a str) -> Self {
        Self { input, pos: 0 }
    }

    fn peek(&self) -> Option<char> {
        self.input[self.pos..].chars().next()
    }

    fn bump(&mut self) {
        if let Some(c) = self.peek() {
            self.pos += c.len_utf8();
        }
    }

    fn skip_ws(&mut self) {
        while matches!(self.peek(), Some(' ' | '\t' | '\r' | '\n' | ';')) {
            if self.peek() == Some(';') {
                while matches!(self.peek(), Some(c) if c != '\n') {
                    self.bump();
                }
            }
            self.bump();
        }
    }

    fn expect(&mut self, ch: char) -> bool {
        self.skip_ws();
        if self.peek() == Some(ch) {
            self.bump();
            true
        } else {
            false
        }
    }

    fn parse_atom(&mut self) -> Option<String> {
        self.skip_ws();
        let start = self.pos;
        match self.peek()? {
            '"' => {
                self.bump();
                while let Some(c) = self.peek() {
                    if c == '"' {
                        self.bump();
                        return Some(self.input[start + 1..self.pos - 1].to_string());
                    }
                    if c == '\\' {
                        self.bump();
                        if self.peek().is_some() {
                            self.bump();
                        }
                        continue;
                    }
                    self.bump();
                }
                None
            }
            c if c.is_ascii_alphabetic() || c == '_' || c == '-' => {
                while matches!(self.peek(), Some(c) if c.is_ascii() && (c.is_alphanumeric() || c == '_') || c == '-') {
                    self.bump();
                }
                Some(self.input[start..self.pos].to_string())
            }
            c if c.is_ascii_digit() => {
                while matches!(self.peek(), Some(c) if c.is_ascii_digit()) {
                    self.bump();
                }
                Some(self.input[start..self.pos].to_string())
            }
            _ => None,
        }
    }

    fn parse_remaining_strings(&mut self) -> Vec<String> {
        let mut out = Vec::new();
        loop {
            self.skip_ws();
            if self.peek() == Some(')') {
                break;
            }
            if let Some(s) = self.parse_atom() {
                out.push(s);
            } else {
                break;
            }
        }
        out
    }

    fn parse_step(&mut self) -> Option<Step> {
        if !self.expect('(') {
            return None;
        }
        let head = self.parse_atom()?;
        let step = match head.as_str() {
            "compile-elf64-obj-code" => {
                let lisp = PathBuf::from(self.parse_atom()?);
                let out = PathBuf::from(self.parse_atom()?);
                let symbol = self.parse_atom()?;
                Step::CompileObjCode { lisp, out, symbol }
            }
            "compile-elf64-exe" => {
                let lisp = PathBuf::from(self.parse_atom()?);
                let out = PathBuf::from(self.parse_atom()?);
                let symbol = self.parse_atom()?;
                Step::CompileElf64Exe { lisp, out, symbol }
            }
            "compile" => {
                let lisp = PathBuf::from(self.parse_atom()?);
                let lbin = PathBuf::from(self.parse_atom()?);
                Step::Compile { lisp, lbin }
            }
            "run" => Step::Run {
                lbin: PathBuf::from(self.parse_atom()?),
            },
            "link-elf64-exe" => {
                let out = PathBuf::from(self.parse_atom()?);
                let entry = self.parse_atom()?;
                let mut objs = Vec::new();
                loop {
                    self.skip_ws();
                    if self.peek() == Some(')') {
                        break;
                    }
                    objs.push(PathBuf::from(self.parse_atom()?));
                }
                Step::LinkElf64Exe { out, entry, objs }
            }
            "run-expect-exit" => Step::RunExpectExit {
                exe: PathBuf::from(self.parse_atom()?),
                exit: self.parse_atom()?,
            },
            "run-ape-expect-exit" => {
                let path = PathBuf::from(self.parse_atom()?);
                let exit = self.parse_atom()?;
                self.skip_ws();
                let arch = if self.peek() != Some(')') {
                    Some(self.parse_atom()?)
                } else {
                    None
                };
                Step::RunApeExpectExit { path, exit, arch }
            }
            "file-size" => Step::FileSize {
                path: PathBuf::from(self.parse_atom()?),
            },
            "file-hash" => Step::FileHash {
                path: PathBuf::from(self.parse_atom()?),
            },
            "hash" => Step::Hash {
                path: PathBuf::from(self.parse_atom()?),
            },
            "pack-ape" => {
                let out = PathBuf::from(self.parse_atom()?);
                let x86 = PathBuf::from(self.parse_atom()?);
                let arm = PathBuf::from(self.parse_atom()?);
                Step::PackApe { out, x86, arm }
            }
            "pack-ape-bare" => {
                let out = PathBuf::from(self.parse_atom()?);
                let x86 = PathBuf::from(self.parse_atom()?);
                let arm = PathBuf::from(self.parse_atom()?);
                Step::PackApeBare { out, x86, arm }
            }
            "inspect-ape" => Step::InspectApe {
                path: PathBuf::from(self.parse_atom()?),
            },
            "run-ape" => {
                let path = PathBuf::from(self.parse_atom()?);
                self.skip_ws();
                let arch = if self.peek() != Some(')') {
                    Some(self.parse_atom()?)
                } else {
                    None
                };
                Step::RunApe { path, arch }
            }
            "emit-elf64-exit" => Step::EmitElf64Exit {
                out: PathBuf::from(self.parse_atom()?),
                exit: self.parse_atom()?,
            },
            "read-file" => Step::ReadFile {
                path: PathBuf::from(self.parse_atom()?),
            },
            "spawn-wait" => {
                let expected = self.parse_atom()?;
                let path = PathBuf::from(self.parse_atom()?);
                let args = self.parse_remaining_strings();
                Step::SpawnWait {
                    expected,
                    path,
                    args,
                }
            }
            "results-min" => {
                let path = PathBuf::from(self.parse_atom()?);
                let key = self.parse_atom()?;
                let min = self.parse_atom()?;
                Step::ResultsMin { path, key, min }
            }
            "compile-expect-exit" => {
                let expected = self.parse_atom()?;
                let mode = self.parse_atom()?;
                let src = PathBuf::from(self.parse_atom()?);
                let out = PathBuf::from(self.parse_atom()?);
                let extra = self.parse_remaining_strings();
                Step::CompileExpectExit {
                    expected,
                    mode,
                    src,
                    out,
                    extra,
                }
            }
            "build-slice-lisp" => {
                let src = PathBuf::from(self.parse_atom()?);
                let out = PathBuf::from(self.parse_atom()?);
                let arch = self.parse_atom()?;
                Step::BuildSliceLisp { src, out, arch }
            }
            "build-slice" => {
                let src = PathBuf::from(self.parse_atom()?);
                let out = PathBuf::from(self.parse_atom()?);
                let arch = self.parse_atom()?;
                Step::BuildSlice { src, out, arch }
            }
            "build-slice-compile" => {
                let src = PathBuf::from(self.parse_atom()?);
                let out = PathBuf::from(self.parse_atom()?);
                let arch = self.parse_atom()?;
                Step::BuildSliceCompile { src, out, arch }
            }
            "nano-cc-compile" => {
                let src = PathBuf::from(self.parse_atom()?);
                let out = PathBuf::from(self.parse_atom()?);
                Step::NanoCcCompile { src, out }
            }
            _ => return None,
        };
        if !self.expect(')') {
            return None;
        }
        Some(step)
    }

    fn parse_plan(&mut self) -> Option<Vec<Step>> {
        if !self.expect('(') {
            return None;
        }
        let head = self.parse_atom()?;
        if head != "bootstrap" {
            return None;
        }
        let mut steps = Vec::new();
        loop {
            self.skip_ws();
            if self.peek() == Some(')') {
                self.bump();
                self.skip_ws();
                return Some(steps);
            }
            steps.push(self.parse_step()?);
        }
    }
}

pub fn parse_bootstrap_plan(src: &str) -> Result<Vec<Step>, i32> {
    let mut p = Parser::new(src);
    p.parse_plan().ok_or_else(|| {
        eprintln!("bootstrap-plan=parse_fail");
        1
    })
}

fn ensure_parent(path: &Path) -> i32 {
    if let Some(parent) = path.parent() {
        if !parent.as_os_str().is_empty() && fs::create_dir_all(parent).is_err() {
            eprintln!("bootstrap-plan=mkdir_fail path={}", parent.display());
            return 3;
        }
    }
    0
}

fn compile_rc(lisp: &Path, lbin: &Path) -> i32 {
    if ensure_parent(lbin) != 0 {
        return ensure_parent(lbin);
    }
    match crate::compile::compile_path(lisp, lbin) {
        Ok(()) => {
            println!("compile.engine=rust");
            println!("compile.output={}", lbin.display());
            0
        }
        Err(e @ CompileError::UnsupportedSource { .. }) => {
            eprintln!("{e}");
            2
        }
        Err(e) => {
            eprintln!("{e}");
            1
        }
    }
}

fn run_compile_subcommand(mode: &str, src: &Path, out: &Path, extra: &[String]) -> i32 {
    match mode {
        "compile" => compile_rc(src, out),
        "compile-elf64-obj-code" => {
            if extra.len() != 1 {
                return 1;
            }
            if ensure_parent(out) != 0 {
                return ensure_parent(out);
            }
            crate::aot::cmd_compile_elf64_obj_code(src, out, &extra[0])
        }
        "compile-elf64-exe" => {
            if extra.len() != 1 {
                return 1;
            }
            if ensure_parent(out) != 0 {
                return ensure_parent(out);
            }
            crate::aot::cmd_compile_elf64_exe(src, out, &extra[0])
        }
        "compile-elf64-code" => {
            if !extra.is_empty() {
                return 1;
            }
            if ensure_parent(out) != 0 {
                return ensure_parent(out);
            }
            crate::aot::cmd_compile_elf64_code(src, out)
        }
        _ => 1,
    }
}

fn check_compile_expect_exit(
    expected_s: &str,
    mode: &str,
    src: &Path,
    out: &Path,
    extra: &[String],
    label: &str,
) -> i32 {
    let expected: u64 = match expected_s.parse() {
        Ok(v) if v <= 255 => v,
        _ => {
            eprintln!("{label}=bad_expected");
            return 2;
        }
    };
    let rc = run_compile_subcommand(mode, src, out, extra);
    if rc as u64 != expected {
        eprintln!("{label}=unexpected expected={expected} actual={rc}");
        return 2;
    }
    println!("{label}.mode={mode}");
    println!("{label}.ok={expected}");
    0
}

pub fn run_bootstrap_plan(path: &Path) -> i32 {
    let src = match fs::read_to_string(path) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("bootstrap-plan=read_fail path={}", path.display());
            return 1;
        }
    };
    let steps = match parse_bootstrap_plan(&src) {
        Ok(s) => s,
        Err(e) => return e,
    };
    println!("bootstrap-plan.path={}", path.display());
    println!("bootstrap-plan.steps={}", steps.len());
    for (i, step) in steps.iter().enumerate() {
        let rc = match step {
            Step::CompileObjCode { lisp, out, symbol } => {
                println!("bootstrap-step.{i}=compile-elf64-obj-code");
                match ensure_parent(out) {
                    0 => crate::aot::cmd_compile_elf64_obj_code(lisp, out, symbol),
                    e => e,
                }
            }
            Step::CompileElf64Exe { lisp, out, symbol } => {
                println!("bootstrap-step.{i}=compile-elf64-exe");
                match ensure_parent(out) {
                    0 => crate::aot::cmd_compile_elf64_exe(lisp, out, symbol),
                    e => e,
                }
            }
            Step::Compile { lisp, lbin } => {
                println!("bootstrap-step.{i}=compile");
                compile_rc(lisp, lbin)
            }
            Step::Run { lbin } => {
                println!("bootstrap-step.{i}=run");
                let data = match fs::read(lbin) {
                    Ok(d) => d,
                    Err(_) => {
                        eprintln!("bootstrap-run=read_fail path={}", lbin.display());
                        return 1;
                    }
                };
                let blob = match crate::lbin::parse_blob(&data) {
                    Ok(b) => b,
                    Err(_) => {
                        eprintln!("bootstrap-run=parse_fail path={}", lbin.display());
                        return 1;
                    }
                };
                crate::vm::execute(&blob)
            }
            Step::LinkElf64Exe { out, entry, objs } => {
                println!("bootstrap-step.{i}=link-elf64-exe");
                match ensure_parent(out) {
                    0 => {
                        let refs: Vec<&Path> = objs.iter().map(|p| p.as_path()).collect();
                        crate::aot::cmd_link_elf64_exe(out, entry, &refs)
                    }
                    e => e,
                }
            }
            Step::RunExpectExit { exe, exit } => {
                println!("bootstrap-step.{i}=run-expect-exit");
                crate::run::run_expect_exit(exe, exit)
            }
            Step::RunApeExpectExit { path, exit, arch } => {
                println!("bootstrap-step.{i}=run-ape-expect-exit");
                crate::ape::run_ape_expect_exit(path, exit, arch.as_deref())
            }
            Step::FileSize { path } => {
                println!("bootstrap-step.{i}=file-size");
                match fs::metadata(path) {
                    Ok(m) => {
                        println!("file-size.path={}", path.display());
                        println!("file-size.bytes={}", m.len());
                        0
                    }
                    Err(_) => {
                        eprintln!("file-size=fail path={}", path.display());
                        1
                    }
                }
            }
            Step::FileHash { path } => {
                println!("bootstrap-step.{i}=file-hash");
                match fs::read(path) {
                    Ok(data) => {
                        let h = crate::lbin::fnv1a64(&data);
                        println!("file-hash.path={}", path.display());
                        println!("file-hash.fnv1a64={h:016x}");
                        0
                    }
                    Err(_) => {
                        eprintln!("file-hash=fail path={}", path.display());
                        1
                    }
                }
            }
            Step::Hash { path } => {
                println!("bootstrap-step.{i}=hash");
                match fs::read(path) {
                    Ok(data) => {
                        println!("{:016x}", crate::lbin::fnv1a64(&data));
                        0
                    }
                    Err(_) => {
                        eprintln!("hash=fail path={}", path.display());
                        1
                    }
                }
            }
            Step::PackApe { out, x86, arm } => {
                println!("bootstrap-step.{i}=pack-ape");
                match ensure_parent(out) {
                    0 => crate::ape::pack_ape(out, x86, arm),
                    e => e,
                }
            }
            Step::PackApeBare { out, x86, arm } => {
                println!("bootstrap-step.{i}=pack-ape-bare");
                match ensure_parent(out) {
                    0 => crate::ape::pack_ape_bare(out, x86, arm),
                    e => e,
                }
            }
            Step::InspectApe { path } => {
                println!("bootstrap-step.{i}=inspect-ape");
                crate::ape::inspect_ape(path)
            }
            Step::RunApe { path, arch } => {
                println!("bootstrap-step.{i}=run-ape");
                crate::ape::run_ape(path, arch.as_deref())
            }
            Step::EmitElf64Exit { out, exit } => {
                println!("bootstrap-step.{i}=emit-elf64-exit");
                match ensure_parent(out) {
                    0 => crate::aot::cmd_emit_elf64_exit(out, exit),
                    e => e,
                }
            }
            Step::ReadFile { path } => {
                println!("bootstrap-step.{i}=read-file");
                crate::run::read_file(path)
            }
            Step::SpawnWait { expected, path, args } => {
                println!("bootstrap-step.{i}=spawn-wait");
                crate::run::spawn_wait(expected, path, args)
            }
            Step::ResultsMin { path, key, min } => {
                println!("bootstrap-step.{i}=results-min");
                crate::run::results_min(path, key, min)
            }
            Step::CompileExpectExit {
                expected,
                mode,
                src,
                out,
                extra,
            } => {
                println!("bootstrap-step.{i}=compile-expect-exit");
                check_compile_expect_exit(
                    expected,
                    mode,
                    src,
                    out,
                    extra,
                    "bootstrap-compile-expect-exit",
                )
            }
            Step::BuildSliceLisp { src, out, arch } => {
                println!("bootstrap-step.{i}=build-slice-lisp");
                crate::build_slice::cmd_build_slice_lisp(src, out, arch)
            }
            Step::BuildSlice { src, out, arch } => {
                println!("bootstrap-step.{i}=build-slice");
                crate::build_slice::cmd_build_slice(src, out, arch)
            }
            Step::BuildSliceCompile { src, out, arch } => {
                println!("bootstrap-step.{i}=build-slice-compile");
                crate::build_slice::cmd_build_slice_compile(src, out, arch)
            }
            Step::NanoCcCompile { src, out } => {
                println!("bootstrap-step.{i}=nano-cc-compile");
                if let Some(parent) = out.parent() {
                    if !parent.as_os_str().is_empty() {
                        let _ = fs::create_dir_all(parent);
                    }
                }
                crate::nano_cc::cmd_nano_cc_compile(src, out)
            }
        };
        if rc != 0 {
            eprintln!("bootstrap-plan=step_fail index={i} rc={rc}");
            return rc;
        }
    }
    println!("bootstrap-plan.ok=1");
    0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_minimal_plan() {
        let src = r#"
(bootstrap
  (run-expect-exit "out.elf" 42))
"#;
        let steps = parse_bootstrap_plan(src).unwrap();
        assert_eq!(steps.len(), 1);
    }

    #[test]
    fn parse_pack_ape_plan() {
        let src = r#"
(bootstrap
  (pack-ape "out.com" "x86.elf" "arm.elf")
  (inspect-ape "out.com"))
"#;
        let steps = parse_bootstrap_plan(src).unwrap();
        assert_eq!(steps.len(), 2);
    }

    #[test]
    fn parse_spawn_wait_plan() {
        let src = r#"
(bootstrap
  (spawn-wait 7 "/bin/sh" "-c" "exit 7"))
"#;
        let steps = parse_bootstrap_plan(src).unwrap();
        assert_eq!(steps.len(), 1);
        if let Step::SpawnWait { args, .. } = &steps[0] {
            assert_eq!(args, &["-c".to_string(), "exit 7".to_string()]);
        } else {
            panic!("expected spawn-wait");
        }
    }
}
