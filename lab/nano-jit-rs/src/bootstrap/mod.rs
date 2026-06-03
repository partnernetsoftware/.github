//! Bootstrap plan DSL — minimal `run-bootstrap-plan` for compose-link probes.

use std::fs;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone)]
pub(crate) enum Step {
    CompileObjCode {
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
    FileSize {
        path: PathBuf,
    },
    FileHash {
        path: PathBuf,
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
            "file-size" => Step::FileSize {
                path: PathBuf::from(self.parse_atom()?),
            },
            "file-hash" => Step::FileHash {
                path: PathBuf::from(self.parse_atom()?),
            },
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
            Step::Compile { lisp, lbin } => {
                println!("bootstrap-step.{i}=compile");
                if ensure_parent(lbin) != 0 {
                    ensure_parent(lbin)
                } else {
                    match crate::compile::compile_path(lisp, lbin) {
                        Ok(()) => 0,
                        Err(e) => {
                            eprintln!("{e}");
                            1
                        }
                    }
                }
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
}
