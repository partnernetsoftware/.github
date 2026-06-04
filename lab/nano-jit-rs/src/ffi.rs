//! Dynamic library FFI — mirrors C runner import resolution.

use crate::lbin::{sig_name, Blob, SIG_ADDR, SIG_I32_I32, SIG_I32_PTR, SIG_I32_PTR_I32, SIG_I32_PTR_PTR, SIG_I32_VOID, SIG_U64_PTR};
use crate::value::Value;
use libloading::{Library, Symbol};
use std::collections::HashMap;
use std::ffi::CString;
use std::io::{self, BufRead, Write};

unsafe extern "C" fn nano_readline_shim(buf: *mut u8, size: i32) -> i32 {
    if buf.is_null() || size < 2 {
        return 0;
    }
    let mut stdout = io::stdout();
    let _ = write!(stdout, "shell> ");
    let _ = stdout.flush();
    let stdin = io::stdin();
    let mut line = String::new();
    match stdin.lock().read_line(&mut line) {
        Ok(0) => 0,
        Ok(_) => {
            let trimmed = line.trim_end_matches(['\n', '\r']);
            let cap = (size - 1).max(0) as usize;
            let n = trimmed.len().min(cap);
            std::ptr::copy_nonoverlapping(trimmed.as_ptr(), buf, n);
            *buf.add(n) = 0;
            1
        }
        Err(_) => 0,
    }
}

pub struct RuntimeImport {
    pub lib: String,
    pub sym: String,
    pub sig: u32,
    pub fn_addr: usize,
    _library: Library,
    u64_ptr: Option<Symbol<'static, unsafe extern "C" fn(*const u8) -> u64>>,
    i32_ptr: Option<Symbol<'static, unsafe extern "C" fn(*const u8) -> i32>>,
    i32_ptr_ptr: Option<Symbol<'static, unsafe extern "C" fn(*const u8, *const u8) -> i32>>,
    i32_void: Option<Symbol<'static, unsafe extern "C" fn() -> i32>>,
    i32_i32: Option<Symbol<'static, unsafe extern "C" fn(i32) -> i32>>,
    i32_ptr_i32: Option<Symbol<'static, unsafe extern "C" fn(*mut u8, i32) -> i32>>,
}

impl RuntimeImport {
    pub fn resolve(blob: &Blob, idx: u32) -> Result<Self, i32> {
        let row = blob.import_row(idx).ok_or(12)?;
        let lib = blob.string_at(crate::lbin::rd32(row, 0)).ok_or(13)?;
        let sym = blob.string_at(crate::lbin::rd32(row, 4)).ok_or(13)?;
        let sig = crate::lbin::rd32(row, 8);
        if lib == "nano" {
            return Self::resolve_nano(lib, sym, sig);
        }
        let lib_name = open_library_name(lib);
        let library = unsafe { Library::new(&lib_name) }.map_err(|_| {
            let _ = writeln!(io::stderr(), "ffi.open=fail lib={lib}");
            14
        })?;
        if sig == SIG_ADDR {
            return Self::resolve_addr(lib, sym, library);
        }
        let mut ri = Self {
            lib: lib.to_string(),
            sym: sym.to_string(),
            sig,
            fn_addr: 0,
            _library: library,
            u64_ptr: None,
            i32_ptr: None,
            i32_ptr_ptr: None,
            i32_void: None,
            i32_i32: None,
            i32_ptr_i32: None,
        };
        ri.bind_symbol(sym)?;
        Ok(ri)
    }

    fn resolve_nano(lib: &str, sym: &str, sig: u32) -> Result<Self, i32> {
        if sym != "read-line" || sig != SIG_I32_PTR_I32 {
            let _ = writeln!(io::stderr(), "ffi.nano=unsupported {lib}:{sym}");
            return Err(15);
        }
        let library = unsafe { Library::new(open_library_name("libc")) }.map_err(|_| {
            let _ = writeln!(io::stderr(), "ffi.open=fail lib=nano-shim");
            14
        })?;
        Ok(Self {
            lib: lib.to_string(),
            sym: sym.to_string(),
            sig,
            fn_addr: nano_readline_shim as *const () as usize,
            _library: library,
            u64_ptr: None,
            i32_ptr: None,
            i32_ptr_ptr: None,
            i32_void: None,
            i32_i32: None,
            i32_ptr_i32: None,
        })
    }

    fn resolve_addr(lib: &str, sym: &str, library: Library) -> Result<Self, i32> {
        let cname = CString::new(sym).map_err(|_| 15)?;
        let ptr = unsafe {
            let symbol: Symbol<*const *const std::ffi::c_void> = library
                .get(cname.as_bytes_with_nul())
                .map_err(|_| {
                    let _ = writeln!(io::stderr(), "ffi.symbol=fail symbol={sym}");
                    15
                })?;
            *symbol as usize
        };
        Ok(Self {
            lib: lib.to_string(),
            sym: sym.to_string(),
            sig: SIG_ADDR,
            fn_addr: ptr,
            _library: library,
            u64_ptr: None,
            i32_ptr: None,
            i32_ptr_ptr: None,
            i32_void: None,
            i32_i32: None,
            i32_ptr_i32: None,
        })
    }

