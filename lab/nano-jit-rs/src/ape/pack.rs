//! APE v2 pack — port of C `cmd_pack_ape` / `cmd_pack_ape_bare`.

use super::{
    emit_v2_header, header_bytes, is_elf, SliceRow, ARCH_AARCH64, ARCH_X86_64, OS_LINUX,
};
use crate::lbin::fnv1a64;
use std::env;
use std::fs;
use std::io::{self, Write};
use std::path::Path;

#[cfg(unix)]
use std::os::unix::fs::PermissionsExt;

fn read_elf(path: &Path, label: &str) -> Result<Vec<u8>, i32> {
    let data = fs::read(path).map_err(|_| {
        let _ = writeln!(io::stderr(), "{label}=read_fail path={}", path.display());
        1
    })?;
    if !is_elf(&data) {
        let _ = writeln!(io::stderr(), "{label}=input_not_elf");
        return Err(1);
    }
    Ok(data)
}

fn pack_v2_payload(x86: &[u8], arm: &[u8]) -> Vec<u8> {
    let x86_hash = fnv1a64(x86);
    let arm_hash = fnv1a64(arm);
    let rows = [
        SliceRow {
            arch_id: ARCH_X86_64,
            os_id: OS_LINUX,
            offset: 0,
            size: x86.len() as u64,
            hash: x86_hash,
        },
        SliceRow {
            arch_id: ARCH_AARCH64,
            os_id: OS_LINUX,
            offset: x86.len() as u64,
            size: arm.len() as u64,
            hash: arm_hash,
        },
    ];
    let mut out = emit_v2_header(&rows);
    out.extend_from_slice(x86);
    out.extend_from_slice(arm);
    out
}

pub fn pack_ape_bare(out_path: &Path, x86_path: &Path, arm_path: &Path) -> i32 {
    let x86 = match read_elf(x86_path, "pack-ape-bare") {
        Ok(d) => d,
        Err(e) => return e,
    };
    let arm = match read_elf(arm_path, "pack-ape-bare") {
        Ok(d) => d,
        Err(e) => return e,
    };
    let out = pack_v2_payload(&x86, &arm);
    if fs::write(out_path, &out).is_err() {
        let _ = writeln!(
            io::stderr(),
            "pack-ape-bare=write_fail path={}",
            out_path.display()
        );
        return 3;
    }
    let v2_hdr_bytes = header_bytes(2);
    println!("pack-ape-bare.output={}", out_path.display());
    println!("pack-ape-bare.container=ape-v2");
    println!("pack-ape-bare.mode=bare");
    println!("pack-ape-bare.header_bytes={v2_hdr_bytes}");
    println!("pack-ape-bare.bytes={}", out.len());
    println!("pack-ape-bare.x86_64.bytes={}", x86.len());
    println!("pack-ape-bare.aarch64.bytes={}", arm.len());
    0
}

fn pack_ape_mode() -> &'static str {
    match env::var("NANO_PACK_APE_MODE").as_deref() {
        Ok("bare") => "bare",
        Ok("stub") | Ok("") | Err(_) => "stub",
        Ok(other) => {
            let _ = writeln!(
                io::stderr(),
                "pack-ape: unknown NANO_PACK_APE_MODE={other} (use stub|bare)"
            );
            "stub"
        }
    }
}

