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
    CallImport,
    Resolve,
    ExpectU64,
    ConstU64,
    AddU64,
    ConstI64,
    ConstBool,
    ExpectI64,
    ExpectBool,
    ExpectPtr,
    Branch,
    Label,
    AddI64,
    SubI64,
    MulI64,
    EqI64,
    LtI64,
    GtI64,
    NeI64,
    LeI64,
    GeI64,
    NotBool,
    AndBool,
    OrBool,
    NullPtr,
    IsNullPtr,
    IsNonnullPtr,
    AddPtr,
    SubPtr,
    PtrToU64,
    U64ToPtr,
    ConstPtr,
    LoadU8,
    LoadU16,
    LoadU32,
    StoreU8,
    StoreU16,
    StoreU32,
    CallFunc,
    ParamI64,
    LoadArgI64,
}

#[derive(Debug, Clone)]
pub struct InstrDef {
    pub form: SrcForm,
    pub name: Option<String>,
    pub const_name: Option<String>,
    pub const2_name: Option<String>,
    pub imm: u64,
}

#[derive(Debug, Clone)]
pub struct VmFuncDef {
    pub name: String,
    #[allow(dead_code)]
    pub param_count: u32,
    pub instrs: Vec<InstrDef>,
}

#[derive(Debug, Default)]
pub struct Module {
    pub imports: Vec<ImportDef>,
    pub consts: Vec<ConstDef>,
    pub instrs: Vec<InstrDef>,
    pub funcs: Vec<VmFuncDef>,
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

    fn parse_i64_atom(s: &str) -> Option<i64> {
        s.parse().ok()
    }

    fn parse_bool_atom(s: &str) -> Option<bool> {
        match s {
            "true" => Some(true),
            "false" => Some(false),
            _ => None,
        }
    }

    fn parse_expect_ptr_atom(s: &str) -> Option<u32> {
        match s {
            "nonnull" => Some(1),
            "null" => Some(0),
            _ => None,
        }
    }

    fn parse_sig(sig: &str) -> Option<u32> {
        match sig {
            "u64(ptr)" => Some(crate::lbin::SIG_U64_PTR),
            "i32(ptr)" => Some(crate::lbin::SIG_I32_PTR),
            "i32(ptr,ptr)" => Some(crate::lbin::SIG_I32_PTR_PTR),
            "i32()" => Some(crate::lbin::SIG_I32_VOID),
            "i32(i32)" => Some(crate::lbin::SIG_I32_I32),
            "i32(ptr,i32)" => Some(crate::lbin::SIG_I32_PTR_I32),
            _ => None,
        }
    }

    fn find_import(&self, m: &Module, name: &str) -> Option<usize> {
        m.imports.iter().position(|i| i.name == name)
    }

    fn find_func(&self, m: &Module, name: &str) -> Option<usize> {
        m.funcs.iter().position(|f| f.name == name)
    }

