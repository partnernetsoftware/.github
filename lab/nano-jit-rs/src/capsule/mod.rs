//! NLCap v0 — multi-tier adaptive container (`.nlcap`).
//!
//! Tiers: `.lbin` (T0 raw VM bytecode), `.sbin` (T1 zstd), `.xbin` (T2 ELF64 slice).

use crate::compile;
use crate::lbin::{fnv1a64, parse_blob, MAGIC_LBIN};
use crate::run;
use crate::vm;
use std::fs;
use std::path::Path;
use std::process::Command;

pub const MAGIC: &[u8; 8] = b"NLCAP0\0\0";
pub const HEADER_SIZE: usize = 32;
pub const TIER_ENTRY_SIZE: usize = 32;

pub const TIER_LBIN: u32 = 1;
pub const TIER_SBIN: u32 = 2;
pub const TIER_XBIN: u32 = 3;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TierEntry {
    pub kind: u32,
    pub priority: u32,
    pub offset: u64,
    pub size: u64,
    pub hash: u64,
}

#[derive(Debug)]
pub struct Capsule {
    pub version: u32,
    pub tiers: Vec<TierEntry>,
    pub data: Vec<u8>,
}

fn write_u32(buf: &mut Vec<u8>, v: u32) {
    buf.extend_from_slice(&v.to_le_bytes());
}

fn write_u64(buf: &mut Vec<u8>, v: u64) {
    buf.extend_from_slice(&v.to_le_bytes());
}

fn read_u32(data: &[u8], off: usize) -> Option<u32> {
    let s: [u8; 4] = data.get(off..off + 4)?.try_into().ok()?;
    Some(u32::from_le_bytes(s))
}

fn read_u64(data: &[u8], off: usize) -> Option<u64> {
    let s: [u8; 8] = data.get(off..off + 8)?.try_into().ok()?;
    Some(u64::from_le_bytes(s))
}

pub fn tier_kind_name(kind: u32) -> &'static str {
    match kind {
        TIER_LBIN => "lbin",
        TIER_SBIN => "sbin",
        TIER_XBIN => "xbin",
        _ => "unknown",
    }
}

pub fn parse_capsule(data: &[u8]) -> Result<Capsule, i32> {
    if data.len() < HEADER_SIZE {
        eprintln!("inspect-capsule=too_small");
        return Err(1);
    }
    if &data[..8] != MAGIC {
        eprintln!("inspect-capsule=bad_magic");
        return Err(1);
    }
    let version = read_u32(data, 8).unwrap_or(0);
    let tier_count = read_u32(data, 12).unwrap_or(0) as usize;
    let table_end = HEADER_SIZE + tier_count * TIER_ENTRY_SIZE;
    if data.len() < table_end {
        eprintln!("inspect-capsule=truncated_table");
        return Err(1);
    }
    let mut tiers = Vec::with_capacity(tier_count);
    for i in 0..tier_count {
        let base = HEADER_SIZE + i * TIER_ENTRY_SIZE;
        tiers.push(TierEntry {
            kind: read_u32(data, base).unwrap_or(0),
            priority: read_u32(data, base + 4).unwrap_or(0),
            offset: read_u64(data, base + 8).unwrap_or(0),
            size: read_u64(data, base + 16).unwrap_or(0),
            hash: read_u64(data, base + 24).unwrap_or(0),
        });
    }
    Ok(Capsule {
        version,
        tiers,
        data: data.to_vec(),
    })
}

pub fn pack_capsule(
    out_path: &Path,
    lbin: &[u8],
    compress: bool,
    xbin: Option<&[u8]>,
) -> Result<Capsule, i32> {
    if lbin.len() >= 8 && &lbin[..8] != MAGIC_LBIN {
        eprintln!("pack-capsule=bad_lbin_magic");
        return Err(1);
    }
    let mut tiers: Vec<(u32, u32, Vec<u8>)> = Vec::new();
    tiers.push((TIER_LBIN, 300, lbin.to_vec()));
    if compress {
        let compressed = zstd::encode_all(lbin, 3).map_err(|_| {
            eprintln!("pack-capsule=zstd_fail");
            2
        })?;
        tiers.push((TIER_SBIN, 200, compressed));
    }
    if let Some(elf) = xbin {
        if elf.len() < 4 || &elf[..4] != b"\x7fELF" {
            eprintln!("pack-capsule=xbin_not_elf");
            return Err(1);
        }
        tiers.push((TIER_XBIN, 100, elf.to_vec()));
    }
    tiers.sort_by_key(|(_, pri, _)| *pri);

    let table_end = HEADER_SIZE + tiers.len() * TIER_ENTRY_SIZE;
    let mut offset = table_end as u64;
    let mut entries = Vec::new();
    let mut payload = Vec::new();
    for (kind, priority, blob) in &tiers {
        let hash = fnv1a64(blob);
        entries.push(TierEntry {
            kind: *kind,
            priority: *priority,
            offset,
            size: blob.len() as u64,
            hash,
        });
        payload.extend_from_slice(blob);
        offset += blob.len() as u64;
    }

    let mut out = Vec::with_capacity(table_end + payload.len());
    out.extend_from_slice(MAGIC);
    write_u32(&mut out, 0);
    write_u32(&mut out, entries.len() as u32);
    write_u32(&mut out, table_end as u32);
    write_u32(&mut out, 0);
    out.extend_from_slice(&[0u8; 8]);
    for e in &entries {
        write_u32(&mut out, e.kind);
        write_u32(&mut out, e.priority);
        write_u64(&mut out, e.offset);
        write_u64(&mut out, e.size);
        write_u64(&mut out, e.hash);
    }
    out.extend_from_slice(&payload);

    fs::write(out_path, &out).map_err(|_| {
        eprintln!("pack-capsule=write_fail path={}", out_path.display());
        3
    })?;

    Ok(Capsule {
        version: 0,
        tiers: entries,
        data: out,
    })
}

