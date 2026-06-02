//! APE v2 — inspect + pack (port of C `nano_ape.c` / `ape_v2.c`).

mod inspect;
mod pack;

pub use inspect::inspect_ape;
pub use pack::{pack_ape, pack_ape_bare};

pub const V2_MAGIC: [u8; 8] = [0x7f, b'N', b'A', b'N', b'O', b'a', b'p', b'e'];
pub const MARKER: &[u8] = b"__NANO_APE_PAYLOAD_BELOW__\n";
pub const V2_VERSION: u32 = 2;
pub const FIXED_HDR_BYTES: usize = 16;
pub const SLICE_ENTRY_BYTES: usize = 28;

pub const ARCH_X86_64: u8 = 1;
pub const ARCH_AARCH64: u8 = 2;
pub const OS_LINUX: u8 = 1;

pub fn header_bytes(slice_count: u16) -> usize {
    FIXED_HDR_BYTES + slice_count as usize * SLICE_ENTRY_BYTES
}

pub fn find_payload_start(data: &[u8]) -> Option<usize> {
    if let Some(idx) = data.windows(MARKER.len()).position(|w| w == MARKER) {
        let ps = idx + MARKER.len();
        if data[ps..].starts_with(&V2_MAGIC) {
            return Some(ps);
        }
    }
    let mut last = None;
    let mut i = 0;
    while i + V2_MAGIC.len() <= data.len() {
        if (i == 0 || data[i - 1] == b'\n') && data[i..i + V2_MAGIC.len()] == V2_MAGIC {
            last = Some(i);
        }
        i += 1;
    }
    last
}

pub fn is_elf(data: &[u8]) -> bool {
    data.len() >= 4 && data[..4] == [0x7f, b'E', b'L', b'F']
}

#[derive(Clone, Copy)]
pub struct SliceRow {
    pub arch_id: u8,
    pub os_id: u8,
    pub offset: u64,
    pub size: u64,
    pub hash: u64,
}

pub fn emit_v2_header(rows: &[SliceRow]) -> Vec<u8> {
    let slice_count = rows.len() as u16;
    let hdr_bytes = header_bytes(slice_count);
    let mut out = vec![0u8; hdr_bytes];
    out[..8].copy_from_slice(&V2_MAGIC);
    out[8..12].copy_from_slice(&V2_VERSION.to_le_bytes());
    out[12..14].copy_from_slice(&slice_count.to_le_bytes());
    out[14..16].copy_from_slice(&(hdr_bytes as u16).to_le_bytes());
    for (i, row) in rows.iter().enumerate() {
        let base = FIXED_HDR_BYTES + i * SLICE_ENTRY_BYTES;
        out[base] = row.arch_id;
        out[base + 1] = row.os_id;
        out[base + 2..base + 4].copy_from_slice(&0u16.to_le_bytes());
        out[base + 4..base + 12].copy_from_slice(&row.offset.to_le_bytes());
        out[base + 12..base + 20].copy_from_slice(&row.size.to_le_bytes());
        out[base + 20..base + 28].copy_from_slice(&row.hash.to_le_bytes());
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::lbin::fnv1a64;

    #[test]
    fn v2_header_size_two_slices() {
        assert_eq!(header_bytes(2), 72);
    }

    #[test]
    fn pack_payload_layout() {
        let x86 = b"\x7fELFx86";
        let arm = b"\x7fELFarm";
        let xh = fnv1a64(x86);
        let ah = fnv1a64(arm);
        let rows = [
            SliceRow {
                arch_id: ARCH_X86_64,
                os_id: OS_LINUX,
                offset: 0,
                size: x86.len() as u64,
                hash: xh,
            },
            SliceRow {
                arch_id: ARCH_AARCH64,
                os_id: OS_LINUX,
                offset: x86.len() as u64,
                size: arm.len() as u64,
                hash: ah,
            },
        ];
        let hdr = emit_v2_header(&rows);
        assert_eq!(hdr.len(), 72);
        assert_eq!(&hdr[..8], &V2_MAGIC);
    }
}
