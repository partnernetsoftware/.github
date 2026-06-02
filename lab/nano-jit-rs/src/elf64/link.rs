//! Tiny ELF64 ET_REL linker — port of `cmd_link_elf64_exe` in `nano_elf64.c`.

use super::{emit_exec_sections, patch_pc32, ExecLayout};
use super::obj::{patch_u32, rd16, rd32, rd64};
use std::io;
use std::path::Path;

const SHDR_SIZE: usize = 64;
const SYM_SIZE: usize = 24;
const RELA_SIZE: usize = 24;

struct ElfObj {
    data: Vec<u8>,
    text_idx: u16,
    text: usize,
    text_size: usize,
    out_off: usize,
    rodata_idx: u16,
    rodata: usize,
    rodata_size: usize,
    rodata_out_off: usize,
    data_idx: u16,
    data_sec: usize,
    data_size: usize,
    data_out_off: usize,
    symtab: usize,
    sym_count: usize,
    strtab: usize,
    strtab_size: usize,
    rela: usize,
    rela_count: usize,
    rela_rodata: usize,
    rela_rodata_count: usize,
    rela_data: usize,
    rela_data_count: usize,
}

struct LinkSym {
    name: String,
    value: u64,
}

fn is_elf(data: &[u8]) -> bool {
    data.len() >= 4 && data[0] == 0x7f && &data[1..4] == b"ELF"
}

fn elf_str(tab: &[u8], off: u32) -> Option<&str> {
    let off = off as usize;
    if off >= tab.len() {
        return None;
    }
    let slice = &tab[off..];
    let nul = slice.iter().position(|&b| b == 0)?;
    std::str::from_utf8(&slice[..nul]).ok()
}

fn parse_elf_obj(data: Vec<u8>) -> io::Result<ElfObj> {
    let fail = || io::Error::new(io::ErrorKind::InvalidData, "link-elf64-exe=parse_fail");
    if !is_elf(&data) || data.len() < 64 || rd16(&data, 16) != 1 || rd16(&data, 18) != 62 {
        return Err(fail());
    }
    let shoff = rd64(&data, 40) as usize;
    let shentsize = rd16(&data, 58) as usize;
    let shnum = rd16(&data, 60) as usize;
    let shstrndx = rd16(&data, 62) as u16;
    if shentsize < SHDR_SIZE || shoff > data.len() || shnum > (data.len() - shoff) / shentsize {
        return Err(fail());
    }

    let shstr_hdr = shoff + shstrndx as usize * shentsize;
    if shstr_hdr + 32 > data.len() {
        return Err(fail());
    }
    let shstr_off = rd64(&data, shstr_hdr + 24) as usize;
    let shstr_size = rd64(&data, shstr_hdr + 32) as usize;
    if shstr_off > data.len() || shstr_size > data.len() - shstr_off {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "link-elf64-exe=parse_fail",
        ));
    }

    let mut obj = ElfObj {
        data,
        text_idx: 0,
        text: 0,
        text_size: 0,
        out_off: 0,
        rodata_idx: 0,
        rodata: 0,
        rodata_size: 0,
        rodata_out_off: 0,
        data_idx: 0,
        data_sec: 0,
        data_size: 0,
        data_out_off: 0,
        symtab: 0,
        sym_count: 0,
        strtab: 0,
        strtab_size: 0,
        rela: 0,
        rela_count: 0,
        rela_rodata: 0,
        rela_rodata_count: 0,
        rela_data: 0,
        rela_data_count: 0,
    };

    for i in 1..shnum {
        let sh = shoff + i * shentsize;
        let name_off = rd32(&obj.data, sh);
        let ty = rd32(&obj.data, sh + 4);
        let off = rd64(&obj.data, sh + 24) as usize;
        let n = rd64(&obj.data, sh + 32) as usize;
        let link = rd32(&obj.data, sh + 40);
        let entsize = rd64(&obj.data, sh + 56) as usize;
        let name = elf_str(
            &obj.data[shstr_off..shstr_off + shstr_size],
            name_off,
        )
        .ok_or_else(fail)?;
        if off > obj.data.len() || n > obj.data.len() - off {
            return Err(fail());
        }
        match name {
            ".text" => {
                obj.text_idx = i as u16;
                obj.text = off;
                obj.text_size = n;
            }
            ".rodata" => {
                obj.rodata_idx = i as u16;
                obj.rodata = off;
                obj.rodata_size = n;
            }
            ".data" => {
                obj.data_idx = i as u16;
                obj.data_sec = off;
                obj.data_size = n;
            }
            ".rela.text" if ty == 4 && entsize == RELA_SIZE => {
                obj.rela = off;
                obj.rela_count = n / RELA_SIZE;
            }
            ".rela.rodata" if ty == 4 && entsize == RELA_SIZE => {
                obj.rela_rodata = off;
                obj.rela_rodata_count = n / RELA_SIZE;
            }
            ".rela.data" if ty == 4 && entsize == RELA_SIZE => {
                obj.rela_data = off;
                obj.rela_data_count = n / RELA_SIZE;
            }
            _ if ty == 2 && entsize == SYM_SIZE && (link as usize) < shnum => {
                let str_sh = shoff + link as usize * shentsize;
                let str_off = rd64(&obj.data, str_sh + 24) as usize;
                let str_n = rd64(&obj.data, str_sh + 32) as usize;
                if str_off > obj.data.len() || str_n > obj.data.len() - str_off {
                    return Err(io::Error::new(
                        io::ErrorKind::InvalidData,
                        "link-elf64-exe=parse_fail",
                    ));
                }
                obj.symtab = off;
                obj.sym_count = n / SYM_SIZE;
                obj.strtab = str_off;
                obj.strtab_size = str_n;
            }
            _ => {}
        }
    }

    if obj.text_size == 0 || obj.symtab == 0 {
        return Err(fail());
    }
    Ok(obj)
}