fn tier_payload<'a>(cap: &'a Capsule, tier: &TierEntry) -> Option<&'a [u8]> {
    let start = tier.offset as usize;
    let end = start.checked_add(tier.size as usize)?;
    cap.data.get(start..end)
}

fn load_lbin_from_capsule(cap: &Capsule, tier: &TierEntry) -> Result<Vec<u8>, i32> {
    let payload = tier_payload(cap, tier).ok_or_else(|| {
        eprintln!("run-capsule=tier_truncated");
        1
    })?;
    match tier.kind {
        TIER_LBIN => Ok(payload.to_vec()),
        TIER_SBIN => zstd::decode_all(payload).map_err(|_| {
            eprintln!("run-capsule=zstd_fail");
            2
        }),
        _ => {
            eprintln!("run-capsule=bad_tier_for_lbin");
            Err(1)
        }
    }
}

fn pick_tier<'a>(cap: &'a Capsule, mode: &str) -> Result<&'a TierEntry, i32> {
    match mode {
        "lbin" => cap
            .tiers
            .iter()
            .find(|t| t.kind == TIER_LBIN)
            .ok_or_else(|| {
                eprintln!("run-capsule=no_lbin_tier");
                1
            }),
        "sbin" => cap
            .tiers
            .iter()
            .find(|t| t.kind == TIER_SBIN)
            .ok_or_else(|| {
                eprintln!("run-capsule=no_sbin_tier");
                1
            }),
        "xbin" => cap
            .tiers
            .iter()
            .find(|t| t.kind == TIER_XBIN)
            .ok_or_else(|| {
                eprintln!("run-capsule=no_xbin_tier");
                1
            }),
        "auto" | "" => cap
            .tiers
            .iter()
            .min_by_key(|t| t.priority)
            .ok_or_else(|| {
                eprintln!("run-capsule=no_tiers");
                1
            }),
        other => {
            eprintln!("run-capsule=bad_tier_mode mode={other}");
            Err(1)
        }
    }
}

pub fn inspect_capsule(path: &Path) -> i32 {
    let data = match fs::read(path) {
        Ok(d) => d,
        Err(_) => {
            eprintln!("inspect-capsule=read_fail path={}", path.display());
            return 1;
        }
    };
    let cap = match parse_capsule(&data) {
        Ok(c) => c,
        Err(e) => return e,
    };
    println!("inspect-capsule.path={}", path.display());
    println!("inspect-capsule.container=nlcap-v0");
    println!("inspect-capsule.version={}", cap.version);
    println!("inspect-capsule.tiers={}", cap.tiers.len());
    println!("inspect-capsule.bytes={}", cap.data.len());
    for (i, t) in cap.tiers.iter().enumerate() {
        println!(
            "inspect-capsule.tier.{i}.kind={}",
            tier_kind_name(t.kind)
        );
        println!("inspect-capsule.tier.{i}.priority={}", t.priority);
        println!("inspect-capsule.tier.{i}.offset={}", t.offset);
        println!("inspect-capsule.tier.{i}.size={}", t.size);
        println!("inspect-capsule.tier.{i}.hash={:016x}", t.hash);
    }
    0
}