    fn bind_symbol(&mut self, sym: &str) -> Result<(), i32> {
        let cname = CString::new(sym).map_err(|_| 15)?;
        let sym_bytes = cname.as_bytes_with_nul();
        unsafe {
            match self.sig {
                SIG_U64_PTR => {
                    let s: Symbol<unsafe extern "C" fn(*const u8) -> u64> =
                        self._library.get(sym_bytes).map_err(|_| {
                            let _ = writeln!(io::stderr(), "ffi.symbol=fail symbol={sym}");
                            15
                        })?;
                    self.fn_addr = *s as *const () as usize;
                    self.u64_ptr = Some(std::mem::transmute(s));
                }
                SIG_I32_PTR => {
                    let s: Symbol<unsafe extern "C" fn(*const u8) -> i32> =
                        self._library.get(sym_bytes).map_err(|_| 15)?;
                    self.fn_addr = *s as *const () as usize;
                    self.i32_ptr = Some(std::mem::transmute(s));
                }
                SIG_I32_PTR_PTR => {
                    let s: Symbol<unsafe extern "C" fn(*const u8, *const u8) -> i32> =
                        self._library.get(sym_bytes).map_err(|_| 15)?;
                    self.fn_addr = *s as *const () as usize;
                    self.i32_ptr_ptr = Some(std::mem::transmute(s));
                }
                SIG_I32_VOID => {
                    let s: Symbol<unsafe extern "C" fn() -> i32> =
                        self._library.get(sym_bytes).map_err(|_| 15)?;
                    self.fn_addr = *s as *const () as usize;
                    self.i32_void = Some(std::mem::transmute(s));
                }
                SIG_I32_I32 => {
                    let s: Symbol<unsafe extern "C" fn(i32) -> i32> =
                        self._library.get(sym_bytes).map_err(|_| 15)?;
                    self.fn_addr = *s as *const () as usize;
                    self.i32_i32 = Some(std::mem::transmute(s));
                }
                SIG_I32_PTR_I32 => {
                    let s: Symbol<unsafe extern "C" fn(*mut u8, i32) -> i32> =
                        self._library.get(sym_bytes).map_err(|_| 15)?;
                    self.fn_addr = *s as *const () as usize;
                    self.i32_ptr_i32 = Some(std::mem::transmute(s));
                }
                _ => {
                    let _ = writeln!(
                        io::stderr(),
                        "signature.arg_mismatch={}",
                        sig_name(self.sig)
                    );
                    return Err(17);
                }
            }
        }
        Ok(())
    }

    pub fn call1(&self, arg: &str) -> Result<Value, i32> {
        let c = CString::new(arg).map_err(|_| 13)?;
        let p = c.as_ptr() as *const u8;
        unsafe {
            match self.sig {
                SIG_U64_PTR => {
                    let f = self.u64_ptr.as_ref().ok_or(17)?;
                    Ok(Value::u64(f(p)))
                }
                SIG_I32_PTR => {
                    let f = self.i32_ptr.as_ref().ok_or(17)?;
                    Ok(Value::i64(i64::from(f(p))))
                }
                _ => {
                    let _ = writeln!(
                        io::stderr(),
                        "signature.arg_mismatch={}",
                        sig_name(self.sig)
                    );
                    Err(17)
                }
            }
        }
    }

    pub fn call2(&self, arg0: &str, arg1: &str) -> Result<Value, i32> {
        if self.sig != SIG_I32_PTR_PTR {
            let _ = writeln!(
                io::stderr(),
                "signature.arg_mismatch={}",
                sig_name(self.sig)
            );
            return Err(17);
        }
        let c0 = CString::new(arg0).map_err(|_| 13)?;
        let c1 = CString::new(arg1).map_err(|_| 13)?;
        unsafe {
            let f = self.i32_ptr_ptr.as_ref().ok_or(17)?;
            Ok(Value::i64(i64::from(f(
                c0.as_ptr() as *const u8,
                c1.as_ptr() as *const u8,
            ))))
        }
    }

    pub fn call0(&self) -> Result<Value, i32> {
        if self.sig != SIG_I32_VOID {
            return Err(17);
        }
        unsafe {
            let f = self.i32_void.as_ref().ok_or(17)?;
            Ok(Value::i64(i64::from(f())))
        }
    }

    pub fn call_i32(&self, arg: i32) -> Result<Value, i32> {
        if self.sig != SIG_I32_I32 {
            return Err(17);
        }
        unsafe {
            let f = self.i32_i32.as_ref().ok_or(17)?;
            Ok(Value::i64(i64::from(f(arg))))
        }
    }

    pub fn call_ptr_i32(&self, buf: &str, size: i32) -> Result<Value, i32> {
        if self.sig != SIG_I32_PTR_I32 {
            let _ = writeln!(
                io::stderr(),
                "signature.arg_mismatch={}",
                sig_name(self.sig)
            );
            return Err(17);
        }
        if self.lib == "nano" && self.sym == "read-line" {
            unsafe {
                let p = buf.as_ptr() as *mut u8;
                Ok(Value::i64(i64::from(nano_readline_shim(p, size))))
            }
        } else {
            unsafe {
                let f = self.i32_ptr_i32.as_ref().ok_or(17)?;
                Ok(Value::i64(i64::from(f(
                    buf.as_ptr() as *mut u8,
                    size,
                ))))
            }
        }
    }
}

fn open_library_name(name: &str) -> String {
    if name == "libc" {
        #[cfg(target_os = "linux")]
        {
            return "libc.so.6".to_string();
        }
        #[cfg(target_os = "macos")]
        {
            return "libSystem.B.dylib".to_string();
        }
    }
    name.to_string()
}

pub fn resolve_all(blob: &Blob, quiet: bool) -> Result<(), i32> {
    let mut cache = HashMap::new();
    for i in 0..blob.import_count {
        if cache.contains_key(&i) {
            continue;
        }
        let ri = RuntimeImport::resolve(blob, i)?;
        if !quiet {
            println!(
                "resolve.{i}={}:{} sig={} ok",
                ri.lib,
                ri.sym,
                sig_name(ri.sig)
            );
        }
        cache.insert(i, ());
    }
    println!("resolve.imports={}", blob.import_count);
    println!("resolve.ok={}", blob.import_count);
    Ok(())
}
