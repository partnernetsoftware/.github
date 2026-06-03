//! Product identity — user-facing **nanolisp.com** (Lisp runtime).
//! Internal engines (JIT / FFI / AOT) stay implementation details.

pub const PRODUCT: &str = "nanolisp.com";
pub const PRODUCT_TITLE: &str = "Nanolisp";
pub const BINARY_NAME: &str = "nanolisp";
pub const LEGACY_BINARY: &str = "nano-jit";
pub const CRATE_NAME: &str = "nano-jit-rs";

pub fn version_line(version: &str) -> String {
    format!("{PRODUCT}={version}")
}

pub fn arch_line(arch: &str) -> String {
    format!("{PRODUCT}.arch={arch}")
}

pub fn os_line(os: &str) -> String {
    format!("{PRODUCT}.os={os}")
}