fn build_stub(v2_hdr_bytes: usize, x86_n: usize, arm_payload_off: usize, arm_n: usize, x86_hash: u64, arm_hash: u64) -> String {
    format!(
        "#!/bin/sh\n\
set -eu\n\
# nano.loader=run-ape-cli (NANO_JIT or nano-lisp-jit run-ape only; no runtime dd when set)\n\
if [ -n \"${{NANO_JIT:-}}\" ]; then\n\
  exec \"${{NANO_JIT}}\" run-ape \"$0\" \"$@\"\n\
fi\n\
if command -v nano-lisp-jit >/dev/null 2>&1; then\n\
  exec nano-lisp-jit run-ape \"$0\" \"$@\"\n\
fi\n\
# nano.loader.fallback=dd-extract (only when NANO_JIT unset and nano-lisp-jit missing)\n\
arch=\"$(uname -m)\"\n\
case \"$arch\" in\n\
  x86_64|amd64) off={v2_hdr_bytes}; size={x86_n}; suffix=x86_64 ;;\n\
  aarch64|arm64) off={arm_payload_off}; size={arm_n}; suffix=aarch64 ;;\n\
  *) echo \"nano pack-ape: unsupported arch $arch\" >&2; exit 126 ;;\n\
esac\n\
# nano.manifest.begin\n\
# nano.container=ape-v1\n\
# nano.slice.x86_64.offset={v2_hdr_bytes}\n\
# nano.slice.x86_64.size={x86_n}\n\
# nano.slice.x86_64.hash={x86_hash:016x}\n\
# nano.slice.aarch64.offset={arm_payload_off}\n\
# nano.slice.aarch64.size={arm_n}\n\
# nano.slice.aarch64.hash={arm_hash:016x}\n\
# nano.manifest.end\n\
payload_line=$(awk '/^__NANO_APE_PAYLOAD_BELOW__$/ {{ print NR + 1; exit }}' \"$0\")\n\
if [ -z \"${{payload_line:-}}\" ]; then echo \"nano pack-ape: payload marker missing\" >&2; exit 126; fi\n\
tmp=\"${{TMPDIR:-/tmp}}/nano-ape-$$-$suffix\"\n\
trap 'rm -f \"$tmp\"' EXIT HUP INT TERM\n\
tail -n +\"$payload_line\" \"$0\" | dd bs=1 skip=\"$off\" count=\"$size\" of=\"$tmp\" 2>/dev/null\n\
chmod +x \"$tmp\"\n\
exec \"$tmp\" \"$@\"\n\
exit 127\n\
__NANO_APE_PAYLOAD_BELOW__\n"
    )
}

#[cfg(unix)]
fn make_executable(path: &Path) -> bool {
    let Ok(meta) = fs::metadata(path) else {
        return false;
    };
    let mut perms = meta.permissions();
    perms.set_mode(0o755);
    fs::set_permissions(path, perms).is_ok()
}

#[cfg(not(unix))]
fn make_executable(_path: &Path) -> bool {
    true
}

pub fn pack_ape(out_path: &Path, x86_path: &Path, arm_path: &Path) -> i32 {
    if pack_ape_mode() == "bare" {
        return pack_ape_bare(out_path, x86_path, arm_path);
    }
    let x86 = match read_elf(x86_path, "pack-ape") {
        Ok(d) => d,
        Err(e) => return e,
    };
    let arm = match read_elf(arm_path, "pack-ape") {
        Ok(d) => d,
        Err(e) => return e,
    };
    let x86_hash = fnv1a64(&x86);
    let arm_hash = fnv1a64(&arm);
    let v2_hdr_bytes = header_bytes(2);
    let arm_payload_off = v2_hdr_bytes + x86.len();
    let stub = build_stub(
        v2_hdr_bytes,
        x86.len(),
        arm_payload_off,
        arm.len(),
        x86_hash,
        arm_hash,
    );
    let mut out = stub.into_bytes();
    out.extend(pack_v2_payload(&x86, &arm));
    if fs::write(out_path, &out).is_err() {
        let _ = writeln!(
            io::stderr(),
            "pack-ape=write_fail path={}",
            out_path.display()
        );
        return 3;
    }
    if !make_executable(out_path) {
        let _ = writeln!(
            io::stderr(),
            "pack-ape=chmod_fail path={}",
            out_path.display()
        );
        return 3;
    }
    println!("pack-ape.output={}", out_path.display());
    println!("pack-ape.mode=stub");
    println!("pack-ape.container=ape-v2");
    println!("pack-ape.header_bytes={v2_hdr_bytes}");
    println!("pack-ape.bytes={}", out.len());
    println!("pack-ape.x86_64.bytes={}", x86.len());
    println!("pack-ape.aarch64.bytes={}", arm.len());
    0
}
