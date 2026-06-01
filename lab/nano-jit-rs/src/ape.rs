//! APE v2 inspect — subset of C `inspect-ape`.

use crate::lbin::{rd32, fnv1a64};
use std::fs;
use std::io::{self, Write};
use std::path::Path;

const V2_MAGIC: [u8; 8] = [0x7f, b'N', b'A', b'N', b'O', b'a', b'p', b'e'];
const MARKER: &[u8] = b"__NANO_APE_PAYLOAD_BELOW__\n";

pub fn inspect_ape(path: &Path) -> i32 {
    let data = match fs::read(path) {
        Ok(d) => d,
        Err(_) => {
            let _ = writeln!(io::stderr(), "inspect-ape=read_fail");
            return 2;
        }
    };
    let payload_start = match find_payload_start(&data) {
        Some(p) => p,
        None => {
            let _ = writeln!(io::stderr(), "inspect-ape=payload_region_missing");
            return 2;
        }
    };
    if payload_start + 16 > data.len() || data[payload_start..payload_start + 8] != V2_MAGIC {
        let _ = writeln!(io::stderr(), "inspect-ape=bad_magic");
        return 3;
    }
    let version = rd32(&data, payload_start + 8);
    if version != 2 {
        let _ = writeln!(io::stderr(), "inspect-ape=bad_version");
        return 3;
    }
    let slice_count = u16::from_le_bytes(data[payload_start + 12..payload_start + 14].try_into().unwrap());
    let header_bytes = u16::from_le_bytes(data[payload_start + 14..payload_start + 16].try_into().unwrap());
    let expected_hdr = 16 + slice_count as usize * 28;
    if header_bytes as usize != expected_hdr {
        let _ = writeln!(io::stderr(), "inspect-ape=bad_header_bytes");
        return 4;
    }
    let payload_base = payload_start + header_bytes as usize;
    if payload_base > data.len() {
        let _ = writeln!(io::stderr(), "inspect-ape=truncated_header");
        return 2;
    }
    println!("inspect-ape.path={}", path.display());
    println!("inspect-ape.container=ape-v2");
    println!("inspect-ape.header_bytes={header_bytes}");
    println!("inspect-ape.slice_count={slice_count}");
    for i in 0..slice_count {
        let row = payload_start + 16 + i as usize * 28;
        let arch_id = data[row];
        let os_id = data[row + 1];
        let offset = u64::from_le_bytes(data[row + 4..row + 12].try_into().unwrap());
        let size = u64::from_le_bytes(data[row + 12..row + 20].try_into().unwrap());
        let hash = u64::from_le_bytes(data[row + 20..row + 28].try_into().unwrap());
        if size == 0 {
            // probe placeholder row
            println!("inspect-ape.slice.{i}.arch_id={arch_id}");
            println!("inspect-ape.slice.{i}.os_id={os_id}");
            println!("inspect-ape.slice.{i}.offset={offset}");
            println!("inspect-ape.slice.{i}.size={size}");
            println!("inspect-ape.slice.{i}.hash={hash:016x}");
            continue;
        }
        let abs = payload_base + offset as usize;
        if abs + size as usize > data.len() {
            let _ = writeln!(io::stderr(), "inspect-ape=bad_offset arch_id={arch_id}");
            return 4;
        }
        if data[abs..abs + 4] != [0x7f, b'E', b'L', b'F'] {
            let _ = writeln!(io::stderr(), "inspect-ape=bad_slice_elf arch_id={arch_id}");
            return 4;
        }
        if hash != 0 {
            let actual = fnv1a64(&data[abs..abs + size as usize]);
            if actual != hash {
                let _ = writeln!(
                    io::stderr(),
                    "inspect-ape=bad_hash arch_id={arch_id} expected={hash:016x} actual={actual:016x}"
                );
                return 5;
            }
        }
        println!("inspect-ape.slice.{i}.arch_id={arch_id}");
        println!("inspect-ape.slice.{i}.os_id={os_id}");
        println!("inspect-ape.slice.{i}.offset={offset}");
        println!("inspect-ape.slice.{i}.size={size}");
        println!("inspect-ape.slice.{i}.hash={hash:016x}");
    }
    println!("inspect-ape.universal.loader=v2-payload-table");
    println!("inspect-ape.ok=1");
    0
}

fn find_payload_start(data: &[u8]) -> Option<usize> {
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