pub fn run_capsule(path: &Path, tier_mode: &str, expect: Option<u64>) -> i32 {
    let data = match fs::read(path) {
        Ok(d) => d,
        Err(_) => {
            eprintln!("run-capsule=read_fail path={}", path.display());
            return 1;
        }
    };
    let cap = match parse_capsule(&data) {
        Ok(c) => c,
        Err(e) => return e,
    };
    let tier = match pick_tier(&cap, tier_mode) {
        Ok(t) => t,
        Err(e) => return e,
    };
    println!("run-capsule.path={}", path.display());
    println!("run-capsule.tier={}", tier_kind_name(tier.kind));

    if tier.kind == TIER_XBIN {
        let elf = match tier_payload(&cap, tier) {
            Some(p) => p,
            None => {
                eprintln!("run-capsule=xbin_truncated");
                return 1;
            }
        };
        let tmp = std::env::temp_dir().join(format!(
            "nanolisp-xbin-{}",
            std::process::id()
        ));
        if fs::write(&tmp, elf).is_err() {
            eprintln!("run-capsule=temp_write_fail");
            return 3;
        }
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let _ = fs::set_permissions(&tmp, fs::Permissions::from_mode(0o755));
        }
        let rc = if let Some(code) = expect {
            run::run_expect_exit(&tmp, &code.to_string())
        } else {
            match Command::new(&tmp).status() {
                Ok(s) => s.code().unwrap_or(1),
                Err(_) => {
                    let _ = fs::remove_file(&tmp);
                    eprintln!("run-capsule=exec_fail");
                    return 2;
                }
            }
        };
        let _ = fs::remove_file(&tmp);
        if rc == 0 {
            println!("run-capsule.ok=1");
        }
        return rc;
    }

    let lbin = match load_lbin_from_capsule(&cap, tier) {
        Ok(b) => b,
        Err(e) => return e,
    };
    let blob = match parse_blob(&lbin) {
        Ok(b) => b,
        Err(_) => {
            eprintln!("run-capsule=lbin_parse_fail");
            return 1;
        }
    };
    let rc = vm::execute(&blob);
    if rc == 0 {
        println!("run-capsule.ok=1");
    }
    rc
}

fn resolve_lbin_input(input: &Path) -> Result<Vec<u8>, i32> {
    let ext = input
        .extension()
        .and_then(|s| s.to_str())
        .unwrap_or("")
        .to_ascii_lowercase();
    if ext == "lbin" {
        return fs::read(input).map_err(|_| {
            eprintln!("pack-capsule=read_fail path={}", input.display());
            1
        });
    }
    match compile::compile_to_blob(input) {
        Ok(data) => Ok(data),
        Err(e) => {
            eprintln!("{e}");
            eprintln!("pack-capsule=compile_fail");
            Err(1)
        }
    }
}

pub fn cmd_pack_capsule(
    out_path: &Path,
    input: &Path,
    xbin_path: Option<&Path>,
    compress: bool,
) -> i32 {
    let lbin = match resolve_lbin_input(input) {
        Ok(b) => b,
        Err(e) => return e,
    };
    let xbin = if let Some(p) = xbin_path {
        match fs::read(p) {
            Ok(d) => Some(d),
            Err(_) => {
                eprintln!("pack-capsule=xbin_read_fail path={}", p.display());
                return 1;
            }
        }
    } else {
        None
    };
    let cap = match pack_capsule(out_path, &lbin, compress, xbin.as_deref()) {
        Ok(c) => c,
        Err(e) => return e,
    };
    println!("pack-capsule.output={}", out_path.display());
    println!("pack-capsule.container=nlcap-v0");
    println!("pack-capsule.tiers={}", cap.tiers.len());
    println!("pack-capsule.bytes={}", cap.data.len());
    println!("pack-capsule.lbin.bytes={}", lbin.len());
    if compress {
        if let Some(t) = cap.tiers.iter().find(|t| t.kind == TIER_SBIN) {
            println!("pack-capsule.sbin.bytes={}", t.size);
        }
    }
    if let Some(t) = cap.tiers.iter().find(|t| t.kind == TIER_XBIN) {
        println!("pack-capsule.xbin.bytes={}", t.size);
    }
    0
}

pub fn cmd_run_capsule(path: &Path, tier_mode: &str, expect_s: Option<&str>) -> i32 {
    let expect = if let Some(s) = expect_s {
        match s.parse::<u64>() {
            Ok(v) if v <= 255 => Some(v),
            _ => {
                eprintln!("run-capsule=bad_expect");
                return 1;
            }
        }
    } else {
        None
    };
    run_capsule(path, tier_mode, expect)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn roundtrip_lbin_sbin_tiers() {
        let mut fake = vec![0u8; 64];
        fake[..8].copy_from_slice(&MAGIC_LBIN);
        fake[8..12].copy_from_slice(&1u32.to_le_bytes());
        let tmp = std::env::temp_dir().join(format!(
            "nanolisp-cap-test-{}.nlcap",
            std::process::id()
        ));
        let cap = pack_capsule(&tmp, &fake, true, None).expect("pack");
        assert!(cap.tiers.len() >= 2);
        let parsed = parse_capsule(&cap.data).expect("parse");
        assert_eq!(parsed.tiers.len(), cap.tiers.len());
        let lbin_tier = parsed.tiers.iter().find(|t| t.kind == TIER_SBIN).unwrap();
        let decoded = load_lbin_from_capsule(&parsed, lbin_tier).expect("decode");
        assert_eq!(decoded, fake);
        let _ = fs::remove_file(&tmp);
    }
}
