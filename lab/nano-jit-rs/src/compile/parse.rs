use super::emit::CompileError;

#[derive(Debug, Clone)]
pub struct ImportDef {
    pub name: String,
    pub lib: String,
    pub symbol: String,
    pub sig: u32,
}

#[derive(Debug, Clone)]
pub struct ConstDef {
    pub name: String,
    pub value: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SrcForm {
    ConstU64,
    AddU64,
    Expect,
    CallImport,
    #[allow(dead_code)]
    CallFunc,
}

#[derive(Debug, Clone)]
pub struct InstrDef {
    pub form: SrcForm,
    pub target: Option<String>,
    pub const_name: Option<String>,
    pub imm: u64,
}

#[derive(Debug, Default)]
pub struct Module {
    pub imports: Vec<ImportDef>,
    pub consts: Vec<ConstDef>,
    pub instrs: Vec<InstrDef>,
}

struct Parser<'a> {
    src: &'a str,
    pos: usize,
}

impl<'a> Parser<'a> {
    fn new(src: &'a str) -> Self {
        Self { src, pos: 0 }
    }

    fn peek(&self) -> Option<char> {
        self.src[self.pos..].chars().next()
    }

    fn bump(&mut self) -> Option<char> {
        let c = self.peek()?;
        self.pos += c.len_utf8();
        Some(c)
    }

    fn skip_ws(&mut self) {
        loop {
            while matches!(self.peek(), Some(' ' | '\t' | '\r' | '\n')) {
                self.bump();
            }
            if self.peek() == Some(';') {
                while self.peek().is_some_and(|c| c != '\n') {
                    self.bump();
                }
                continue;
            }
            break;
        }
    }

    fn eat(&mut self, c: char) -> bool {
        self.skip_ws();
        if self.peek() == Some(c) {
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
            '(' | ')' | '"' | ';' => return None,
            _ => {}
        }
        while let Some(c) = self.peek() {
            if matches!(c, '(' | ')' | '"' | ';' | ' ' | '\t' | '\r' | '\n') {
                break;
            }
            self.bump();
        }
        if self.pos == start {
            None
        } else {
            Some(self.src[start..self.pos].to_string())
        }
    }

    fn parse_string(&mut self) -> Option<String> {
        self.skip_ws();
        if self.peek() != Some('"') {
            return None;
        }
        self.bump();
        let mut out = String::new();
        while let Some(c) = self.peek() {
            if c == '"' {
                self.bump();
                return Some(out);
            }
            self.bump();
            if c == '\\' {
                let esc = self.bump()?;
                match esc {
                    'n' => out.push('\n'),
                    't' => out.push('\t'),
                    other => out.push(other),
                }
            } else {
                out.push(c);
            }
        }
        None
    }

    fn parse_u64_atom(s: &str) -> Option<u64> {
        s.parse().ok()
    }

    fn parse_sig(sig: &str) -> Option<u32> {
        match sig {
            "u64(ptr)" => Some(crate::lbin::SIG_U64_PTR),
            "i32(ptr)" => Some(crate::lbin::SIG_I32_PTR),
            "i32(ptr,ptr)" => Some(crate::lbin::SIG_I32_PTR_PTR),
            "i32()" => Some(crate::lbin::SIG_I32_VOID),
            "i32(i32)" => Some(crate::lbin::SIG_I32_I32),
            _ => None,
        }
    }

    fn find_import(&self, m: &Module, name: &str) -> Option<usize> {
        m.imports.iter().position(|i| i.name == name)
    }

    fn parse_import_form(&mut self, m: &mut Module) -> bool {
        let name = match self.parse_atom() {
            Some(n) => n,
            None => return false,
        };
        let lib = match self.parse_string() {
            Some(s) => s,
            None => return false,
        };
        let symbol = match self.parse_string() {
            Some(s) => s,
            None => return false,
        };
        let sig_str = match self.parse_string() {
            Some(s) => s,
            None => return false,
        };
        if !self.eat(')') {
            return false;
        }
        let sig = match Self::parse_sig(&sig_str) {
            Some(s) => s,
            None => return false,
        };
        m.imports.push(ImportDef {
            name,
            lib,
            symbol,
            sig,
        });
        true
    }

