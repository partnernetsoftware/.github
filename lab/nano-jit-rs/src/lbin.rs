//! `.lbin` bytecode wire format (LBIN01) — compiled output of `.lisp`, analogous to `.class`.
//! Produced by `compile`, consumed by the VM (`run`). Compatible with C runner layout.

pub const HEADER_SIZE: usize = 32;
pub const IMPORT_SIZE: usize = 16;
pub const CONST_SIZE: usize = 16;
pub const INSTR_SIZE: usize = 12;
pub const FUNC_ENTRY_SIZE: usize = 12;

pub const MAGIC_LBIN: [u8; 8] = *b"LBIN01\0\0";
pub const MAGIC_LJIR: [u8; 8] = *b"LJIRB1\0\0";

pub const CONST_STRING: u32 = 1;

pub const OP_CALL_IMPORT_CONST: u8 = 1;
pub const OP_RET_LAST: u8 = 2;
pub const OP_CALL_IMPORT_CONST2: u8 = 3;
pub const OP_RESOLVE_IMPORT: u8 = 4;
pub const OP_CALL_IMPORT_VOID: u8 = 5;
pub const OP_EXPECT_U64: u8 = 6;
pub const OP_CONST_U64: u8 = 7;
pub const OP_ADD_U64: u8 = 8;
pub const OP_CALL_IMPORT_IMM: u8 = 9;
pub const OP_CONST_I64: u8 = 10;
pub const OP_CONST_BOOL: u8 = 11;
pub const OP_EXPECT_I64: u8 = 12;
pub const OP_EXPECT_BOOL: u8 = 13;
pub const OP_EXPECT_PTR: u8 = 14;
pub const OP_BRANCH_BOOL: u8 = 15;
pub const OP_ADD_I64: u8 = 16;
pub const OP_SUB_I64: u8 = 17;
pub const OP_MUL_I64: u8 = 18;
pub const OP_EQ_I64: u8 = 19;
pub const OP_LT_I64: u8 = 20;
pub const OP_GT_I64: u8 = 21;
pub const OP_NE_I64: u8 = 22;
pub const OP_LE_I64: u8 = 23;
pub const OP_GE_I64: u8 = 24;
pub const OP_NOT_BOOL: u8 = 25;
pub const OP_AND_BOOL: u8 = 26;
pub const OP_OR_BOOL: u8 = 27;
pub const OP_NULL_PTR: u8 = 28;
pub const OP_IS_NULL_PTR: u8 = 29;
pub const OP_IS_NONNULL_PTR: u8 = 30;
pub const OP_ADD_PTR: u8 = 31;
pub const OP_SUB_PTR: u8 = 32;
pub const OP_PTR_TO_U64: u8 = 33;
pub const OP_U64_TO_PTR: u8 = 34;
pub const OP_CONST_PTR: u8 = 35;
pub const OP_LOAD_U8: u8 = 36;
pub const OP_LOAD_U16: u8 = 37;
pub const OP_LOAD_U32: u8 = 38;
pub const OP_STORE_U8: u8 = 39;
pub const OP_STORE_U16: u8 = 40;
pub const OP_STORE_U32: u8 = 41;
pub const OP_CALL_FUNC: u8 = 42;
pub const OP_LOAD_ARG_I64: u8 = 43;

pub const SIG_U64_PTR: u32 = 1;
pub const SIG_I32_PTR: u32 = 2;
pub const SIG_I32_PTR_PTR: u32 = 3;
pub const SIG_I32_VOID: u32 = 4;
pub const SIG_I32_I32: u32 = 5;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BlobFormat {
    Lbin,
    Ljir,
}

#[derive(Debug)]
pub struct Blob<'a> {
    pub data: &'a [u8],
    pub format: BlobFormat,
    pub version: u32,
    pub func_count: u32,
    pub import_count: u32,
    pub const_count: u32,
    pub instr_count: u32,
    pub string_size: u32,
    pub import_off: usize,
    pub const_off: usize,
    pub instr_off: usize,
    pub string_off: usize,
    pub func_off: usize,
}

#[derive(Debug)]
pub enum BlobError {
    TooSmall,
    BadMagic,
    BadVersion,
    BadLayout,
}

pub fn rd32(data: &[u8], off: usize) -> u32 {
    u32::from_le_bytes(data[off..off + 4].try_into().unwrap())
}

