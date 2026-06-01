//! VM value types — mirrors `lab/lispjit-ir/nano_types.h`.

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ValueKind {
    U64 = 1,
    I64 = 2,
    Bool = 3,
    Ptr = 4,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Value {
    pub kind: ValueKind,
    pub bits: u64,
}

impl Value {
    pub fn u64(v: u64) -> Self {
        Self {
            kind: ValueKind::U64,
            bits: v,
        }
    }

    pub fn i64(v: i64) -> Self {
        Self {
            kind: ValueKind::I64,
            bits: v as u64,
        }
    }

    pub fn bool(v: bool) -> Self {
        Self {
            kind: ValueKind::Bool,
            bits: u64::from(v),
        }
    }

    pub fn ptr(p: *const u8) -> Self {
        Self {
            kind: ValueKind::Ptr,
            bits: p as u64,
        }
    }

    pub fn as_call_arg(&self) -> Option<u64> {
        match self.kind {
            ValueKind::U64 | ValueKind::I64 => Some(self.bits),
            _ => None,
        }
    }

    pub fn expect_u64(self, expected: u64) -> bool {
        match self.kind {
            ValueKind::U64 => self.bits == expected,
            ValueKind::I64 => (self.bits as i64) >= 0 && self.bits == expected,
            _ => false,
        }
    }

    pub fn expect_i64(self, expected: i64) -> bool {
        match self.kind {
            ValueKind::I64 => self.bits as i64 == expected,
            ValueKind::U64 if expected >= 0 => self.bits == expected as u64,
            _ => false,
        }
    }

    pub fn expect_bool(self, expected: bool) -> bool {
        self.kind == ValueKind::Bool && (self.bits != 0) == expected
    }

    pub fn expect_ptr(self, nonnull: bool) -> bool {
        self.kind == ValueKind::Ptr && (self.bits != 0) == nonnull
    }

    pub fn add_u64(&mut self, rhs: u64) -> bool {
        if self.kind != ValueKind::U64 {
            return false;
        }
        self.bits = self.bits.wrapping_add(rhs);
        true
    }

    pub fn add_i64(&mut self, rhs: i64) -> bool {
        if self.kind != ValueKind::I64 {
            return false;
        }
        self.bits = (self.bits as i64).wrapping_add(rhs) as u64;
        true
    }

    pub fn sub_i64(&mut self, rhs: i64) -> bool {
        if self.kind != ValueKind::I64 {
            return false;
        }
        self.bits = (self.bits as i64).wrapping_sub(rhs) as u64;
        true
    }

    pub fn mul_i64(&mut self, rhs: i64) -> bool {
        if self.kind != ValueKind::I64 {
            return false;
        }
        self.bits = (self.bits as i64).wrapping_mul(rhs) as u64;
        true
    }

    fn order_i64(bits: u64) -> u64 {
        bits ^ 0x8000_0000_0000_0000
    }

    pub fn eq_i64(&mut self, rhs: i64) -> bool {
        if self.kind != ValueKind::I64 {
            return false;
        }
        *self = Self::bool(self.bits as i64 == rhs);
        true
    }

    pub fn lt_i64(&mut self, rhs: i64) -> bool {
        if self.kind != ValueKind::I64 {
            return false;
        }
        *self = Self::bool(Self::order_i64(self.bits) < Self::order_i64(rhs as u64));
        true
    }

    pub fn gt_i64(&mut self, rhs: i64) -> bool {
        if self.kind != ValueKind::I64 {
            return false;
        }
        *self = Self::bool(Self::order_i64(self.bits) > Self::order_i64(rhs as u64));
        true
    }

    pub fn ne_i64(&mut self, rhs: i64) -> bool {
        if self.kind != ValueKind::I64 {
            return false;
        }
        *self = Self::bool((self.bits as i64) != rhs);
        true
    }

    pub fn le_i64(&mut self, rhs: i64) -> bool {
        if self.kind != ValueKind::I64 {
            return false;
        }
        *self = Self::bool(Self::order_i64(self.bits) <= Self::order_i64(rhs as u64));
        true
    }

    pub fn ge_i64(&mut self, rhs: i64) -> bool {
        if self.kind != ValueKind::I64 {
            return false;
        }
        *self = Self::bool(Self::order_i64(self.bits) >= Self::order_i64(rhs as u64));
        true
    }

    pub fn not_bool(&mut self) -> bool {
        if self.kind != ValueKind::Bool {
            return false;
        }
        *self = Self::bool(self.bits == 0);
        true
    }

    pub fn and_bool(&mut self, rhs: bool) -> bool {
        if self.kind != ValueKind::Bool {
            return false;
        }
        *self = Self::bool(self.bits != 0 && rhs);
        true
    }

    pub fn or_bool(&mut self, rhs: bool) -> bool {
        if self.kind != ValueKind::Bool {
            return false;
        }
        *self = Self::bool(self.bits != 0 || rhs);
        true
    }

    pub fn is_null_ptr(&mut self) -> bool {
        if self.kind != ValueKind::Ptr {
            return false;
        }
        *self = Self::bool(self.bits == 0);
        true
    }

    pub fn is_nonnull_ptr(&mut self) -> bool {
        if self.kind != ValueKind::Ptr {
            return false;
        }
        *self = Self::bool(self.bits != 0);
        true
    }

    pub fn add_ptr(&mut self, rhs: u64) -> bool {
        if self.kind != ValueKind::Ptr {
            return false;
        }
        self.bits = self.bits.wrapping_add(rhs);
        true
    }

    pub fn sub_ptr(&mut self, rhs: u64) -> bool {
        if self.kind != ValueKind::Ptr {
            return false;
        }
        self.bits = self.bits.wrapping_sub(rhs);
        true
    }

    pub fn ptr_to_u64(&mut self) -> bool {
        if self.kind != ValueKind::Ptr {
            return false;
        }
        self.kind = ValueKind::U64;
        true
    }

    pub fn u64_to_ptr(&mut self) -> bool {
        if self.kind != ValueKind::U64 {
            return false;
        }
        self.kind = ValueKind::Ptr;
        true
    }

    pub fn load_u8(&mut self) -> bool {
        if self.kind != ValueKind::Ptr || self.bits == 0 {
            return false;
        }
        let p = self.bits as *const u8;
        self.kind = ValueKind::U64;
        self.bits = u64::from(unsafe { *p });
        true
    }

    pub fn load_u16(&mut self) -> bool {
        if self.kind != ValueKind::Ptr || self.bits == 0 {
            return false;
        }
        let p = self.bits as *const u8;
        unsafe {
            self.kind = ValueKind::U64;
            self.bits = u64::from(*p) | (u64::from(*p.add(1)) << 8);
        }
        true
    }

    pub fn load_u32(&mut self) -> bool {
        if self.kind != ValueKind::Ptr || self.bits == 0 {
            return false;
        }
        let p = self.bits as *const u8;
        unsafe {
            self.kind = ValueKind::U64;
            self.bits = u64::from(*p)
                | (u64::from(*p.add(1)) << 8)
                | (u64::from(*p.add(2)) << 16)
                | (u64::from(*p.add(3)) << 24);
        }
        true
    }

    pub fn store_u8(&mut self, byte: u64) -> bool {
        if self.kind != ValueKind::Ptr || self.bits == 0 || byte > 255 {
            return false;
        }
        unsafe {
            *(self.bits as *mut u8) = byte as u8;
        }
        true
    }

    pub fn store_u16(&mut self, word: u64) -> bool {
        if self.kind != ValueKind::Ptr || self.bits == 0 || word > 65535 {
            return false;
        }
        let p = self.bits as *mut u8;
        unsafe {
            *p = (word & 0xff) as u8;
            *p.add(1) = ((word >> 8) & 0xff) as u8;
        }
        true
    }

    pub fn store_u32(&mut self, dword: u64) -> bool {
        if self.kind != ValueKind::Ptr || self.bits == 0 || dword > 0xffff_ffff {
            return false;
        }
        let p = self.bits as *mut u8;
        unsafe {
            *p = (dword & 0xff) as u8;
            *p.add(1) = ((dword >> 8) & 0xff) as u8;
            *p.add(2) = ((dword >> 16) & 0xff) as u8;
            *p.add(3) = ((dword >> 24) & 0xff) as u8;
        }
        true
    }

    pub fn print(&self, out: &mut impl std::io::Write) -> std::io::Result<()> {
        match self.kind {
            ValueKind::U64 => write!(out, "{}", self.bits),
            ValueKind::I64 => write!(out, "{}", self.bits as i64),
            ValueKind::Bool => write!(out, "{}", if self.bits != 0 { "true" } else { "false" }),
            ValueKind::Ptr if self.bits == 0 => write!(out, "null"),
            ValueKind::Ptr => write!(out, "0x{:x}", self.bits),
        }
    }
}

pub fn imm64(lo: u32, hi: u32) -> u64 {
    u64::from(lo) | (u64::from(hi) << 32)
}

pub fn imm_i64(lo: u32, hi: u32) -> i64 {
    imm64(lo, hi) as i64
}