    fn parse_const_form(&mut self, m: &mut Module) -> bool {
        let name = match self.parse_atom() {
            Some(n) => n,
            None => return false,
        };
        let value = match self.parse_string() {
            Some(s) => s,
            None => return false,
        };
        if !self.eat(')') {
            return false;
        }
        m.consts.push(ConstDef { name, value });
        true
    }

    fn add_instr(
        &self,
        instrs: &mut Vec<InstrDef>,
        form: SrcForm,
        target: Option<String>,
        const_name: Option<String>,
        imm: u64,
    ) {
        instrs.push(InstrDef {
            form,
            target,
            const_name,
            imm,
        });
    }

    fn parse_body_items(&mut self, m: &Module, instrs: &mut Vec<InstrDef>) -> bool {
        loop {
            self.skip_ws();
            if self.peek() == Some(')') {
                self.bump();
                return true;
            }
            if !self.eat('(') {
                return false;
            }
            let head = match self.parse_atom() {
                Some(h) => h,
                None => return false,
            };
            let ok = if head == "u64" || head == "add-u64" {
                let value = match self.parse_atom() {
                    Some(v) => v,
                    None => return false,
                };
                let imm = match Self::parse_u64_atom(&value) {
                    Some(v) => v,
                    None => return false,
                };
                if !self.eat(')') {
                    return false;
                }
                let form = if head == "u64" {
                    SrcForm::ConstU64
                } else {
                    SrcForm::AddU64
                };
                self.add_instr(instrs, form, None, None, imm);
                true
            } else if head == "expect" {
                let value = match self.parse_atom() {
                    Some(v) => v,
                    None => return false,
                };
                let expected = match Self::parse_u64_atom(&value) {
                    Some(v) => v,
                    None => return false,
                };
                if !self.eat(')') {
                    return false;
                }
                self.add_instr(instrs, SrcForm::Expect, None, None, expected);
                true
            } else if head == "call" {
                let target = match self.parse_atom() {
                    Some(t) => t,
                    None => return false,
                };
                let mut const_name = None;
                self.skip_ws();
                if self.peek() != Some(')') {
                    const_name = self.parse_atom();
                }
                if !self.eat(')') {
                    return false;
                }
                let form = if self.find_import(m, &target).is_some() {
                    SrcForm::CallImport
                } else {
                    return false;
                };
                self.add_instr(instrs, form, Some(target), const_name, 0);
                true
            } else {
                false
            };
            if !ok {
                return false;
            }
        }
    }

    fn parse_main_form(&mut self, m: &mut Module) -> bool {
        let mut instrs = Vec::new();
        if !self.parse_body_items(m, &mut instrs) || instrs.is_empty() {
            return false;
        }
        m.instrs = instrs;
        true
    }

    fn parse_module_inner(&mut self, m: &mut Module) -> bool {
        if !self.eat('(') {
            return false;
        }
        let module = match self.parse_atom() {
            Some(s) if s == "module" => s,
            _ => return false,
        };
        let _ = module;

        loop {
            self.skip_ws();
            if self.peek() == Some(')') {
                self.bump();
                self.skip_ws();
                return self.pos == self.src.len() && !m.instrs.is_empty();
            }
            if !self.eat('(') {
                return false;
            }
            let head = match self.parse_atom() {
                Some(h) => h,
                None => return false,
            };
            let ok = match head.as_str() {
                "import" => self.parse_import_form(m),
                "const" => self.parse_const_form(m),
                "main" => self.parse_main_form(m),
                _ => false,
            };
            if !ok {
                return false;
            }
        }
    }
}

pub fn parse_module(src: &str) -> Result<Module, CompileError> {
    let mut p = Parser::new(src);
    let mut m = Module::default();
    if p.parse_module_inner(&mut m) {
        Ok(m)
    } else {
        Err(CompileError::ParseFail)
    }
}