pub fn parse_blob(data: &[u8]) -> Result<Blob<'_>, BlobError> {
    if data.len() < HEADER_SIZE {
        return Err(BlobError::TooSmall);
    }
    let format = if data.starts_with(&MAGIC_LBIN) {
        BlobFormat::Lbin
    } else if data.starts_with(&MAGIC_LJIR) {
        BlobFormat::Ljir
    } else {
        return Err(BlobError::BadMagic);
    };
    let version = rd32(data, 8);
    if version != 1 {
        return Err(BlobError::BadVersion);
    }
    let func_count = rd32(data, 12);
    let import_count = rd32(data, 16);
    let const_count = rd32(data, 20);
    let instr_count = rd32(data, 24);
    let string_size = rd32(data, 28);
    let import_off = HEADER_SIZE;
    let const_off = import_off + import_count as usize * IMPORT_SIZE;
    let instr_off = const_off + const_count as usize * CONST_SIZE;
    let string_off = instr_off + instr_count as usize * INSTR_SIZE;
    let func_off = string_off + string_size as usize;
    let end = func_off + func_count as usize * FUNC_ENTRY_SIZE;
    if end > data.len() {
        if func_count == 0 && string_off + string_size as usize == data.len() {
            return Ok(Blob {
                data,
                format,
                version,
                func_count,
                import_count,
                const_count,
                instr_count,
                string_size,
                import_off,
                const_off,
                instr_off,
                string_off,
                func_off: data.len(),
            });
        }
        return Err(BlobError::BadLayout);
    }
    if end != data.len() {
        return Err(BlobError::BadLayout);
    }
    Ok(Blob {
        data,
        format,
        version,
        func_count,
        import_count,
        const_count,
        instr_count,
        string_size,
        import_off,
        const_off,
        instr_off,
        string_off,
        func_off,
    })
}

impl<'a> Blob<'a> {
    pub fn string_at(&self, off: u32) -> Option<&'a str> {
        let base = self.string_off + off as usize;
        if off >= self.string_size {
            return None;
        }
        let slice = &self.data[base..self.string_off + self.string_size as usize];
        let nul = slice.iter().position(|&b| b == 0)?;
        std::str::from_utf8(&slice[..nul]).ok()
    }

    pub fn import_row(&self, idx: u32) -> Option<&'a [u8]> {
        if idx >= self.import_count {
            return None;
        }
        let off = self.import_off + idx as usize * IMPORT_SIZE;
        Some(&self.data[off..off + IMPORT_SIZE])
    }

    pub fn const_row(&self, idx: u32) -> Option<&'a [u8]> {
        if idx >= self.const_count {
            return None;
        }
        let off = self.const_off + idx as usize * CONST_SIZE;
        Some(&self.data[off..off + CONST_SIZE])
    }

    pub fn instr_row(&self, idx: u32) -> Option<&'a [u8]> {
        if idx >= self.instr_count {
            return None;
        }
        let off = self.instr_off + idx as usize * INSTR_SIZE;
        Some(&self.data[off..off + INSTR_SIZE])
    }

    pub fn func_entry_row(&self, idx: u32) -> Option<&'a [u8]> {
        if idx >= self.func_count {
            return None;
        }
        let off = self.func_off + idx as usize * FUNC_ENTRY_SIZE;
        Some(&self.data[off..off + FUNC_ENTRY_SIZE])
    }

    pub fn const_string_ref(&self, idx: u32) -> Option<&'a str> {
        let row = self.const_row(idx)?;
        if rd32(row, 0) != CONST_STRING {
            return None;
        }
        self.string_at(rd32(row, 4))
    }

    pub fn dump(&self) -> String {
        let mut out = String::new();
        out.push_str(&format!(
            "blob.format={}\n",
            if self.format == BlobFormat::Lbin {
                "lbin"
            } else {
                "legacy-ljir"
            }
        ));
        out.push_str(&format!("blob.version={}\n", self.version));
        out.push_str(&format!("blob.imports={}\n", self.import_count));
        out.push_str(&format!("blob.consts={}\n", self.const_count));
        out.push_str(&format!("blob.instructions={}\n", self.instr_count));
        out.push_str(&format!("blob.strings={}\n", self.string_size));
        for i in 0..self.import_count {
            let r = self.import_row(i).unwrap();
            let sig = rd32(r, 8);
            out.push_str(&format!(
                "import.{}={}:{} sig={}({})\n",
                i,
                self.string_at(rd32(r, 0)).unwrap_or("?"),
                self.string_at(rd32(r, 4)).unwrap_or("?"),
                sig_name(sig),
                sig
            ));
        }
        out
    }
}

pub fn sig_name(sig: u32) -> &'static str {
    match sig {
        0 => "addr",
        SIG_U64_PTR => "u64(ptr)",
        SIG_I32_PTR => "i32(ptr)",
        SIG_I32_PTR_PTR => "i32(ptr,ptr)",
        SIG_I32_VOID => "i32()",
        SIG_I32_I32 => "i32(i32)",
        _ => "unknown",
    }
}

pub fn fnv1a64(data: &[u8]) -> u64 {
    let mut h: u64 = 1469598103934665603;
    for &b in data {
        h ^= u64::from(b);
        h = h.wrapping_mul(1099511628211);
    }
    h
}