fn sym_name(o: &ElfObj, idx: usize) -> Option<String> {
    if idx >= o.sym_count {
        return None;
    }
    let sym = o.symtab + idx * SYM_SIZE;
    let off = rd32(&o.data, sym);
    elf_str(
        &o.data[o.strtab..o.strtab + o.strtab_size],
        off,
    )
    .map(str::to_string)
}

fn sym_binding(o: &ElfObj, idx: usize) -> u8 {
    o.data[o.symtab + idx * SYM_SIZE + 4] >> 4
}

fn sym_shndx(o: &ElfObj, idx: usize) -> u16 {
    rd16(&o.data, o.symtab + idx * SYM_SIZE + 6)
}

fn sym_value(o: &ElfObj, idx: usize) -> u64 {
    rd64(&o.data, o.symtab + idx * SYM_SIZE + 8)
}

fn rel32_ok(rel: i64) -> Option<u32> {
    if rel < i32::MIN as i64 || rel > i32::MAX as i64 {
        None
    } else {
        Some(rel as u32)
    }
}

fn find_sym(syms: &[LinkSym], name: &str) -> Option<u64> {
    syms.iter().find(|s| s.name == name).map(|s| s.value)
}

pub fn link_exe(path: &Path, entry_name: &str, obj_paths: &[&Path]) -> io::Result<usize> {
    let mut objs = Vec::new();
    for p in obj_paths {
        objs.push(parse_elf_obj(std::fs::read(p)?)?);
    }

    const STUB_N: usize = 14;
    let mut code = Vec::new();
    let mut rodata = Vec::new();
    let mut data_buf = Vec::new();
    let mut syms: Vec<LinkSym> = Vec::new();

    let mut text_off = STUB_N;
    for obj in &mut objs {
        obj.out_off = text_off;
        text_off += obj.text_size;
    }

    code.extend_from_slice(&[
        0xe8, 0, 0, 0, 0, 0x89, 0xc7, 0xb8, 0x3c, 0, 0, 0, 0x0f, 0x05,
    ]);
    for obj in &objs {
        code.extend_from_slice(&obj.data[obj.text..obj.text + obj.text_size]);
    }
    for obj in &mut objs {
        if obj.rodata_size > 0 {
            obj.rodata_out_off = rodata.len();
            rodata.extend_from_slice(&obj.data[obj.rodata..obj.rodata + obj.rodata_size]);
        }
        if obj.data_size > 0 {
            obj.data_out_off = data_buf.len();
            data_buf.extend_from_slice(&obj.data[obj.data_sec..obj.data_sec + obj.data_size]);
        }
    }

    let layout = super::layout_for_codegen(code.len(), rodata.len(), data_buf.len());

    for obj in &objs {
        for s in 1..obj.sym_count {
            if sym_shndx(obj, s) != obj.text_idx || sym_binding(obj, s) == 0 {
                continue;
            }
            let name = sym_name(obj, s).ok_or_else(|| {
                io::Error::new(io::ErrorKind::InvalidData, "link-elf64-exe=parse_fail")
            })?;
            if name.is_empty() {
                continue;
            }
            if find_sym(&syms, &name).is_some() {
                return Err(io::Error::new(
                    io::ErrorKind::InvalidData,
                    "link-elf64-exe=duplicate_symbol",
                ));
            }
            syms.push(LinkSym {
                name,
                value: layout.text_va + obj.out_off as u64 + sym_value(obj, s),
            });
        }
    }

    let entry_addr = find_sym(&syms, entry_name).ok_or_else(|| {
        io::Error::new(
            io::ErrorKind::InvalidData,
            "link-elf64-exe=entry_missing",
        )
    })?;
    let entry_rel = entry_addr as i64 - (layout.text_va + 5) as i64;
    patch_u32(
        &mut code,
        1,
        rel32_ok(entry_rel).ok_or_else(|| {
            io::Error::new(
                io::ErrorKind::InvalidData,
                "link-elf64-exe=entry_out_of_range",
            )
        })?,
    );

    for obj in &objs {
        for r in 0..obj.rela_count {
            let rela = obj.rela + r * RELA_SIZE;
            let r_off = rd64(&obj.data, rela);
            let r_info = rd64(&obj.data, rela + 8);
            let addend = rd64(&obj.data, rela + 16) as i64;
            let ty = r_info as u32;
            let sym_idx = (r_info >> 32) as usize;
            if ty != 4 || sym_idx >= obj.sym_count || r_off > obj.text_size as u64 - 4 {
                return Err(io::Error::new(
                    io::ErrorKind::InvalidData,
                    "link-elf64-exe=unsupported_reloc",
                ));
            }
            let target = if sym_binding(obj, sym_idx) == 0 {
                if sym_shndx(obj, sym_idx) != obj.text_idx {
                    return Err(io::Error::new(
                        io::ErrorKind::InvalidData,
                        "link-elf64-exe=unsupported_local_reloc",
                    ));
                }
                layout.text_va + obj.out_off as u64 + sym_value(obj, sym_idx)
            } else {
                let name = sym_name(obj, sym_idx).unwrap_or_default();
                find_sym(&syms, &name).ok_or_else(|| {
                    io::Error::new(
                        io::ErrorKind::InvalidData,
                        "link-elf64-exe=symbol_missing",
                    )
                })?
            };
            let place = layout.text_va + obj.out_off as u64 + r_off;
            let rel = target as i64 + addend - place as i64;
            patch_u32(
                &mut code,
                obj.out_off + r_off as usize,
                rel32_ok(rel).ok_or_else(|| {
                    io::Error::new(
                        io::ErrorKind::InvalidData,
                        "link-elf64-exe=reloc_out_of_range",
                    )
                })?,
            );
        }

        apply_sec_rela(
            &mut code,
            obj,
            obj.rela_rodata,
            obj.rela_rodata_count,
            &layout,
            layout.rodata_va,
            obj.rodata_out_off,
            obj.rodata_idx,
        )?;
        apply_sec_rela(
            &mut code,
            obj,
            obj.rela_data,
            obj.rela_data_count,
            &layout,
            layout.data_va,
            obj.data_out_off,
            obj.data_idx,
        )?;
    }

    emit_exec_sections(path, &code, &rodata, &data_buf)?;
    Ok(code.len())
}

