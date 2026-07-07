//! ELF64 ET_REL object emission — port of `emit_elf64_obj_file` in `nano_elf64.c`.

use std::io;
use std::path::Path;

const EHDR_SIZE: usize = 64;
const SHDR_SIZE: usize = 64;
const SYM_SIZE: usize = 24;
const RELA_SIZE: usize = 24;

#[derive(Clone)]
pub struct ObjSymbol {
    pub name: String,
    pub info: u8,
    pub shndx: u16,
    pub value: u64,
    pub size: u64,
}

#[derive(Clone, Copy)]
pub struct ObjRela {
    pub offset: u64,
    pub sym_idx: u32,
    pub r#type: u32,
    pub addend: i64,
}

fn align_up(n: usize, a: usize) -> usize {
    (n + a - 1) & !(a - 1)
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

fn wr_ehdr_reloc(buf: &mut [u8], shoff: u64, shnum: u16, shstrndx: u16) {
    wr_ident(buf);
    wr16(buf, 16, 1);
    wr16(buf, 18, 62);
    wr32(buf, 20, 1);
    wr64(buf, 40, shoff);
    wr16(buf, 52, EHDR_SIZE as u16);
    wr16(buf, 58, SHDR_SIZE as u16);
    wr16(buf, 60, shnum);
    wr16(buf, 62, shstrndx);
}

fn wr_shdr(
    buf: &mut [u8],
    off: usize,
    name: u32,
    sh_type: u32,
    flags: u64,
    sec_off: u64,
    size: u64,
    link: u32,
    info: u32,
    align: u64,
    entsize: u64,
) {
    wr32(buf, off, name);
    wr32(buf, off + 4, sh_type);
    wr64(buf, off + 8, flags);
    wr64(buf, off + 24, sec_off);
    wr64(buf, off + 32, size);
    wr32(buf, off + 40, link);
    wr32(buf, off + 44, info);
    wr64(buf, off + 48, align);
    wr64(buf, off + 56, entsize);
}

fn wr_sym(
    buf: &mut [u8],
    off: usize,
    name: u32,
    info: u8,
    shndx: u16,
    value: u64,
    size: u64,
) {
    buf[off..off + SYM_SIZE].fill(0);
    wr32(buf, off, name);
    buf[off + 4] = info;
    wr16(buf, off + 6, shndx);
    wr64(buf, off + 8, value);
    wr64(buf, off + 16, size);
}

fn wr_rela(buf: &mut [u8], off: usize, r: &ObjRela) {
    wr64(buf, off, r.offset);
    wr64(buf, off + 8, (u64::from(r.sym_idx) << 32) | u64::from(r.r#type));
    wr64(buf, off + 16, r.addend as u64);
}

fn local_sym_info(syms: &[ObjSymbol]) -> Option<u32> {
    let mut local_count = 0usize;
    for s in syms {
        if s.info >> 4 == 0 {
            local_count += 1;
        } else {
            break;
        }
    }
    for s in syms.iter().skip(local_count) {
        if s.info >> 4 == 0 {
            return None;
        }
    }
    Some((1 + local_count) as u32)
}

pub fn emit_obj_file(
    path: &Path,
    text: &[u8],
    syms: &[ObjSymbol],
    relas: &[ObjRela],
) -> io::Result<()> {
    let symtab_info = local_sym_info(syms).ok_or_else(|| {
        io::Error::new(io::ErrorKind::InvalidData, "elf64.obj=bad_sym_info")
    })?;

    let shstr_no_rela: &[u8] = b"\0.text\0.shstrtab\0.symtab\0.strtab\0.note.GNU-stack\0";
    let shstr_with_rela: &[u8] =
        b"\0.text\0.rela.text\0.shstrtab\0.symtab\0.strtab\0.note.GNU-stack\0";
    let (shstr, shnum, shstrndx, symtab_link, text_name, rela_name, shstr_name, symtab_name, strtab_name, note_name) =
        if relas.is_empty() {
            (shstr_no_rela, 6u16, 2u16, 4u32, 1u32, 0u32, 7u32, 17u32, 25u32, 33u32)
        } else {
            (shstr_with_rela, 7u16, 3u16, 5u32, 1u32, 7u32, 18u32, 28u32, 36u32, 44u32)
        };

    let mut strtab = vec![0u8];
    let mut name_offs = Vec::with_capacity(syms.len());
    for s in syms {
        name_offs.push(strtab.len() as u32);
        strtab.extend_from_slice(s.name.as_bytes());
        strtab.push(0);
    }

    let off_text = EHDR_SIZE;
    let off_rela = if relas.is_empty() {
        0
    } else {
        align_up(off_text + text.len(), 8)
    };
    let off_shstr = if relas.is_empty() {
        off_text + text.len()
    } else {
        off_rela + relas.len() * RELA_SIZE
    };
    let off_strtab = off_shstr + shstr.len();
    let off_symtab = align_up(off_strtab + strtab.len(), 8);
    let symtab_n = (syms.len() + 1) * SYM_SIZE;
    let off_shdr = align_up(off_symtab + symtab_n, 8);
    let file_n = off_shdr + shnum as usize * SHDR_SIZE;

    let mut out = vec![0u8; file_n];
    wr_ehdr_reloc(&mut out, off_shdr as u64, shnum, shstrndx);
    out[off_text..off_text + text.len()].copy_from_slice(text);
    for (i, r) in relas.iter().enumerate() {
        wr_rela(&mut out, off_rela + i * RELA_SIZE, r);
    }
    out[off_shstr..off_shstr + shstr.len()].copy_from_slice(shstr);
    out[off_strtab..off_strtab + strtab.len()].copy_from_slice(&strtab);
    for (i, s) in syms.iter().enumerate() {
        wr_sym(
            &mut out,
            off_symtab + (i + 1) * SYM_SIZE,
            name_offs[i],
            s.info,
            s.shndx,
            s.value,
            s.size,
        );
    }

    let sh = off_shdr;
    wr_shdr(
        &mut out,
        sh + SHDR_SIZE,
        text_name,
        1,
        0x6,
        off_text as u64,
        text.len() as u64,
        0,
        0,
        16,
        0,
    );
    if !relas.is_empty() {
        wr_shdr(
            &mut out,
            sh + 2 * SHDR_SIZE,
            rela_name,
            4,
            0,
            off_rela as u64,
            (relas.len() * RELA_SIZE) as u64,
            4,
            1,
            8,
            RELA_SIZE as u64,
        );
    }
    let shstr_slot = shstrndx as usize;
    wr_shdr(
        &mut out,
        sh + shstr_slot * SHDR_SIZE,
        shstr_name,
        3,
        0,
        off_shstr as u64,
        shstr.len() as u64,
        0,
        0,
        1,
        0,
    );
    let symtab_slot = if relas.is_empty() { 3 } else { 4 };
    wr_shdr(
        &mut out,
        sh + symtab_slot * SHDR_SIZE,
        symtab_name,
        2,
        0,
        off_symtab as u64,
        symtab_n as u64,
        symtab_link,
        symtab_info,
        8,
        SYM_SIZE as u64,
    );
    let strtab_slot = if relas.is_empty() { 4 } else { 5 };
    wr_shdr(
        &mut out,
        sh + strtab_slot * SHDR_SIZE,
        strtab_name,
        3,
        0,
        off_strtab as u64,
        strtab.len() as u64,
        0,
        0,
        1,
        0,
    );
    let note_slot = if relas.is_empty() { 5 } else { 6 };
    wr_shdr(
        &mut out,
        sh + note_slot * SHDR_SIZE,
        note_name,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
    );

    std::fs::write(path, &out)
}

/// ET_REL with `.text` + `.rodata` or `.data` + matching `.rela.*` — port of
/// `emit_elf64_obj_text_data_section` in `nano_elf64.c`.
pub fn emit_obj_text_data_section(
    path: &Path,
    symbol: &str,
    text: &[u8],
    sec_name: &str,
    sec_data: &[u8],
    relas: &[ObjRela],
) -> io::Result<()> {
    const SHSTR: &[u8] = b"\0.text\0.rodata\0.data\0.rela.rodata\0.rela.data\0.shstrtab\0.symtab\0.strtab\0.note.GNU-stack\0";
    const SHSTR_TEXT: u32 = 1;
    const SHSTR_RODATA: u32 = 7;
    const SHSTR_DATA: u32 = 15;
    const SHSTR_RELA_RODATA: u32 = 21;
    const SHSTR_RELA_DATA: u32 = 34;
    const SHSTR_SHSTRTAB: u32 = 44;
    const SHSTR_SYMTAB: u32 = 54;
    const SHSTR_STRTAB: u32 = 61;
    const SHSTR_NOTE: u32 = 68;

    let is_data = sec_name == ".data";
    let sec_name_off = if is_data { SHSTR_DATA } else { SHSTR_RODATA };
    let rela_name_off = if is_data { SHSTR_RELA_DATA } else { SHSTR_RELA_RODATA };
    let sec_flags = if is_data { 3u64 } else { 2u64 };

    let syms = [
        ObjSymbol {
            name: "nano_blob_data".into(),
            info: 0x11,
            shndx: 2,
            value: 0,
            size: sec_data.len() as u64,
        },
        ObjSymbol {
            name: symbol.to_string(),
            info: 0x12,
            shndx: 1,
            value: 0,
            size: text.len() as u64,
        },
    ];

    let off_text = EHDR_SIZE;
    let off_sec = off_text + text.len();
    let off_rela = align_up(off_sec + sec_data.len(), 8);
    let off_shstr = off_rela + relas.len() * RELA_SIZE;
    let strtab_n = 1 + "nano_blob_data".len() + 1 + symbol.len() + 1;
    let off_strtab = off_shstr + SHSTR.len();
    let off_symtab = align_up(off_strtab + strtab_n, 8);
    let symtab_n = 3 * SYM_SIZE;
    let off_shdr = align_up(off_symtab + symtab_n, 8);
    let file_n = off_shdr + 8 * SHDR_SIZE;

    let mut out = vec![0u8; file_n];
    wr_ehdr_reloc(&mut out, off_shdr as u64, 8, 4);
    out[off_text..off_text + text.len()].copy_from_slice(text);
    out[off_sec..off_sec + sec_data.len()].copy_from_slice(sec_data);
    for (i, r) in relas.iter().enumerate() {
        wr_rela(&mut out, off_rela + i * RELA_SIZE, r);
    }
    out[off_shstr..off_shstr + SHSTR.len()].copy_from_slice(SHSTR);
    let name_offs = [1u32, 1 + "nano_blob_data".len() as u32 + 1];
    out[off_strtab] = 0;
    out[off_strtab + name_offs[0] as usize..off_strtab + name_offs[0] as usize + "nano_blob_data".len() + 1]
        .copy_from_slice(b"nano_blob_data\0");
    out[off_strtab + name_offs[1] as usize..off_strtab + name_offs[1] as usize + symbol.len() + 1]
        .copy_from_slice(format!("{symbol}\0").as_bytes());
    wr_sym(
        &mut out,
        off_symtab + SYM_SIZE,
        name_offs[0],
        syms[0].info,
        syms[0].shndx,
        syms[0].value,
        syms[0].size,
    );
    wr_sym(
        &mut out,
        off_symtab + 2 * SYM_SIZE,
        name_offs[1],
        syms[1].info,
        syms[1].shndx,
        syms[1].value,
        syms[1].size,
    );

    let sh = off_shdr;
    wr_shdr(
        &mut out,
        sh + SHDR_SIZE,
        SHSTR_TEXT,
        1,
        0x6,
        off_text as u64,
        text.len() as u64,
        0,
        0,
        16,
        0,
    );
    wr_shdr(
        &mut out,
        sh + 2 * SHDR_SIZE,
        sec_name_off,
        1,
        sec_flags,
        off_sec as u64,
        sec_data.len() as u64,
        0,
        0,
        1,
        0,
    );
    wr_shdr(
        &mut out,
        sh + 3 * SHDR_SIZE,
        rela_name_off,
        4,
        0,
        off_rela as u64,
        (relas.len() * RELA_SIZE) as u64,
        5,
        2,
        8,
        RELA_SIZE as u64,
    );
    wr_shdr(
        &mut out,
        sh + 4 * SHDR_SIZE,
        SHSTR_SHSTRTAB,
        3,
        0,
        off_shstr as u64,
        SHSTR.len() as u64,
        0,
        0,
        1,
        0,
    );
    wr_shdr(
        &mut out,
        sh + 5 * SHDR_SIZE,
        SHSTR_SYMTAB,
        2,
        0,
        off_symtab as u64,
        symtab_n as u64,
        6,
        2,
        8,
        SYM_SIZE as u64,
    );
    wr_shdr(
        &mut out,
        sh + 6 * SHDR_SIZE,
        SHSTR_STRTAB,
        3,
        0,
        off_strtab as u64,
        strtab_n as u64,
        0,
        0,
        1,
        0,
    );
    wr_shdr(
        &mut out,
        sh + 7 * SHDR_SIZE,
        SHSTR_NOTE,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
    );

    std::fs::write(path, &out)
}

pub fn rd16(data: &[u8], off: usize) -> u16 {
    u16::from_le_bytes(data[off..off + 2].try_into().unwrap())
}

pub fn rd32(data: &[u8], off: usize) -> u32 {
    u32::from_le_bytes(data[off..off + 4].try_into().unwrap())
}

pub fn rd64(data: &[u8], off: usize) -> u64 {
    u64::from_le_bytes(data[off..off + 8].try_into().unwrap())
}

pub fn patch_u32(buf: &mut [u8], off: usize, v: u32) {
    wr32(buf, off, v);
}
