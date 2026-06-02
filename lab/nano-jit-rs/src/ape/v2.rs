//! APE v2 parse + validate — shared by inspect-ape and run-ape.

use super::{
    find_payload_start, header_bytes, is_elf, SliceRow, ARCH_AARCH64, ARCH_X86_64, OS_LINUX,
    V2_MAGIC,
};
use crate::lbin::{fnv1a64, rd32};

#[derive(Debug, Clone)]
pub struct V2Image {
    pub payload_start: usize,
    pub header_bytes: usize,
    pub slice_count: u16,
    pub slices: Vec<SliceRow>,
}

impl V2Image {
    pub fn payload_base(&self) -> usize {
        self.payload_start + self.header_bytes
    }

    pub fn slice_bytes<'a>(&self, data: &'a [u8], row: &SliceRow) -> Option<&'a [u8]> {
        if row.size == 0 {
            return None;
        }
        let base = self.payload_base() + row.offset as usize;
        let end = base + row.size as usize;
        if end > data.len() {
            return None;
        }
        Some(&data[base..end])
    }
}

pub fn load_v2(data: &[u8], prefix: &str) -> Result<V2Image, i32> {
    let payload_start = find_payload_start(data).ok_or_else(|| {
        eprintln!("{prefix}=payload_region_missing");
        2
    })?;
    if payload_start + 16 > data.len() || data[payload_start..payload_start + 8] != V2_MAGIC {
        eprintln!("{prefix}=bad_magic");
        return Err(3);
    }
    let version = rd32(data, payload_start + 8);
    if version != 2 {
        eprintln!("{prefix}=bad_version");
        return Err(3);
    }
    let slice_count =
        u16::from_le_bytes(data[payload_start + 12..payload_start + 14].try_into().unwrap());
    let hdr_bytes =
        u16::from_le_bytes(data[payload_start + 14..payload_start + 16].try_into().unwrap());
    let expected = header_bytes(slice_count);
    if hdr_bytes as usize != expected {
        eprintln!("{prefix}=bad_header_bytes");
        return Err(4);
    }
    let payload_base = payload_start + expected;
    if payload_base > data.len() {
        eprintln!("{prefix}=truncated_header");
        return Err(2);
    }
    let mut slices = Vec::with_capacity(slice_count as usize);
    for i in 0..slice_count {
        let row = payload_start + 16 + i as usize * 28;
        let arch_id = data[row];
        let os_id = data[row + 1];
        let reserved = u16::from_le_bytes(data[row + 2..row + 4].try_into().unwrap());
        if reserved != 0 {
            eprintln!("{prefix}=bad_slice_reserved arch_id={arch_id}");
            return Err(4);
        }
        if arch_id != ARCH_X86_64 && arch_id != ARCH_AARCH64 {
            eprintln!("{prefix}=bad_slice_ids arch_id={arch_id} os_id={os_id}");
            return Err(4);
        }
        if os_id != 0 && os_id != OS_LINUX {
            eprintln!("{prefix}=bad_slice_ids arch_id={arch_id} os_id={os_id}");
            return Err(4);
        }
        let offset = u64::from_le_bytes(data[row + 4..row + 12].try_into().unwrap());
        let size = u64::from_le_bytes(data[row + 12..row + 20].try_into().unwrap());
        let hash = u64::from_le_bytes(data[row + 20..row + 28].try_into().unwrap());
        slices.push(SliceRow {
            arch_id,
            os_id,
            offset,
            size,
            hash,
        });
    }
    let img = V2Image {
        payload_start,
        header_bytes: expected,
        slice_count,
        slices,
    };
    validate_slices(data, &img, prefix)?;
    validate_hashes(data, &img, prefix)?;
    Ok(img)
}

fn validate_slices(data: &[u8], img: &V2Image, prefix: &str) -> Result<(), i32> {
    let base = img.payload_base();
    for row in &img.slices {
        if row.size == 0 {
            continue;
        }
        let abs = base + row.offset as usize;
        if row.offset as usize > data.len() - base || (row.size as usize) > data.len() - abs {
            eprintln!(
                "{prefix}=bad_offset arch_id={} off={} size={} base={} file={}",
                row.arch_id,
                row.offset,
                row.size,
                base,
                data.len()
            );
            return Err(4);
        }
        if !is_elf(&data[abs..abs + row.size as usize]) {
            eprintln!("{prefix}=bad_slice_elf arch_id={}", row.arch_id);
            return Err(4);
        }
    }
    Ok(())
}

fn validate_hashes(data: &[u8], img: &V2Image, prefix: &str) -> Result<(), i32> {
    for row in &img.slices {
        if row.hash == 0 || row.size == 0 {
            continue;
        }
        let slice = img.slice_bytes(data, row).ok_or(4)?;
        let actual = fnv1a64(slice);
        if actual != row.hash {
            eprintln!(
                "{prefix}=bad_hash arch_id={} expected={:016x} actual={:016x}",
                row.arch_id, row.hash, actual
            );
            return Err(5);
        }
    }
    Ok(())
}

pub fn select_slice<'a>(
    img: &'a V2Image,
    force_arch: Option<&str>,
) -> Result<(&'a SliceRow, &'static str), i32> {
    let (want, name) = match force_arch {
        Some("x86_64") => (ARCH_X86_64, "x86_64"),
        Some("aarch64") => (ARCH_AARCH64, "aarch64"),
        Some(other) => {
            eprintln!("run-ape=bad_arch value={other}");
            return Err(127);
        }
        None => match std::env::consts::ARCH {
            "x86_64" => (ARCH_X86_64, "x86_64"),
            "aarch64" => (ARCH_AARCH64, "aarch64"),
            machine => {
                eprintln!("run-ape=unsupported_arch machine={machine}");
                return Err(126);
            }
        },
    };
    for row in &img.slices {
        if row.arch_id == want
            && (row.os_id == 0 || row.os_id == OS_LINUX)
            && row.size > 0
        {
            return Ok((row, name));
        }
    }
    eprintln!("run-ape=slice_missing arch_id={want}");
    Err(4)
}