fn apply_sec_rela(
    code: &mut [u8],
    obj: &ElfObj,
    rela_tab: usize,
    rela_count: usize,
    layout: &ExecLayout,
    sec_va: u64,
    sec_out_off: usize,
    sec_shndx: u16,
) -> io::Result<()> {
    if rela_count == 0 {
        return Ok(());
    }
    for r in 0..rela_count {
        let rela = rela_tab + r * RELA_SIZE;
        let r_off = rd64(&obj.data, rela);
        let r_info = rd64(&obj.data, rela + 8);
        let addend = rd64(&obj.data, rela + 16) as i64;
        let ty = r_info as u32;
        let sym_idx = (r_info >> 32) as usize;
        if ty != 1 || sym_idx >= obj.sym_count || r_off > obj.text_size as u64 - 4 {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                "link-elf64-exe=unsupported_data_reloc",
            ));
        }
        if sym_shndx(obj, sym_idx) != sec_shndx {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                "link-elf64-exe=bad_data_symbol",
            ));
        }
        let target = sec_va + sec_out_off as u64 + sym_value(obj, sym_idx) + addend as u64;
        let rip_next = layout.text_va + obj.out_off as u64 + r_off + 4;
        if !patch_pc32(
            code,
            obj.out_off + r_off as usize,
            target,
            rip_next,
        ) {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                "link-elf64-exe=data_reloc_out_of_range",
            ));
        }
    }
    Ok(())
}

pub fn link_exe_from_obj(path: &Path, entry: &str, obj: &Path) -> io::Result<usize> {
    link_exe(path, entry, &[obj])
}

#[cfg(test)]
mod tests {
    use crate::elf64::obj::{emit_obj_file, ObjSymbol};
    use super::*;

    #[test]
    fn roundtrip_emit_parse_link() {
        let dir = std::env::temp_dir();
        let obj = dir.join("nano-jit-rs-link-test.o");
        let exe = dir.join("nano-jit-rs-link-test.elf");
        let text = [0xb8, 42, 0, 0, 0, 0xc3];
        emit_obj_file(
            &obj,
            &text,
            &[ObjSymbol {
                name: "nano_main".into(),
                info: 0x12,
                shndx: 1,
                value: 0,
                size: text.len() as u64,
            }],
            &[],
        )
        .unwrap();
        parse_elf_obj(std::fs::read(&obj).unwrap()).expect("parse");
        link_exe_from_obj(&exe, "nano_main", &obj).expect("link");
        let _ = std::fs::remove_file(&obj);
        let _ = std::fs::remove_file(&exe);
    }
}
