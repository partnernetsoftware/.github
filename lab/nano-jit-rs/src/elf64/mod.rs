//! Minimal ELF64 ET_EXEC emitter — port of `nano_elf64.c` RX / multi-section layout.

mod link;
mod obj;

use std::fs;
use std::io;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;

pub use link::{link_exe, link_exe_from_obj};
pub use obj::{emit_obj_file, ObjRela, ObjSymbol};

const EHDR_SIZE: usize = 64;
const PHDR_SIZE: usize = 56;
const EXEC_BASE: u64 = 0x400_000;
const MACHINE_X86_64: u16 = 62;

#[derive(Default, Clone, Copy)]
pub struct ExecLayout {
    pub text_va: u64,
    pub rodata_va: u64,
    pub data_va: u64,
}

fn align_up(n: usize, a: usize) -> usize {
    (n + a - 1) & !(a - 1)
}

fn exec_layout(code_n: usize, rodata_n: usize, data_n: usize) -> (ExecLayout, usize) {
    let page = 0x1000;
    let nph = 1 + (rodata_n > 0) as usize + (data_n > 0) as usize;
    let mut off = EHDR_SIZE + nph * PHDR_SIZE;
    let mut va = off;
    let mut layout = ExecLayout {
        text_va: EXEC_BASE + va as u64,
        ..Default::default()
    };
    off += code_n;
    va += code_n;
    if rodata_n > 0 {
        off = align_up(off, page);
        va = align_up(va, page);
        layout.rodata_va = EXEC_BASE + va as u64;
        off += rodata_n;
        va += rodata_n;
    }
    if data_n > 0 {
        off = align_up(off, page);
        va = align_up(va, page);
        layout.data_va = EXEC_BASE + va as u64;
        off += data_n;
        va += data_n;
    }
    (layout, align_up(off, page))
}

fn wr16(buf: &mut [u8], off: usize, v: u16) {
    buf[off..off + 2].copy_from_slice(&v.to_le_bytes());
}

fn wr32(buf: &mut [u8], off: usize, v: u32) {
    buf[off..off + 4].copy_from_slice(&v.to_le_bytes());
}

fn wr64(buf: &mut [u8], off: usize, v: u64) {
    buf[off..off + 8].copy_from_slice(&v.to_le_bytes());
}

fn wr_ident(buf: &mut [u8]) {
    buf[..16].fill(0);
    buf[0] = 0x7f;
    buf[1..4].copy_from_slice(b"ELF");
    buf[4] = 2;
    buf[5] = 1;
    buf[6] = 1;
}

fn wr_ehdr_exec(buf: &mut [u8], entry: u64, phoff: u64, phnum: u16, machine: u16) {
    wr_ident(buf);
    wr16(buf, 16, 2);
    wr16(buf, 18, machine);
    wr32(buf, 20, 1);
    wr64(buf, 24, entry);
    wr64(buf, 32, phoff);
    wr16(buf, 52, EHDR_SIZE as u16);
    wr16(buf, 54, PHDR_SIZE as u16);
    wr16(buf, 56, phnum);
}

fn wr_phdr(
    buf: &mut [u8],
    off: usize,
    flags: u32,
    file_off: u64,
    vaddr: u64,
    filesz: u64,
) {
    wr32(buf, off, 1);
    wr32(buf, off + 4, flags);
    wr64(buf, off + 8, file_off);
    wr64(buf, off + 16, vaddr);
    wr64(buf, off + 24, vaddr);
    wr64(buf, off + 32, filesz);
    wr64(buf, off + 40, filesz);
    wr64(buf, off + 48, 0x1000);
}

fn make_executable(path: &Path) -> io::Result<()> {
    let mut perms = fs::metadata(path)?.permissions();
    perms.set_mode(0o755);
    fs::set_permissions(path, perms)
}

pub fn emit_exec_sections(
    path: &Path,
    code: &[u8],
    rodata: &[u8],
    data: &[u8],
) -> io::Result<(usize, u64)> {
    let (layout, file_n) = exec_layout(code.len(), rodata.len(), data.len());
    let nph = 1 + (rodata.len() > 0) as u16 + (data.len() > 0) as u16;
    let mut out = vec![0u8; file_n];
    wr_ehdr_exec(&mut out, layout.text_va, EHDR_SIZE as u64, nph, MACHINE_X86_64);

    let mut ph = EHDR_SIZE;
    let text_off = (layout.text_va - EXEC_BASE) as usize;
    wr_phdr(&mut out, ph, 5, text_off as u64, layout.text_va, code.len() as u64);
    ph += PHDR_SIZE;
    if !rodata.is_empty() {
        let ro_off = layout.rodata_va - EXEC_BASE;
        wr_phdr(
            &mut out,
            ph,
            4,
            ro_off,
            layout.rodata_va,
            rodata.len() as u64,
        );
        ph += PHDR_SIZE;
    }
    if !data.is_empty() {
        let data_off = layout.data_va - EXEC_BASE;
        wr_phdr(
            &mut out,
            ph,
            6,
            data_off,
            layout.data_va,
            data.len() as u64,
        );
    }

    out[text_off..text_off + code.len()].copy_from_slice(code);
    if !rodata.is_empty() {
        let ro_off = (layout.rodata_va - EXEC_BASE) as usize;
        out[ro_off..ro_off + rodata.len()].copy_from_slice(rodata);
    }
    if !data.is_empty() {
        let data_off = (layout.data_va - EXEC_BASE) as usize;
        out[data_off..data_off + data.len()].copy_from_slice(data);
    }

    fs::write(path, &out)?;
    make_executable(path)?;
    Ok((EHDR_SIZE + nph as usize * PHDR_SIZE + code.len(), layout.text_va))
}

pub fn emit_exec_rx(path: &Path, code: &[u8]) -> io::Result<(usize, u64)> {
    emit_exec_sections(path, code, &[], &[])
}

pub fn emit_exit(path: &Path, exit_code: u8) -> io::Result<(usize, u64)> {
    let mut code = [0u8; 12];
    code[0] = 0xb8;
    wr32(&mut code, 1, 60);
    code[5] = 0xbf;
    wr32(&mut code, 6, u32::from(exit_code));
    code[10] = 0x0f;
    code[11] = 0x05;
    emit_exec_rx(path, &code)
}

pub fn layout_for_codegen(code_len: usize, rodata_len: usize, data_len: usize) -> ExecLayout {
    exec_layout(code_len, rodata_len, data_len).0
}

pub fn patch_pc32(code: &mut [u8], patch_off: usize, target_va: u64, rip_next_va: u64) -> bool {
    let rel = target_va as i64 - rip_next_va as i64;
    if rel < i32::MIN as i64 || rel > i32::MAX as i64 {
        return false;
    }
    wr32(code, patch_off, rel as u32);
    true
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn exit_stub_layout() {
        let (logical, entry) = {
            let dir = std::env::temp_dir();
            let p = dir.join("nano-jit-rs-elf64-test.elf");
            let r = emit_exit(&p, 42).unwrap();
            let _ = fs::remove_file(&p);
            r
        };
        assert_eq!(logical, 132);
        assert_eq!(entry, 0x400_078);
    }
}