    fn push_instr(
        instrs: &mut Vec<InstrDef>,
        form: SrcForm,
        name: Option<String>,
        const_name: Option<String>,
        const2_name: Option<String>,
        imm: u64,
    ) {
        instrs.push(InstrDef {
            form,
            name,
            const_name,
            const2_name,
            imm,
        });
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

    fn parse_body_items(
        &mut self,
        m: &Module,
        param_count: &mut Option<u32>,
        instrs: &mut Vec<InstrDef>,
    ) -> bool {
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

            if head == "block" {
                if !self.parse_body_items(m, param_count, instrs) {
                    return false;
                }
                continue;
            }

            let ok = if head == "resolve" {
                let import_name = self.parse_atom();
                import_name.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(
                            instrs,
                            SrcForm::Resolve,
                            import_name,
                            None,
                            None,
                            0,
                        );
                        true
                    }
            } else if head == "branch" {
                let label = self.parse_atom();
                label.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(instrs, SrcForm::Branch, label, None, None, 0);
                        true
                    }
            } else if head == "label" {
                let label = self.parse_atom();
                label.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(instrs, SrcForm::Label, label, None, None, 0);
                        true
                    }
            } else if matches!(
                head.as_str(),
                "u64"
                    | "add-u64"
                    | "i64"
                    | "add-i64"
                    | "sub-i64"
                    | "mul-i64"
                    | "eq-i64"
                    | "lt-i64"
                    | "gt-i64"
                    | "ne-i64"
                    | "le-i64"
                    | "ge-i64"
            ) {
                let value = match self.parse_atom() {
                    Some(v) => v,
                    None => return false,
                };
                let i64_ops = matches!(
                    head.as_str(),
                    "i64"
                        | "add-i64"
                        | "sub-i64"
                        | "mul-i64"
                        | "eq-i64"
                        | "lt-i64"
                        | "gt-i64"
                        | "ne-i64"
                        | "le-i64"
                        | "ge-i64"
                );
                let form = match head.as_str() {
                    "u64" => SrcForm::ConstU64,
                    "add-u64" => SrcForm::AddU64,
                    "i64" => SrcForm::ConstI64,
                    "add-i64" => SrcForm::AddI64,
                    "sub-i64" => SrcForm::SubI64,
                    "mul-i64" => SrcForm::MulI64,
                    "eq-i64" => SrcForm::EqI64,
                    "lt-i64" => SrcForm::LtI64,
                    "gt-i64" => SrcForm::GtI64,
                    "ne-i64" => SrcForm::NeI64,
                    "le-i64" => SrcForm::LeI64,
                    _ => SrcForm::GeI64,
                };
                let imm = if i64_ops {
                    Self::parse_i64_atom(&value).map(|v| v as u64)
                } else {
                    Self::parse_u64_atom(&value)
                };
                imm.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(instrs, form, None, None, None, imm.unwrap());
                        true
                    }
            } else if head == "bool" {
                let value = self.parse_atom();
                let b = value.as_deref().and_then(Self::parse_bool_atom);
                b.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(
                            instrs,
                            SrcForm::ConstBool,
                            None,
                            None,
                            None,
                            u64::from(b.unwrap()),
                        );
                        true
                    }
            } else if head == "null-ptr" {
                self.eat(')')
                    && {
                        Self::push_instr(instrs, SrcForm::NullPtr, None, None, None, 0);
                        true
                    }
            } else if head == "add-ptr" || head == "sub-ptr" {
                let value = self.parse_atom();
                let imm = value.as_deref().and_then(Self::parse_u64_atom);
                let form = if head == "add-ptr" {
                    SrcForm::AddPtr
                } else {
                    SrcForm::SubPtr
                };
                imm.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(instrs, form, None, None, None, imm.unwrap());
                        true
                    }
            } else if head == "ptr-to-u64" || head == "u64-to-ptr" {
                let form = if head == "ptr-to-u64" {
                    SrcForm::PtrToU64
                } else {
                    SrcForm::U64ToPtr
                };
                self.eat(')')
                    && {
                        Self::push_instr(instrs, form, None, None, None, 0);
                        true
                    }
            } else if head == "const-ptr" {
                let const_name = self.parse_atom();
                const_name.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(
                            instrs,
                            SrcForm::ConstPtr,
                            None,
                            const_name,
                            None,
                            0,
                        );
                        true
                    }
            } else if matches!(head.as_str(), "load-u8" | "load-u16" | "load-u32") {
                let form = match head.as_str() {
                    "load-u8" => SrcForm::LoadU8,
                    "load-u16" => SrcForm::LoadU16,
                    _ => SrcForm::LoadU32,
                };
                self.eat(')')
                    && {
                        Self::push_instr(instrs, form, None, None, None, 0);
                        true
                    }
            } else if matches!(head.as_str(), "store-u8" | "store-u16" | "store-u32") {
                let value = self.parse_atom();
                let imm = value.as_deref().and_then(Self::parse_u64_atom);
                let form = match head.as_str() {
                    "store-u8" => SrcForm::StoreU8,
                    "store-u16" => SrcForm::StoreU16,
                    _ => SrcForm::StoreU32,
                };
                imm.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(instrs, form, None, None, None, imm.unwrap());
                        true
                    }
            } else if head == "is-null-ptr" || head == "is-nonnull-ptr" {
                let form = if head == "is-null-ptr" {
                    SrcForm::IsNullPtr
                } else {
                    SrcForm::IsNonnullPtr
                };
                self.eat(')')
                    && {
                        Self::push_instr(instrs, form, None, None, None, 0);
                        true
                    }
            } else if head == "not-bool" {
                self.eat(')')
                    && {
                        Self::push_instr(instrs, SrcForm::NotBool, None, None, None, 0);
                        true
                    }
            } else if head == "and-bool" || head == "or-bool" {
                let value = self.parse_atom();
                let b = value.as_deref().and_then(Self::parse_bool_atom);
                let form = if head == "and-bool" {
                    SrcForm::AndBool
                } else {
                    SrcForm::OrBool
                };
                b.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(
                            instrs,
                            form,
                            None,
                            None,
                            None,
                            u64::from(b.unwrap()),
                        );
                        true
                    }
            } else if head == "expect" {
                let value = self.parse_atom();
                let parsed = if let Some(v) = value.as_deref() {
                    if let Some(b) = Self::parse_bool_atom(v) {
                        Some((SrcForm::ExpectBool, u64::from(b)))
                    } else if let Some(p) = Self::parse_expect_ptr_atom(v) {
                        Some((SrcForm::ExpectPtr, u64::from(p)))
                    } else if let Some(i) = Self::parse_i64_atom(v) {
                        if i < 0 {
                            Some((SrcForm::ExpectI64, i as u64))
                        } else {
                            Some((SrcForm::ExpectU64, i as u64))
                        }
                    } else if let Some(u) = Self::parse_u64_atom(v) {
                        Some((SrcForm::ExpectU64, u))
                    } else {
                        None
                    }
                } else {
                    None
                };
                parsed.is_some()
                    && self.eat(')')
                    && {
                        let (form, imm) = parsed.unwrap();
                        Self::push_instr(instrs, form, None, None, None, imm);
                        true
                    }
            } else if head == "param" {
                let ty = self.parse_atom();
                let mut ok = false;
                if let Some(count) = param_count.as_mut() {
                    if ty.as_deref() == Some("i64") && *count < 2 && self.eat(')') {
                        *count += 1;
                        Self::push_instr(instrs, SrcForm::ParamI64, None, None, None, 0);
                        ok = true;
                    }
                }
                ok
            } else if head == "load-arg-i64" {
                let value = self.parse_atom();
                let idx = value.as_deref().and_then(Self::parse_u64_atom);
                idx.is_some()
                    && param_count.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(
                            instrs,
                            SrcForm::LoadArgI64,
                            None,
                            None,
                            None,
                            idx.unwrap(),
                        );
                        true
                    }
            } else if head == "call" {
                let target = self.parse_atom();
                let mut const_name = None;
                let mut const2_name = None;
                if target.is_some() {
                    self.skip_ws();
                    if self.peek() != Some(')') {
                        const_name = self.parse_atom();
                        self.skip_ws();
                        if self.peek() != Some(')') {
                            const2_name = self.parse_atom();
                        }
                    }
                }
                let form = if target
                    .as_deref()
                    .is_some_and(|t| self.find_import(m, t).is_some())
                {
                    SrcForm::CallImport
                } else if target
                    .as_deref()
                    .is_some_and(|t| self.find_func(m, t).is_some())
                {
                    SrcForm::CallFunc
                } else {
                    return false;
                };
                target.is_some()
                    && self.eat(')')
                    && {
                        Self::push_instr(instrs, form, target, const_name, const2_name, 0);
                        true
                    }
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
        let mut param_count = None;
        if !self.parse_body_items(m, &mut param_count, &mut instrs) || instrs.is_empty() {
            return false;
        }
        m.instrs = instrs;
        true
    }

    fn parse_func_form(&mut self, m: &mut Module) -> bool {
        let name = match self.parse_atom() {
            Some(n) if !n.is_empty() && n != "main" && self.find_func(m, &n).is_none() => n,
            _ => return false,
        };
        let mut param_count = Some(0u32);
        let mut instrs = Vec::new();
        if !self.parse_body_items(m, &mut param_count, &mut instrs) || instrs.is_empty() {
            return false;
        }
        m.funcs.push(VmFuncDef {
            name,
            param_count: param_count.unwrap_or(0),
            instrs,
        });
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
                "func" => self.parse_func_form(m),
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
